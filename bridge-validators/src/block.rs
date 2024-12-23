use std::{marker::PhantomData, time::Duration};

use async_stream::try_stream;
use async_trait::async_trait;

use anyhow::{anyhow, Result};
use ethers::{
    providers::Middleware,
    types::{Address, Block, BlockNumber, Filter, Log, TxHash, ValueOrArray, U64},
};
use ethers_contract::{parse_log, EthEvent};
use futures::{Stream, StreamExt, TryStreamExt};
use tokio::time::interval;
use tracing::{info, warn};

use crate::client::{ChainClient, LogStrategy};

#[async_trait]
pub trait BlockPolling {
    #[allow(dead_code)]
    async fn stream_finalized_blocks(&mut self) -> Result<()>;
    #[allow(dead_code)]
    async fn get_historic_blocks(&self, from: u64, to: u64) -> Result<()>;

    async fn get_events<D>(&self, event: Filter, from_block: u64, to_block: u64) -> Result<Vec<D>>
    where
        D: EthEvent;
}

impl ChainClient {
    async fn get_logs_from_blocks(&self, event: Filter) -> Result<Vec<Log>> {
        // Fetch transactions for all the blocks in Filter.
        let mut result: Vec<Log> = Vec::new();
        let from_block: u64 = event
            .get_from_block()
            .ok_or(anyhow!(
                "from_block is not present in get_logs_from_blocks()"
            ))?
            .as_u64();
        let to_block: u64 = event
            .get_to_block()
            .ok_or(anyhow!("to_block is not present in get_logs_from_blocks()"))?
            .as_u64();
        for block_number in from_block..to_block + 1 {
            // eth_GetBlockReceipts is as broken as eth_getLogs, so we need to check each transaction
            // individually. Joy!
            let the_block: Option<Block<TxHash>> =
                self.client.provider().get_block(block_number).await?;
            if let Some(block) = the_block {
                // go through all the transactions
                for txn_hash in block.transactions {
                    // We have a transaction. Did it have any logs?
                    info!("block {} txn {:#x}", block_number, txn_hash);
                    // Get the receipt
                    let maybe_receipt = self
                        .client
                        .provider()
                        .get_transaction_receipt(txn_hash)
                        .await?;
                    if let Some(receipt) = maybe_receipt {
                        // Yay!
                        if let Some(v) = &receipt.status {
                            info!("[1] txn {:#x} has status {v}", txn_hash);
                            if *v != U64::from(1) {
                                info!("[1] txn failed - skipping");
                                continue;
                            }
                        } else {
                            info!("[1] txn {:#x} has no status - ignoring", txn_hash);
                            continue;
                        }
                        info!("Got receipt for txn {:#x}", txn_hash);
                        for log in receipt.logs {
                            // Because FML, the filter doesn't actually include the address.
                            if log.address != self.chain_gateway_address {
                                info!(
                                    "[1] event from {0:#x} != chain_gateway({1:#x})",
                                    log.address, self.chain_gateway_address
                                );
                                continue;
                            }
                            let mut matches: bool = true;
                            for topic_idx in 0..event.topics.len() {
                                if let Some(x) = &event.topics[topic_idx] {
                                    if let Some(y) = &log.topics.get(topic_idx) {
                                        let match_this_topic = match x {
                                            ValueOrArray::Value(xv) => {
                                                if let Some(xxv) = xv {
                                                    xxv == *y
                                                } else {
                                                    true
                                                }
                                            }
                                            ValueOrArray::Array(xvs) => xvs.iter().any(|cand| {
                                                if let Some(xcand) = cand {
                                                    *xcand == **y
                                                } else {
                                                    false
                                                }
                                            }),
                                        };
                                        if !match_this_topic {
                                            matches = false;
                                            break;
                                        }
                                    } else {
                                        matches = false;
                                        break;
                                    }
                                }
                                // If there's no filter element for this topic, we're fine.
                            }
                            if matches {
                                info!("Event matches; pushing for transit");
                                if let Some(v) = self.except.transform_log(&log) {
                                    result.push(v);
                                } else {
                                    info!("Log {log:?} could not be sent for transit due transform_log() failure");
                                }
                            }
                        }
                    } else {
                        warn!("WARNING: txn {:#x} has no receipt", txn_hash);
                    }
                }
            }
        }
        Ok(result)
    }
}

#[async_trait]
impl BlockPolling for ChainClient {
    async fn stream_finalized_blocks(&mut self) -> Result<()> {
        Ok(())
    }

    async fn get_historic_blocks(&self, from: u64, to: u64) -> Result<()> {
        let concurrent_requests = futures::stream::iter(
            (from..to).map(|block_number| self.client.get_block(block_number)),
        )
        .buffer_unordered(3)
        .map(|r| {
            println!("finished request: {:?}", r);
            r
        })
        .try_collect::<Vec<_>>();

        let _res = concurrent_requests.await;

        Ok(())
    }

    async fn get_events<D>(&self, event: Filter, from_block: u64, to_block: u64) -> Result<Vec<D>>
    where
        D: EthEvent,
    {
        let event = event
            .from_block(from_block)
            .to_block(to_block)
            .address(self.chain_gateway_address);

        let logs: Vec<Log> = match self.log_strategy {
            LogStrategy::GetLogs => {
                let logs: Vec<serde_json::Value> = self
                    .client
                    .provider()
                    .request("eth_getLogs", [event])
                    .await?;
                // zq1 will send logs for failed txns; this is avoided here at a higher
                // level, by forcing the strategy to be GetTransactions in client.rs
                logs.into_iter()
                    .filter(|log| {
                        log.get("address")
                            .and_then(|val| val.as_str())
                            .and_then(|val| val.parse::<Address>().ok())
                            .map(|from_address| {
                                if from_address == self.chain_gateway_address {
                                    true
                                } else {
                                    info!(
                                        "event from {0:#x} , chain gateway {1:#x}",
                                        from_address, self.chain_gateway_address
                                    );
                                    false
                                }
                            })
                            .unwrap_or(false)
                    })
                    .map(|log| {
                        // Parse log values
                        let mut log = log;
                        match log["removed"].as_str() {
                            Some("true") => log["removed"] = serde_json::Value::Bool(true),
                            Some("false") => log["removed"] = serde_json::Value::Bool(false),
                            Some(&_) => warn!("invalid parsing"),
                            None => (),
                        };
                        let log: Log = serde_json::from_value(log)?;
                        Ok(log)
                    })
                    .collect::<Result<Vec<Log>>>()?
            }
            LogStrategy::GetTransactions => self.get_logs_from_blocks(event).await?,
        };

        let events: Vec<D> = logs
            .into_iter()
            .filter_map(|log| self.except.transform_log(&log))
            .map(|log| Ok(parse_log::<D>(log)?))
            .collect::<Result<Vec<D>>>()?;

        return Ok(events);
    }
}

pub struct EventListener<D: EthEvent> {
    chain_client: ChainClient,
    current_block: U64,
    event: Filter,
    phantom: PhantomData<D>,
}

impl<D: EthEvent> EventListener<D> {
    pub fn new(chain_client: ChainClient, event: Filter) -> Self {
        EventListener {
            current_block: 0.into(),
            chain_client,
            event,
            phantom: PhantomData,
        }
    }

    async fn get_block_number(&self) -> Result<U64> {
        let block = if self.chain_client.block_instant_finality {
            self.chain_client.client.get_block_number().await
        } else {
            self.chain_client
                .client
                .get_block(BlockNumber::Finalized)
                .await
                .map(|block| block.unwrap().number.unwrap())
        }?;

        Ok(block)
    }

    async fn poll_next_events(&mut self) -> Result<Vec<D>>
    where
        D: EthEvent,
    {
        // Some chains (Zilliqa!) can't get it together to broadcast events at the block they are
        // currently at, so there is an option to deliberately delay checking back a few blocks,
        // until the node we are pointed at has the logs for the block and can therefore reply
        // correctly.
        let scan_behind_blocks = self.chain_client.scan_behind_blocks;
        let new_block: U64 = match self.get_block_number().await {
            Err(e) => {
                warn!(?e);
                let vec = Ok(vec![]);
                return vec;
            }
            Ok(block) => block,
        };

        // Don't worry about blocks we've already scanned.
        let min_block = self.current_block + 1;
        // Don't worry about blocks which are too recent for us to care about.
        let max_block = new_block - scan_behind_blocks;
        if max_block <= min_block {
            // No point in checking, return early
            return Ok(vec![]);
        }
        // `eth_getLogs`'s block_number is inclusive, so `current_block` is already retrieved
        let events = match self
            .chain_client
            .get_events(self.event.clone(), min_block.as_u64(), max_block.as_u64())
            .await
        {
            Err(err) => {
                warn!(
                    "Failed to fetch events on {} from {} to {}",
                    self.chain_client,
                    (self.current_block + 1),
                    new_block
                );
                warn!(?err);
                vec![]
            }
            Ok(events) => events,
        };
        info!(
            "{} Getting from {} to {}, events gathered {:?}",
            self.chain_client.chain_id,
            (self.current_block + 1),
            new_block,
            events.len(),
        );
        if !events.is_empty() {
            info!(
                "Getting from {} to {}, events gathered {:?}",
                (self.current_block + 1),
                new_block,
                events.len(),
            )
        }

        self.current_block = new_block;

        Ok(events)
    }

    pub fn listen(mut self) -> impl Stream<Item = Result<Vec<D>>> {
        let stream = try_stream! {
            // TODO: update block interval on config
            let mut interval = interval(Duration::from_secs(3));
            // Set this down 1 because we (almost) certainly haven't scanned this block
            // yet...
            self.current_block = self.chain_client.client.get_block_number().await? - 1;

            loop {
                interval.tick().await;

                let new_events =  self.poll_next_events().await?;
                yield new_events
            }
        };
        Box::pin(stream)
    }
}

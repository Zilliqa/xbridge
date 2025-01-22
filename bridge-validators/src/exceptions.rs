use crate::{ChainConfig, Exception};
use ethers::types::{Log, H256, U256};
use std::collections::HashMap;
use tracing::warn;

/// The exception processor handles exceptions - these are txns which were issued in error, usually as a result
/// of a bug in the relayer contracts; their parameters are corrected here before being passed on to the rest of
/// the relayer logic for execution.
#[derive(Debug, Clone)]
pub struct ExceptionProcessor {
    exceptions_by_txnhash: HashMap<H256, Exception>,
}

impl ExceptionProcessor {
    pub fn new(config: &ChainConfig, chain_id: U256) -> Self {
        let mut exceptions_by_txnhash = HashMap::new();
        config.exceptions.iter().for_each(|v| {
            v.iter().for_each(|i| {
                if i.chain_id == chain_id {
                    exceptions_by_txnhash.insert(i.transaction_id, i.clone());
                }
            })
        });
        warn!(
            "Loaded {0} exceptions for chain_id {1}",
            exceptions_by_txnhash.len(),
            chain_id
        );
        ExceptionProcessor {
            exceptions_by_txnhash,
        }
    }

    // We'll warn!() if we have to drop a log.
    pub fn transform_log(&self, log: &Log) -> Option<Log> {
        if let Some(hash) = log.transaction_hash {
            if let Some(except) = self.exceptions_by_txnhash.get(&hash) {
                if log
                    .block_number
                    .map_or(false, |x| x.as_u64() == except.block_number)
                    && log.block_hash.map_or(false, |x| x == except.block_hash)
                    && log.topics.len() == 2
                {
                    let mut new_log = log.clone();
                    new_log.topics[1] = except.replacement_chainid;
                    new_log.data = except.replacement_bytes.clone();
                    warn!("Found a match for exception {except:?} with log {log:?} - replacing log data to form {new_log:?}");
                    return Some(new_log);
                }
            }
        }
        Some(log.clone())
    }
}

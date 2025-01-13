use std::sync::Arc;

use crate::{exceptions, ChainGateway, ValidatorManager};
use anyhow::Result;
use ethers::{
    middleware::{MiddlewareBuilder, NonceManagerMiddleware, SignerMiddleware},
    providers::{Http, Middleware, Provider},
    signers::{LocalWallet, Signer},
    types::{Address, U256},
};
use serde::{Deserialize, Serialize};
use std::fmt;
use tracing::info;

use crate::ChainConfig;

pub type Client = NonceManagerMiddleware<SignerMiddleware<Provider<Http>, LocalWallet>>;

#[derive(Debug, Clone)]
pub enum LogStrategy {
    // use eth_getLogs()
    GetLogs,
    // scan every transaction individually
    GetTransactions,
}

#[derive(Debug, Clone)]
pub struct ChainClient {
    pub client: Arc<Client>,
    pub validator_manager_address: Address,
    pub chain_gateway_address: Address,
    pub chain_id: U256,
    pub wallet: LocalWallet,
    pub chain_gateway_block_deployed: u64,
    pub block_instant_finality: bool,
    pub gas_estimation_percent: Option<u64>,
    pub use_legacy_transactions: bool,
    pub scan_behind_blocks: u64,
    pub log_strategy: LogStrategy,
    pub to_block_number: Option<u64>,
    pub priority_fee_per_gas_max: Option<u64>,
    pub except: exceptions::ExceptionProcessor,
}

impl fmt::Display for ChainClient {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "chainid#{}", self.chain_id)
    }
}

#[derive(Serialize, Deserialize, Debug, Clone)]
pub struct VersionStruct {
    #[serde(rename = "Version")]
    pub version: String,
}

impl ChainClient {
    pub async fn new(config: &ChainConfig, wallet: LocalWallet) -> Result<Self> {
        info!(
            "initialising chain client for URL {0} with gateway {1:#x} ... ",
            config.rpc_url.as_str(),
            config.chain_gateway_address
        );
        let provider = Provider::<Http>::try_from(config.rpc_url.as_str())?;
        let maybe_version = provider
            .request::<(), VersionStruct>("GetVersion", ())
            .await
            .ok();
        // let provider = Provider::<Ws>::connect(&config.rpc_url).await?;
        let chain_id = provider.get_chainid().await?;
        let client: Arc<Client> = Arc::new(
            provider
                .with_signer(wallet.clone().with_chain_id(chain_id.as_u64()))
                .nonce_manager(wallet.address()),
        );
        // TODO: get the validator_manager_address from chain_gateway itself
        let chain_gateway = ChainGateway::new(config.chain_gateway_address, client.clone());
        let validator_manager_address: Address = chain_gateway.validator_manager().call().await?;
        let is_zilliqa1 = if let Some(version) = &maybe_version {
            version.version.to_lowercase().starts_with("v9.")
        } else {
            false
        };
        let strategy = if is_zilliqa1 {
            info!(
                "   ... this chain looks like zilliqa 1 ; forcing the GetTransactions log strategy"
            );
            LogStrategy::GetTransactions
        } else {
            match config.use_get_transactions {
                None => LogStrategy::GetLogs,
                Some(v) => match v {
                    false => LogStrategy::GetLogs,
                    true => LogStrategy::GetTransactions,
                },
            }
        };
        info!("   ... chain client initialised for chain_id {chain_id}, url {0}, with version {maybe_version:?} and strategy {strategy:?}.",
              config.rpc_url.as_str());
        Ok(ChainClient {
            client,
            validator_manager_address,
            chain_gateway_address: config.chain_gateway_address,
            chain_id,
            wallet,
            chain_gateway_block_deployed: config.chain_gateway_block_deployed,
            block_instant_finality: config.block_instant_finality.unwrap_or_default(),
            gas_estimation_percent: config.gas_estimation_percent,
            use_legacy_transactions: config.use_legacy_transactions.unwrap_or(false),
            scan_behind_blocks: config.scan_behind_blocks.unwrap_or_default(),
            log_strategy: strategy,
            to_block_number: config.to_block_number,
            priority_fee_per_gas_max: config.priority_fee_per_gas_max,
            except: exceptions::ExceptionProcessor::new(config, chain_id),
        })
    }
}
pub trait ContractInitializer<T> {
    fn get_contract(&self) -> T;
}

impl ContractInitializer<ValidatorManager<Client>> for ChainClient {
    fn get_contract(&self) -> ValidatorManager<Client> {
        ValidatorManager::new(self.validator_manager_address, self.client.clone())
    }
}

impl ContractInitializer<ChainGateway<Client>> for ChainClient {
    fn get_contract(&self) -> ChainGateway<Client> {
        ChainGateway::new(self.chain_gateway_address, self.client.clone())
    }
}

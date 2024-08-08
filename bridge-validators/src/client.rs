use std::sync::Arc;

use crate::{ChainGateway, ValidatorManager};
use anyhow::Result;
use ethers::{
    middleware::{MiddlewareBuilder, NonceManagerMiddleware, SignerMiddleware},
    providers::{Http, Middleware, Provider},
    signers::{LocalWallet, Signer},
    types::{Address, U256},
};
use std::fmt;
use tracing::info;

use crate::ChainConfig;

pub type Client = NonceManagerMiddleware<SignerMiddleware<Provider<Http>, LocalWallet>>;

// ZQ1 seems to have given up responding to getLogs(), so we now have
// a way to query all transactions on the chain to obtain our logs.
#[derive(Debug, Clone)]
pub enum LogStrategy {
    GetLogs,
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
    pub legacy_gas_estimation_percent: Option<u64>,
    pub scan_behind_blocks: u64,
    pub log_strategy: LogStrategy,
}

impl fmt::Display for ChainClient {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "chainid#{}", self.chain_id)
    }
}

impl ChainClient {
    pub async fn new(config: &ChainConfig, wallet: LocalWallet) -> Result<Self> {
        info!(
            "initialising chain client for URL {0} with gateway {1:#x} ... ",
            config.rpc_url.as_str(),
            config.chain_gateway_address
        );
        let provider = Provider::<Http>::try_from(config.rpc_url.as_str())?;
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
        let strategy = match config.use_get_transactions {
            None => LogStrategy::GetLogs,
            Some(v) => match v {
                false => LogStrategy::GetLogs,
                true => LogStrategy::GetTransactions,
            },
        };
        info!("... success!");
        Ok(ChainClient {
            client,
            validator_manager_address,
            chain_gateway_address: config.chain_gateway_address,
            chain_id,
            wallet,
            chain_gateway_block_deployed: config.chain_gateway_block_deployed,
            block_instant_finality: config.block_instant_finality.unwrap_or_default(),
            legacy_gas_estimation_percent: config.legacy_gas_estimation_percent,
            scan_behind_blocks: config.scan_behind_blocks.unwrap_or_default(),
            log_strategy: strategy,
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

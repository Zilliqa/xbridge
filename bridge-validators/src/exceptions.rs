use ethers::types::Log;

/// The exception processor handles exceptions - these are txns which were issued in error, usually as a result
/// of a bug in the relayer contracts; their parameters are corrected here before being passed on to the rest of
/// the relayer logic for execution.
#[derive(Debug, Clone)]
pub struct ExceptionProcessor {}

impl ExceptionProcessor {
    pub fn new() -> Self {
        ExceptionProcessor {}
    }

    // We'll warn!() if we have to drop a log.
    pub fn transform_log(&self, log: &Log) -> Option<Log> {
        Some(log.clone())
    }
}

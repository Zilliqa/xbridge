import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-scilla-plugin";

const config: HardhatUserConfig = {
  solidity: "0.8.24",
  networks: {
    zq_testnet: {
      url: "https://dev-api.zilliqa.com",
      websocketUrl: "wss://dev-api.zilliqa.com",
      accounts: [
        process.env.PRIVATE_KEY_ZILBRIDGE ],
      chainId: 33101,
      zilliqaNetwork: true,
    },
    zq_testnet_mitmweb: {
      url: "http://localhost:6200",
      websocketUrl: "ws://localhost:6200",
      accounts: [
        process.env.PRIVATE_KEY_ZILBRIDGE ],
      chainId: 33101,
      zilliqaNetwork: true,
    },
  }
};


export default config;

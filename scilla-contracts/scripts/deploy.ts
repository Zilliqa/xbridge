import { ethers, config } from "hardhat";
import { ScillaContract, initZilliqa } from 'hardhat-scilla-plugin';

async function main() {
  const network = config.networks[hre.network.name];
  const privateKeys = network.accounts[0];
  const networkUrl = network.url;
  const chain_id = network.chainId & ~0x8000;
  initZilliqa(networkUrl, chain_id, [ privateKeys ], 40 );
  let account = hre.zilliqa.getDefaultAccount();
  console.log(`Deploying from ${account.address}`);
  const zqTestnetTokenManager = process.env.TOKEN_MANAGER_ADDRESS;
  if (zqTestnetTokenManager === undefined) {
    throw new Error("No TOKEN_MANAGER_ADDRESS");
  }
  let tokenContract = await hre.deployScillaContract("SwitcheoTokenZRC2",  "Bridged-XTST", "XTST",
                                               account.address, 3, 0, zqTestnetTokenManager);
  console.log(`    address public constant zqBridgedERC20Address = address(0x00${tokenContract.address})`);

  let nativeBridgedContract = await hre.deployScillaContract("SwitcheoTokenZRC2",  "Bridged-BNB", "eBNB",
                                               account.address, 18, 0, zqTestnetTokenManager);
  console.log(`    address public constant zqBridgedBNBAddress = address(0x00${nativeBridgedContract.address})`);

  let local = await hre.deployScillaContract("FungibleToken", account.address, "zq_native Test", "ZTST", 3, 1_000_000_000);
  console.log(`    address public constant zqZRC2Address = address(0x00${local.address})`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

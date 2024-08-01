import { ethers, config } from "hardhat";
import { ScillaContract, initZilliqa } from 'hardhat-scilla-plugin';

async function main() {
  const network = config.networks[hre.network.name];
  const privateKeys = network.accounts[0];
  const networkUrl = network.url;
  const chain_id = network.chainId & ~0x8000;
  initZilliqa(networkUrl, chain_id, [ privateKeys ], 40 );
  let account = hre.zilliqa.getDefaultAccount();
  let targetAddress = process.env.ZILBRIDGE_TEST_ADDRESS;
  let testAmount = process.env.ZILBRIDGE_TEST_AMOUNT;
  let tokenContractAddress = process.env.ZILBRIDGE_SCILLA_TOKEN_ADDRESS;
  console.log(`transferring ${testAmount} of ${tokenContractAddress} from ${account.address} to ${targetAddress}`);
  let tokenContract = await hre.interactWithScillaContract(tokenContractAddress);
  let result = await tokenContract.Transfer(targetAddress, testAmount);
  console.log(`result = ${JSON.stringify(result)}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

import { ethers, config } from "hardhat";
import { ScillaContract, initZilliqa } from "hardhat-scilla-plugin";

async function main() {
  const network = config.networks[hre.network.name];
  const privateKeys = network.accounts[0];
  const networkUrl = network.url;
  const chain_id = network.chainId & ~0x8000;
  initZilliqa(networkUrl, chain_id, [privateKeys], 40);
  let account = hre.zilliqa.getDefaultAccount();
  let targetAddress = process.env.TEST_ADDRESS;
  let tokenContractAddress = process.env.SCILLA_TOKEN_ADDRESS;
  let evmContractAddress = process.env.EVM_TOKEN_ADDRESS;
  console.log(`Balance of ${targetAddress} in ${tokenContractAddress} .. `);
  let tokenContract =
    await hre.interactWithScillaContract(tokenContractAddress);
  console.log(`${JSON.stringify(tokenContract)}`);
  console.log(`${JSON.stringify(tokenContract.balances())}`);
  let factory = await ethers.getContractFactory("ZRC2ProxyForZRC2");
  console.log(`factory is ${factory}`);
  const contract = await factory.attach(evmContractAddress);
  console.log("got contract");
  let result = await contract.balanceOf(targetAddress);
  console.log(` .... ${result}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

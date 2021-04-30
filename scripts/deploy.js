// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  // const Greeter = await hre.ethers.getContractFactory("Greeter");
  // const greeter = await Greeter.deploy("Hello, Hardhat!");
  // await greeter.deployed();
  // console.log("Greeter deployed to:", greeter.address);

  // Basic ERC20 Token Contract
  // const ERC20Contract = await hre.ethers.getContractFactory("MyToken");
  // const ERC20ContractDeployment = await ERC20Contract.deploy();
  // await ERC20ContractDeployment.deployed();
  // console.log("ERC20 Contract is Deployed to : ",ERC20ContractDeployment.address);

  // ERC20 Token Factory
  const ERC20ContractFactory = await hre.ethers.getContractFactory("FactoryClone");
  const ERC20ContractFactoryDeployment = await ERC20ContractFactory.deploy();
  await ERC20ContractFactoryDeployment.deployed();
  console.log("ERC20 Factory Contract is Deployed to : ",ERC20ContractFactoryDeployment.address);
  // 0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0
  // 0x61ef99673A65BeE0512b8d1eB1aA656866D24296
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

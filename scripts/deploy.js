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

  // Company Registration Contract Deployment (ERC721)
  const BusinessRegistrationContract = await hre.ethers.getContractFactory("CompanyRegistration");
  const BusinessRegistratioDeployment = await BusinessRegistrationContract.deploy();
  const BusinessRegistration = await BusinessRegistratioDeployment.deployed();
  console.log("Business Registration is Deployed to : ",BusinessRegistration.address);

  // Company Secretary (ERC721) Factory Deployment
  const CompanySecretaryContract = await hre.ethers.getContractFactory("CompanySecretary721FactoryCloneV1");
  const CompanySecretaryContractFactoryDeployment = await CompanySecretaryContract.deploy();
  const CompanySecretaryFactory = await CompanySecretaryContractFactoryDeployment.deployed();
  console.log("Company Secretary Factory Contract is Deployed to : ",CompanySecretaryFactory.address);

  // Company Shares Issuer Factory Deployment
  const SharesIssuerContractFactory = await hre.ethers.getContractFactory("SharesIssuerFactoryCloneV1");
  const SharesIssuerContractFactoryDeployment = await SharesIssuerContractFactory.deploy();
  const SharesIssuerFactory = await SharesIssuerContractFactoryDeployment.deployed();
  console.log("Shares Issuer Factory Contract is Deployed to : ",SharesIssuerFactory.address);

  // Company Board Factory Deployment
  const CompanyBoardContractFactory = await hre.ethers.getContractFactory("CompanyBoardFactoryCloneV1");
  const CompanyBoardContractFactoryDeployment = await CompanyBoardContractFactory.deploy();
  const CompanyBoardFactory = await CompanyBoardContractFactoryDeployment.deployed();
  console.log("Company Board Factory Contract is Deployed to : ",CompanyBoardFactory.address);

  // Business Registration is Deployed to :  0x8E1558B6B8a3ef346d187EABbe9B08C4DdFf336B
  // Company Secretary Factory Contract is Deployed to :  0xA32a509e5f04d43438744a44e33Fb02FC55073ea
  // Shares Issuer Factory Contract is Deployed to :  0x87943Ac856a51d99e3e039Ff1eF976D316f06118
  // Company Board Factory Contract is Deployed to :  0xEaE3e0Be728155C099C3b940462e50c6600E307F

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });

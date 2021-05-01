const { expect } = require("chai");
const hre = require("hardhat");
// describe("Greeter", function() {
//   this.timeout(100000);
//   it("Should return the new greeting once it's changed", async function() {
//     const Greeter = await ethers.getContractFactory("Greeter");
//     const greeter = await Greeter.deploy("Hello, world!");
    
//     await greeter.deployed();
//     expect(await greeter.greet()).to.equal("Hello, world!");

//     await greeter.setGreeting("Hola, mundo!");
//     expect(await greeter.greet()).to.equal("Hola, mundo!");
//   });
// });

describe("Register a new compant", ()=>{
  it("Should return a deployed address",async()=>{
    const accounts = await hre.ethers.getSigners();

    // Company Registration Contract Deployment (ERC721)
    const BusinessRegistrationContract = await hre.ethers.getContractFactory("CompanyRegistration");
    const BusinessRegistratioDeployment = await BusinessRegistrationContract.deploy();
    const BusinessRegistration = await BusinessRegistratioDeployment.deployed();
    console.log("Business Registration is Deployed to : ",BusinessRegistration.address);

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

    // Board of Directors Deployment && Initiate Clone Shares Issuer for this Company Board
    // const CompanyBoardContract = await hre.ethers.getContractFactory("CompanyBoardV1");
    const tx1 = await CompanyBoardFactory.createCompanyBoard(
      [
        accounts[0].address,
        accounts[1].address
      ],
      [1000,2000],
      "Shares",
      "SHARE",
      SharesIssuerFactory.address
    );
    // console.log('TX1 Res : ',tx1);
    const { gasUsed: createGasUsed, events } = await tx1.wait();
    console.log(events);
    const { address } = events.find(Boolean);
    console.log(`Gas Used : ${createGasUsed.toString()}`);

    // Mint by Contract Owner (OnChain Limited)
    const tx2 = await BusinessRegistration.mint(accounts[0].address);
    console.log('TX2 Res : ',tx2);
    
    const thisCompanyBoard = await ethers.getContractFactory('CompanyBoardV1');
    const companyBoardInstance = new ethers.Contract(address, thisCompanyBoard.interface, accounts[0]);
    const sharesIssuerAddress = await companyBoardInstance.sharesIssuerAddress();
    console.log('Share Issuer Address : ',sharesIssuerAddress);

    // console.log('Share Issuer Address : ',CompanyBoardFactory.getSharesIssuerAddress());
    // const CompanyBoard = await CompanyBoardContractDeployment.deployed();
    // console.log("CompanyBoard is Deployed to : ",CompanyBoard.address);

    // const tx1 = await ERC20Factory.createToken("Shares","SHARE",CompanyBoard.address);
    // console.log('Create Token Res : ',tx1);
    // const { gasUsed: createGasUsed, events } = await tx1.wait();
    // const { address } = events.find(Boolean);
    // console.log(`Gas Used : ${createGasUsed.toString()}`);
    // console.log(`Share Issuer Address : ${address}`);
    // const ERC20UpgradeableContract = await hre.ethers.getContractFactory("ERC20Mint");

    // Set Share Issuer in the Company Board
    // const tx2 = await CompanyBoard.setShareIssuer(address);
    // console.log('TX2 Res : ',tx2);

    // Initial Shares Issue
    // const tx3 = await CompanyBoard.initSharesIssue();
    // console.log('TX3 Res : ',tx3);

    let { interface } = await ethers.getContractFactory('SharesIssuerV1');
    const instance = new ethers.Contract(sharesIssuerAddress, interface, accounts[0]);
    console.log("Account balance:", (await instance.balanceOf(accounts[0].address)).toString());
    console.log("Account balance:", (await instance.balanceOf(accounts[1].address)).toString());
    
    // const tx3 = await CompanyBoard.initSharesIssue(address);
    // console.log('TX3 Res : ',tx3);
    // const { gasUsed: createGasUsed, events } = await tx2.wait();
    // const { interface } = await ethers.getContractFactory('ERC20Mint');
    // const instance = new ethers.Contract(address, interface, accounts[0]);

    // const tx4 = await CompanyBoard.getVotingWeight(accounts[0].address,address);
    // console.log('TX4 Res : ',tx4.toString()/1000);
    // const tx5 = await CompanyBoard.getVotingWeight(accounts[1].address,address);
    // console.log('TX5 Res : ',tx5.toString()/1000);

  });
});

// describe("Deploy ERC Factory",()=>{
//     it("Should return a deployed address",async()=>{

//       // Deploy ERC20 Clone Factory
//       // const ERC20ContractFactory = await hre.ethers.getContractFactory("FactoryClone");
//       // const ERC20ContractFactoryDeployment = await ERC20ContractFactory.deploy();
//       // const ERC20Factory = await ERC20ContractFactoryDeployment.deployed();
//       // console.log("ERC20 Factory Contract is Deployed to : ",ERC20Factory.address);

//       // const accounts = await hre.ethers.getSigners();
//       // console.log('Accounts',accounts[0].address);

//       // const tx1 = await ERC20Factory.createToken("TestToken","Test",accounts[0].address);
//       // // console.log('Create Token Res : ',tx1);
//       // const { gasUsed: createGasUsed, events } = await tx1.wait();
//       // const { address } = events.find(Boolean);
//       // console.log(`Gas Used : ${createGasUsed.toString()}`);
//       // // const ERC20UpgradeableContract = await hre.ethers.getContractFactory("ERC20Mint");

//       // const { interface } = await ethers.getContractFactory('ERC20Mint');
//       // const instance = new ethers.Contract(address, interface, accounts[0]);

//       // const tx2 = await instance.getRoleMember(instance.MINTER_ROLE(),0);
//       // console.log('Contract Owner / Minter',tx2);
//       // const tx3 = await instance.getRoleMember(instance.MINTER_ROLE(),1);
//       // console.log('Contract Owner / Minter',tx3);
//       // // const tx2 = await instance.grantRole(instance.MINTER_ROLE(), accounts[0].address);
//       // // console.log('Grant Role Res : ',tx2);
//       // const tx4 = await instance.mint(accounts[0].address, 100);
//       // const { gasUsed: mintGasUsed } = await tx4.wait();
//       // console.log(`ERC20.Mint: ${mintGasUsed.toString()}`);

//       // console.log("Account balance:", (await instance.balanceOf(accounts[0].address)).toString());

//     });
// });
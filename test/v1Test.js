const { expect } = require("chai");
const hre = require("hardhat");

describe("Register a new company", ()=>{
  it("Should return a deployed address",async()=>{
    // Get Network Accounts
    const accounts = await hre.ethers.getSigners();

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

    // Deploy a Shared Secretary
    const tx0 = await CompanySecretaryFactory.createCompanySecretary(
      "CompanySecretary",
      "CR",
      "https://kios.tech",
      accounts[0].address
    );
    const tx0Res = await tx0.wait();
    const sharedCompanySecretaryAddress = tx0Res.events.find(Boolean).address;
    console.log(`Gas Used : ${tx0Res.gasUsed.toString()}`);
    console.log('Shared Company Secretary Deployed Address',sharedCompanySecretaryAddress);

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

    // Create a Business Registration
    const tx2 = await BusinessRegistration.mint(accounts[0].address);
    // console.log('TX2 Res : ',tx2);

    // Board of Directors Deployment && Initiate Clone Shares Issuer for this Company Board && Mint Shares
    const tx1 = await CompanyBoardFactory.createCompanyBoard(
      [
        accounts[0].address,
        accounts[1].address
      ],
      [1000,2000],
      "Shares",
      "SHARE",
      SharesIssuerFactory.address,
      accounts[0].address
    );
    // console.log('TX1 Res : ',tx1);
    const { gasUsed: createGasUsed, events } = await tx1.wait();
    const { address } = events.find(Boolean);
    console.log(`Gas Used : ${createGasUsed.toString()}`);
    console.log('Company Board Address : ',address);

    // Transfer the Business Registratin Certificate to the Board
    const tx13 = await BusinessRegistration.transferFrom(accounts[0].address,address,0);
    const { gasUsed: createGasUsedTx13 } = await tx13.wait();
    console.log('Gas Used : ',createGasUsedTx13.toString());
    const tx14 = await BusinessRegistration.ownerOf(0);
    console.log('Company Board now owned the Business Registration Certificates : ',tx14.toString());

    // Check Whether Balance is Correct or Not
    const thisCompanyBoard = await ethers.getContractFactory('CompanyBoardV1');
    const companyBoardInstance = new ethers.Contract(address, thisCompanyBoard.interface, accounts[0]);
    const sharesIssuerAddress = await companyBoardInstance.sharesIssuerAddress();
    console.log('Share Issuer Address : ',sharesIssuerAddress);
    let { interface } = await ethers.getContractFactory('SharesIssuerV1');
    const instance = new ethers.Contract(sharesIssuerAddress, interface, accounts[0]);
    console.log("Account balance:", (await instance.balanceOf(accounts[0].address)).toString());
    console.log("Account balance:", (await instance.balanceOf(accounts[1].address)).toString());

    const tx12 = await companyBoardInstance.companyType();
    console.log('Company Type Before Voting for a Proposal',tx12.toString());

    // Initiate a Proposal
    const thisCompanySecrectary = await ethers.getContractFactory('CompanySecretary721V1');
    const companySecrectaryInstance = new ethers.Contract(sharedCompanySecretaryAddress, thisCompanySecrectary.interface, accounts[0]);
    const tx3 = await companySecrectaryInstance.mint(address);
    // console.log(tx3);
    // const tx3Res = await tx3.wait();
    // console.log(tx3Res.events);
    const tx4 = await companySecrectaryInstance.balanceOf(address);
    const tx5 = await companySecrectaryInstance.tokenOfOwnerByIndex(address,tx4.toString()-1);
    console.log('Latest Proposal Token Id :',tx5.toString());
    const tx6 = await companyBoardInstance.initProposal(tx5.toString(), sharedCompanySecretaryAddress, 2, 3, 50, 1, 2);
    // Change the company Type to a Public Company
    const { gasUsed: createGasUsedTx6 } = await tx6.wait();
    console.log('Gas Used : ',createGasUsedTx6.toString());

    // Vote for a Proposal By Address 0
    const tx7 = await companyBoardInstance.vote(tx5.toString(),sharedCompanySecretaryAddress,0);
    const { gasUsed: createGasUsedTx7 } = await tx7.wait();
    console.log('Gas Used : ',createGasUsedTx7.toString());

    // Check Vote Count
    const tx8 = await companyBoardInstance.proposalResult(tx5.toString(),sharedCompanySecretaryAddress);
    console.log('Vote Count : ',tx8.toString());

    // Vote for a Proposal By Address 1
    const companyBoardInstance1 = new ethers.Contract(address, thisCompanyBoard.interface, accounts[1]);
    const tx9 = await companyBoardInstance1.vote(tx5.toString(),sharedCompanySecretaryAddress,0);
    const { gasUsed: createGasUsedTx9 } = await tx9.wait();
    console.log('Gas Used : ',createGasUsedTx9.toString());

    // Check Vote Count
    const tx10 = await companyBoardInstance1.proposalResult(tx5.toString(),sharedCompanySecretaryAddress);
    console.log('Vote Count : ',tx10.toString());
    // console.log('Vote Status : ',tx10.status.toString());

    // Get Execute Result
    const tx11 = await companyBoardInstance.companyType();
    console.log('Company Type After Voting for a Proposal',tx11.toString());

    // Check Proposal Result
    // const tx11 = await companyBoardInstance.endProposal(tx5.toString(),sharedCompanySecretaryAddress);
    // const { gasUsed: createGasUsedTx11 } = await tx11.wait();
    // console.log('Gas Used : ',createGasUsedTx11.toString());


    // const tx4 = await companySecrectaryInstance.mint(accounts[2].address);
    // // console.log(tx3);
    // const tx4Res = await tx4.wait();
    // // console.log(tx4Res.events);

    // const tx7 = await companySecrectaryInstance.mint(address);
    // const tx7Res = await tx7.wait();

    // const tx5 = await companySecrectaryInstance.balanceOf(address);
    // console.log(tx5.toString());

    // const tx6 = await companySecrectaryInstance.balanceOf(accounts[2].address);
    // console.log(tx6.toString());

    // const tx9 = await companySecrectaryInstance.tokenOfOwnerByIndex(address,tx5.toString()-1);
    // console.log(tx9.toString());

    // const tx10 = await companySecrectaryInstance.tokenOfOwnerByIndex(address,tx5.toString()-2);
    // console.log(tx10.toString());

    // const tx8 = await companySecrectaryInstance.totalSupply();
    // console.log(tx8.toString());

    // const tx6 = await companySecrectaryInstance.tokenOfOwnerByIndex(address,0);
    // console.log(tx6.toString());
    // const tx7 = await companySecrectaryInstance.tokenOfOwnerByIndex(address,1);
    // console.log(tx7.toString());
    


  });
});
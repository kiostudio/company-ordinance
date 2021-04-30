require("@nomiclabs/hardhat-waffle");
require('dotenv').config();
require("hardhat-gas-reporter");

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async () => {
  const accounts = await ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    version : "0.8.0",
    settings: {
      optimizer: {
        enabled: true
      }
    }
  },
  defaultNetwork: "local",
  networks: {
    local: {
      url: "http://127.0.0.1:8545",
      accounts: ["0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"],
    },
    ropsten: {
      url: "https://ropsten.infura.io/v3/"+process.env.INFURA_KEY,
      accounts: [process.env.ROPSTEN_ACCOUNT]
    }
  },
  gasReporter : {
    enabled : true
  }
};


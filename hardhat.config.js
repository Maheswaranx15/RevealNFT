require("dotenv").config();

require("@nomiclabs/hardhat-etherscan");
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-web3");
require("hardhat-gas-reporter");
require("solidity-coverage");

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.18",
      },
    ],
  },
  networks: {
    matic: {
      url: "",
      accounts: [""],
    }
  },
  etherscan: {
    apiKey: {
      polygonMumbai: ""
    }
  }
};
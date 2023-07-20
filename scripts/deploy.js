// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require("fs");

async function main() {

  const nft1155tokenName = "NexityNFT721";
  const nft1155tokenSymbol = "NFT1155";
  const tokenURIPrefix = "https://gateway.pinata.cloud/ipfs/";

  const Trade = await hre.ethers.getContractFactory("Trade");
  const trade = await Trade.deploy();
  await trade.deployed();

  const NFT = await hre.ethers.getContractFactory("NFT1155");
  const nft = await NFT.deploy(nft1155tokenName,nft1155tokenSymbol,tokenURIPrefix,tradeinstance.address);
  await nft.deployed();


  console.log(
    ` Trade contract deployment address`, trade.address
  );

  console.log(
    ` NFT contract deployment address`, trade.address
  );


  const NFTData = {
    address: nft.address,
    abi: JSON.parse(nft.interface.format('json'))
  }

  fs.writeFileSync('./NFTData.json', JSON.stringify(NFTData))


  const TradeData = {
    address: trade.address,
    abi: JSON.parse(trade.interface.format('json'))
  }

  fs.writeFileSync('./TradeData.json', JSON.stringify(TradeData))

  //Verify the smart contract using hardhat 
  await hre.run("verify:verify", {
    address: nft.address,
  });

  await hre.run("verify:verify", {
    address: contest.address,
    constructorArguments: [nft1155tokenName,nft1155tokenSymbol,tokenURIPrefix,tradeinstance.address],
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
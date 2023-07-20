const { expect } = require("chai");
const { ethers } = require("hardhat");
const {
  BN,           // Big Number support
  constants,    // Common constants, like the zero address and largest integers
  expectEvent,  // Assertions for emitted events
  expectRevert, // Assertions for transactions that should fail
} = require('@openzeppelin/test-helpers');
require("@nomiclabs/hardhat-truffle5");



describe("NFT1155", function () {
  var nft1155instance;
  var tradeinstance;
  it("Contract Deployment", async function () {
    const nft1155tokenName = "NexityNFT721";
    const nft1155tokenSymbol = "NFT1155";
    const tokenURIPrefix = "https://gateway.pinata.cloud/ipfs/";
    const Trade = await ethers.getContractFactory("Trade");
    tradeinstance = await Trade.deploy();
    await tradeinstance.deployed();

    const NFT1155 = await ethers.getContractFactory("NFT1155");
    nft1155instance = await NFT1155.deploy(nft1155tokenName,nft1155tokenSymbol,tokenURIPrefix,tradeinstance.address);
    await nft1155instance.deployed();

    console.log(`Trade`,tradeinstance.address);
  })

  it(`Adding NFT Address to Miniting contract`,async ()=>{
    await tradeinstance.updateNFTAddress(nft1155instance.address)
  })

  it(`mintFunctionality and Checking TokenURI is Revealed or not`,async()=>{
    let seed = 1
    const NftAmount = "1000000000000000000"
    let mint = await tradeinstance.mint(seed, {value:NftAmount})
    const receipt = await mint.wait()
    let tokenID = receipt.events[1].args[1]
    console.log(`TokeID Randomly Generated`,Number(tokenID));
    console.log(`NFT is not Revealed`,await nft1155instance.uri(tokenID));
    await nft1155instance.revealNFT()
    console.log(`NFT is Revealed`,await nft1155instance.uri(tokenID));
  })


})
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("Mini Market", function () {

  before(async function () {
    [owner, addr1] = await ethers.getSigners();
    const Market = await ethers.getContractFactory("marketERC1155");
    market = await Market.deploy();
    await market.deployed();
  });
  
  it("Is owned by the deployer", async function () {
    expect(await market.isOwner(owner.address)).to.equal(true);
  });

  it("Can list a new NFT", async function () {
    await market.newListing(01);
    expect(await market.assetOwner(owner.address,01)).to.equal(true);
  });

  it("Has an inceased totalAssets after new listing", async function () {
    expect(await market.totalAssets()).to.equal(1);
  });

  it("Can be purchased by consumer wallet", async function () {
    await market.connect(addr1).buyAsset(01);
    expect(await market.assetOwner(owner.address,01)).to.equal(true);
  });

});
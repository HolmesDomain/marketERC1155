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

  it("There are no existing assets on the marketplace", async function () {
    expect(await market.totalAssets()).to.equal(0);
  });

  it("Cannot officially list a new NFT without approval", async function () {
    await expect(market.newListing(01,10)).to.be.revertedWith("Pending admin approval for listing");
  });

  it("Staging asset listing event", async function () {
    expect(await market.stageListing(01));
  });

  it("Approves specified Asset id", async function () {
    expect(await market.approveListing(01));
  });

  it("Can list 10 new NFT/assets owned by admin wallet", async function () {
    await market.newListing(01,10);
    expect(await market.assetOwner(owner.address,01)).to.equal(true);
  });

  it("Has an inceased totalAssets after new listing", async function () {
    expect(await market.totalAssets()).to.equal(10);
  });

  it("4 assets can be purchased/transfered from the admin to owner wallet", async function () {
    await market.transferAsset(01,owner.address,addr1.address,4);
    expect(await market.assetOwner(addr1.address,01)).to.equal(true);
  });

  it("BalanceOf admin wallet|consumer wallet will be 6|4", async function () {
    expect(await market.balanceOf(owner.address,01)).to.equal(6);
    expect(await market.balanceOf(addr1.address,01)).to.equal(4);
  });

  describe("Listings", async function () {
    it("Can be cancelled", async function () {
      await market.connect(addr1).stageListing(02);
      await market.connect(addr1).cancelListing(02);
      await expect(market.connect(addr1).newListing(02,10)).to.be.reverted;
    });
  });
});

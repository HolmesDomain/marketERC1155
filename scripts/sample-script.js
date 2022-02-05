const hre = require("hardhat");

async function main() {
  const Market = await hre.ethers.getContractFactory("marketERC1155");
  const market = await Market.deploy();

  await market.deployed();

  console.log("Market is deployed to:", market.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

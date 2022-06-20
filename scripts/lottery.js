const { ethers, upgrades } = require("hardhat");

async function main() {
  const Lottery = await ethers.getContractFactory("Lottery");
  const lottery = await upgrades.deployProxy(Lottery, ["Simple Lottery", "LOT"], {
    initializer: "initialize",
  });
  await lottery.deployed();
  console.log("Lottery deployed to:", lottery.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

const { ethers, upgrades } = require("hardhat");

async function main() {
  const existingLotteryContractAdddress = "0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0";

  const LotteryV2 = await ethers.getContractFactory("LotteryV2");
  await upgrades.upgradeProxy(existingLotteryContractAdddress, LotteryV2);
  console.log("Lottery upgraded");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

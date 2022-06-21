require("@nomiclabs/hardhat-waffle");
require('@openzeppelin/hardhat-upgrades');

task("accounts", "Prints the list of accounts", async (_, { ethers }) => {
  await ethers.provider.getBlockNumber().then((blockNumber) => {
    console.log("Current block number: " + blockNumber);
  });

  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

module.exports = {
  solidity: "0.8.4"
};

const { expect } = require("chai");

describe("Lottery", () => {
  it("Should return the new greeting once it's changed", async() => {
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy("Simple Lottery", "LOT");
    await lottery.deployed();

    expect(await lottery.getBalance()).to.equal(0);
  });
});

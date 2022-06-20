const { expect } = require("chai");

describe("Lottery", () => {
  it("Should return the new greeting once it's changed", async() => {
    const Lottery = await ethers.getContractFactory("Lottery");
    const lottery = await Lottery.deploy("Simple Lottery", "LOT");
    await lottery.deployed();

    expect(await lottery.getBalance()).to.equal(0);
  });
});

it('works before and after upgrading', async function () {
  const instance = await upgrades.deployProxy(Lottery, [42]);
  assert.strictEqual(await instance.retrieve(), 42);

  await upgrades.upgradeProxy(instance.address, BoxV2);
  assert.strictEqual(await instance.retrieve(), 42);
});

describe("Upgradeable", function() {
  it('works', async () => {
    const Box = await ethers.getContractFactory("Box");
    const BoxV2 = await ethers.getContractFactory("BoxV2");
  
    const instance = await upgrades.deployProxy(Box, [42]);
    const upgraded = await upgrades.upgradeProxy(instance.address, BoxV2);

    const value = await upgraded.value();
    expect(value.toString()).to.equal('42');
  });
});
const { expect } = require("chai");

const etherToWei = (ether) => {
  return ethers.utils.parseEther(`${ether}`);
}

const formatRevertReason = (revertReason) => {
  return `VM Exception while processing transaction: reverted with reason string '${revertReason}'`;
}

describe("Lottery Contract", () => {
  let Lottery, contract, owner, address1, address2;
  const tokenName = "Simple Lottery";
  const tokenSymbol = "LOT";

  before(async () => {
    Lottery = await ethers.getContractFactory('Lottery');
    contract = await upgrades.deployProxy(Lottery, [tokenName, tokenSymbol], {
      initializer: "initialize",
    });
    await contract.deployed();
    [owner, address1, address2, _] = await ethers.getSigners();
  });

  describe('DEPLOYMENT', () => {
    it('Should set the right owner', async () => {
      expect(await contract.owner()).to.equal(owner.address);
    });

    it('Should set the right name', async () => {
      expect(await contract.name()).to.equal(tokenName);
    });

    it('Should set the right symbol', async () => {
      expect(await contract.symbol()).to.equal(tokenSymbol);
    });

    it('Should set the right balance', async () => {
      expect(await contract.getBalance()).to.equal(0);
    });
  });

  describe('Buy ticket', () => {
    it('Should successfully buy ticket', async () => {
      expect(await contract.getBalance()).to.equal(0);
      await contract
        .connect(address1)
        .buyTicket({ value: etherToWei(1) })
      expect(await contract.getBalance()).to.equal(etherToWei(1));
    });

    it('Should successfully mint ticket and emit event', async () => {
      await expect(
        contract
          .connect(address2)
          .buyTicket({ value: etherToWei(1) })
      )
        .to.emit(contract, "BuyTicket");
    });

    it('Should have the right amount of players', async () => {
      expect(await contract.getPlayerCount()).to.equal(2);
    });
    
    it('Should successfully set the correct tokenURI', async () => {
      expect(
          await contract
            .tokenURI(1)
      ).to.equal("https://ipfs.io/ipfs/QmQKfi3xnGjDkFvYR9EQDP67BGWJvqqFNUPfvQxTdqXPWS?filename=metadata.json");
    })
  });

  describe('Pick winner', () => {
    it('Should not allow non-owner to trigger pick winner', async () => {
      try { // using try-catch for revertReason due to this issue https://github.com/NomicFoundation/hardhat/issues/2234
        await contract
          .connect(address1)
          .pickWinner();
      }
      catch (error) {
        expect(error.message).to.equal(formatRevertReason('Ownable: caller is not the owner'));
      }
    });
  });

  describe('Upgradeable Contract', () => {
    it('Should upgrade contract and return getBalance + 5 from the upgraded contract', async () => {
      const originalBalance = await contract.getBalance();

      expect(
        originalBalance
      ).to.equal(etherToWei(2));

      const existingLotteryContractAdddress = contract.address;

      const LotteryV2 = await ethers.getContractFactory("LotteryV2");
      const lotteryv2 = await upgrades.upgradeProxy(existingLotteryContractAdddress, LotteryV2);
      
      const balanceFromUpgradedContract = await lotteryv2.getBalance();

      expect(
        balanceFromUpgradedContract
      ).to.equal(originalBalance.add(5));
    });
  });

});
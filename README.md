# NFT Lottery Game

NFT Lottery on a Hardhat environment https://hardhat.org.
Users are able to buy a ticket which is an actual NFT. The funds from each ticket purchase are gathered in a prize pool. After a certain period of time a random winner is chosen.


Running the following in one terminal:

```shell
npx hardhat node
```

And the following in a second terminal:

```shell
npx hardhat run scripts/lottery.js --network localhost
```

If you'd like to test the upgradeable proxy contract run:
(*the address of the already deployed proxy should be pasted in the scripts/lottery_v2.js file)

```shell
npx hardhat run scripts/lottery_v2.js --network localhost
```

Execute tests using:

```shell
npx hardhat test
```
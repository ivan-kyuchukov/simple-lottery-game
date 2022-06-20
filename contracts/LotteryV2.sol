// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LotteryV2 is ERC721URIStorageUpgradeable, OwnableUpgradeable {

    using Counters for Counters.Counter;
    Counters.Counter private ticketIds;
    
    uint private PRICE_PERCENTAGE;
    uint256 private LOTTERY_ENTRANCE_ETHER;
    uint private LOTTERY_OPEN_DURATION_IN_BLOCKS;

    error LotteryOwnerCannotPlay();
    error LotteryExactEntranceAmountRequired();
    error LotteryNotOpen();
    error LotteryEnded();
    error LotteryStillOngoing();
    error LotteryNotEnoughPlayers();

    enum LotteryState {
        Open,
        PickingWinner
    }

    event BuyTicket(address buyer, uint256 ticketId);
    event PickWinner(address winner, uint priceAmount);

    LotteryState private lotteryState;
    uint private currentLotteryStartAt;

    address payable[] public players;

    // constructor (string memory name, string memory symbol) ERC721(name, symbol) {
    //     currentLotteryStartAt = block.number; // This can also be set to, for example, some hours/days from 'now'
    // }

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC721_init(name, symbol);
        currentLotteryStartAt = block.number;

        PRICE_PERCENTAGE = 50;
        LOTTERY_ENTRANCE_ETHER = 1 ether;
        LOTTERY_OPEN_DURATION_IN_BLOCKS = 5;
        lotteryState = LotteryState.Open;
    }
    
    function buyTicket() external payable {
        console.log("currentLotteryStartAt:", currentLotteryStartAt);
        console.log("block.number:", block.number);
        
        if (msg.sender == owner()) revert LotteryOwnerCannotPlay(); // using revert instead of require -> gas optimization
        if (msg.value != LOTTERY_ENTRANCE_ETHER) revert LotteryExactEntranceAmountRequired();
        if (lotteryState != LotteryState.Open) revert LotteryNotOpen();
        if (currentLotteryEnded()) revert LotteryEnded();

        uint256 newTicketId = ticketIds.current();
        ticketIds.increment();

        _safeMint(payable(msg.sender), newTicketId);
        _setTokenURI(newTicketId, ""); // TODO: implement tokenURI
        
        players.push(payable(msg.sender));

        emit BuyTicket(msg.sender, newTicketId);
    }
    
    function getBalance() public view returns(uint) {
        console.log("currentLotteryStartAt:", currentLotteryStartAt);
        console.log("block.number:", block.number);
        return 10;
    }
    
    function random() internal view returns(uint) { // TODO: random always returns second player, fix!
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function currentLotteryEnded() internal view returns (bool) {
        return block.number > currentLotteryStartAt + LOTTERY_OPEN_DURATION_IN_BLOCKS;
    }

    function currentLotteryOngoing() internal view returns (bool) {
        return block.number <= currentLotteryStartAt + LOTTERY_OPEN_DURATION_IN_BLOCKS;
    }
    
    function pickWinner() external onlyOwner {
        if (players.length < 2) revert LotteryNotEnoughPlayers();
        if (currentLotteryOngoing()) revert LotteryStillOngoing();
        
        lotteryState = LotteryState.PickingWinner;
        address payable winner;
        winner = players[random() % players.length];
        console.log("winner", winner);

        uint priceAmount = (getBalance() * PRICE_PERCENTAGE) / 100;
        console.log("price amount", priceAmount);
        winner.transfer(priceAmount);

        emit PickWinner(winner, priceAmount);
        
        resetLottery();
    }
    
    function resetLottery() internal {
        players = new address payable[](0);
        currentLotteryStartAt = block.number;
        lotteryState = LotteryState.Open;
    }
}
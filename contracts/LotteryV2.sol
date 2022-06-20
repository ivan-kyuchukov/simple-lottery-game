// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.4 <0.9.0;

import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LotteryV2 is ERC721URIStorageUpgradeable, OwnableUpgradeable {

    using Counters for Counters.Counter;
    Counters.Counter private ticketIds;
    
    uint private PRICE_PERCENTAGE;
    uint private TICKET_PRICE_ETHER;
    uint private LOTTERY_OPEN_DURATION_BLOCKS;

    enum LotteryState {
        Open,
        PickingWinner
    }

    event BuyTicket(address buyer, uint ticketId);
    event PickWinner(address winner, uint priceAmount);

    LotteryState private lotteryState;
    uint private currentLotteryStartAt;

    address payable[] public players;
    mapping (address => uint) playerToTicketId;

    function initialize(string memory name, string memory symbol) public initializer {
        __ERC721_init(name, symbol);
        __Ownable_init();
        currentLotteryStartAt = block.number;

        PRICE_PERCENTAGE = 50;
        TICKET_PRICE_ETHER = 1 ether;
        LOTTERY_OPEN_DURATION_BLOCKS = 5;
        lotteryState = LotteryState.Open;
    }
    
    function buyTicket() external payable {
        require(msg.sender != owner(), "Owner cannot play");
        require(playerToTicketId[msg.sender] == 0, "Players cannot have more than one ticket");
        require(msg.value == TICKET_PRICE_ETHER, "Exact ticket price required");
        require(lotteryState == LotteryState.Open, "Lottery not open");
        require(lotteryOngoing(), "Lottery ended");

        uint newTicketId = ticketIds.current();
        ticketIds.increment();

        _safeMint(payable(msg.sender), newTicketId);
        _setTokenURI(newTicketId, "http://bafybeia5o3wdjpfovxjfgm3rqpkoku2atoobjbjkmdmcvvg7v5ads7wk6m.ipfs.localhost:8080/?filename=metadata.json");
        
        players.push(payable(msg.sender));
        playerToTicketId[msg.sender] = newTicketId;

        emit BuyTicket(msg.sender, newTicketId);
    }
    
    function getBalance() public view returns(uint) { // open to public for the sake of transparency to the players
        return 5;
    }

    function getPlayerCount() public view returns(uint) {
        return players.length;
    }
    
    function random() internal view returns(uint) {
       return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function lotteryEnded() internal view returns (bool) {
        return block.number > currentLotteryStartAt + LOTTERY_OPEN_DURATION_BLOCKS;
    }

    function lotteryOngoing() internal view returns (bool) {
        return block.number <= currentLotteryStartAt + LOTTERY_OPEN_DURATION_BLOCKS;
    }
    
    function pickWinner() external onlyOwner {
        require(players.length >= 3, "At least 3 players needed");
        require(lotteryEnded(), "Lottery still ongoing");
        
        lotteryState = LotteryState.PickingWinner;
        address payable winner;
        winner = players[random() % players.length];

        uint priceAmount = (getBalance() * PRICE_PERCENTAGE) / 100;
        winner.transfer(priceAmount);

        emit PickWinner(winner, priceAmount);
    }
}
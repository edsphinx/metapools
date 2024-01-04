// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "hardhat/console.sol";

contract SportsBetting {
    address public owner;
    uint public minimumBet;
    uint public numberOfPossibleOutcomes;

    struct Bet {
        uint amount;
        uint odds; // Represented as a multiplier with 2 decimal places (e.g., 150 for 1.5x)
        uint selectedOutcome; // Add this field to store the selected outcome
        bool isSettled;
        bool isWinner;
    }

    struct Event {
        string name;
        bool isFinished;
        uint winningOutcome;
        mapping(uint => uint) betsCount; // Tracks the number of bets for each outcome
        mapping(address => Bet) bets;
    }

    // Structure to hold details of each received Ether transaction
    struct EtherTransaction {
        address sender;
        uint amount;
        uint timestamp;
    }

    // Array to store all received Ether transactions
    EtherTransaction[] public receivedTransactions;

    // Variable to track the total amount of Ether received
    uint public totalReceivedEther;

    mapping(uint => Event) public events;
    uint public eventCount;

    constructor(uint _minimumBet) {
        owner = msg.sender;
        minimumBet = _minimumBet;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function addEvent(string memory eventName) public onlyOwner {
        // Increment the eventCount first
        uint currentEventId = eventCount++;

        // Initialize the Event struct in place
        Event storage newEvent = events[currentEventId];
        newEvent.name = eventName;
        newEvent.isFinished = false;
        newEvent.winningOutcome = 2; // Assuming 2 represents an unset or default state
    }

    function placeBet(uint eventId, uint selectedOutcome) public payable {
        require(msg.value >= minimumBet, "Bet does not meet minimum bet requirement.");
        require(eventId < eventCount, "Event does not exist.");
        require(!events[eventId].isFinished, "Event is already finished.");

        Event storage event_ = events[eventId];
        require(event_.bets[msg.sender].amount == 0, "Bet already placed.");

        event_.betsCount[selectedOutcome] += 1; // Increment the bet count for the selected outcome
        uint odds = calculateOdds(eventId, selectedOutcome);
        event_.bets[msg.sender] = Bet({
            amount: msg.value,
            odds: odds,
            selectedOutcome: selectedOutcome, // Set the selected outcome
            isSettled: false,
            isWinner: false
        });
    }

    function calculateOdds(uint eventId, uint selectedOutcome) private view returns (uint) {
        Event storage event_ = events[eventId];
        
        // Calculate total bets on all outcomes
        uint totalBets = 0;
        for (uint i = 0; i < numberOfPossibleOutcomes; i++) {
            totalBets += event_.betsCount[i];
        }

        // Avoid division by zero
        if (totalBets == 0) {
            return 100; // Return even odds if no bets are placed yet
        }

        // Calculate odds based on the proportion of bets on the selected outcome
        // This is a simplistic formula and should be refined for real-world use
        uint odds = 100 * totalBets / event_.betsCount[selectedOutcome];

        return odds;
    }


    function settleEvent(uint eventId, uint winningOutcome) public onlyOwner {
        require(eventId < eventCount, "Event does not exist.");
        Event storage event_ = events[eventId];
        require(!event_.isFinished, "Event is already settled.");

        event_.isFinished = true;
        event_.winningOutcome = winningOutcome;
    }

    function claimWinnings(uint eventId) public {
        Event storage event_ = events[eventId];
        require(event_.isFinished, "Event is not yet settled.");
        Bet storage bet = event_.bets[msg.sender];
        require(bet.amount > 0, "No bet placed.");
        require(!bet.isSettled, "Winnings already claimed.");

        bet.isSettled = true;
        if (event_.winningOutcome == bet.selectedOutcome) {
            bet.isWinner = true;
            uint payout = bet.amount * bet.odds / 100;
            payable(msg.sender).transfer(payout);
        }
    }

    function getEventData(uint eventId) public view returns (string memory name, bool isFinished, uint winningOutcome) {
        Event storage event_ = events[eventId];
        return (event_.name, event_.isFinished, event_.winningOutcome);
    }

    function getBetData(uint eventId, address bettor) public view returns (uint amount, uint odds, uint selectedOutcome, bool isSettled, bool isWinner) {
        Bet storage bet = events[eventId].bets[bettor];
        return (bet.amount, bet.odds, bet.selectedOutcome, bet.isSettled, bet.isWinner);
    }

    // Additional functions like withdrawFunds, updateMinimumBet, etc., would be added here.

    // Fallback function to accept incoming ETH

    // The receive function is triggered when Ether is sent to the contract without data
    receive() external payable {
        // Update the total received Ether
        totalReceivedEther += msg.value;

        // Record the transaction details
        receivedTransactions.push(EtherTransaction({
            sender: msg.sender,
            amount: msg.value,
            timestamp: block.timestamp // Current block timestamp
        }));

        // Emit an event for the received Ether
        emit Received(msg.sender, msg.value);
    }

    // The fallback function is triggered when Ether is sent to the contract with data
    // or if no other function matches the call
    fallback() external payable {
        // Handle the incoming Ether or call
        // Typically, you might just want to revert or log the event
        // Reverting is a safer default action if you don't expect to receive such calls
        revert("Fallback not allowed");
    }

    // Event to log received Ether
    event Received(address sender, uint amount);
}

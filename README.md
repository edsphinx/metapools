# SportsBetting Contract Interaction Guide

The `SportsBetting` contract allows users to place bets on sports events, calculate odds, and settle events. This guide will walk you through the process of interacting with the contract using Etherscan.

## Prerequisites

- Access to Etherscan with the contract deployed.
- A web3-enabled browser or an Ethereum wallet like MetaMask.
- Some ETH in your wallet for transactions.

## Steps to Interact with the Contract

### 1. Adding a New Event

To create a new betting event:

1. Go to the Etherscan page of the `SportsBetting` contract.
2. Connect your wallet by clicking on the “Connect to Web3” button.
3. Navigate to the “Write Contract” tab.
4. Find the `addEvent` function in the list.
5. Enter the name of the event in the `eventName` field.
   - Example: `"Soccer Match 1"`
6. Confirm and sign the transaction in your wallet.

### 2. Placing Bets

To place a bet on an event:

1. Ensure you are still connected to your wallet.
2. Under the “Write Contract” tab, locate the `placeBet` function.
3. Enter the `eventId` of the event you want to bet on. This is typically the index of the event.
   - Example: `0` for the first event
4. Enter the `selectedOutcome`.
   - Example: `0` for Team X,`1` for Team Y, `2` for a draw
5. Specify the bet amount in the transaction value field (ensure this is in Wei).
   - Example: To bet 0.01 ETH, enter `10000000000000000`
6. Confirm and sign the transaction.

### 3. Settling an Event

To settle an event and determine the winning outcome:

1. Find the `settleEvent` function under the “Write Contract” tab.
2. Enter the `eventId` of the event you want to settle.
   - Example: `0` for the first event
3. Enter the `winningOutcome`.
   - Example: `0` for Team X,`1` for Team Y, `2` for a draw
4. Confirm and sign the transaction.

### 4. Calculating Odds

Odds are calculated automatically when a bet is placed. To view the odds:

1. Navigate to the “Read Contract” tab.
2. Find the `getBetData` function.
3. Enter the `eventId` and the bettor’s address.
   - Example: `eventId` - `0`, `bettor's address` - `0x123...`
4. The function will return bet details, including the calculated odds.

## Notes

- Transactions require ETH for gas fees.
- Ensure you are interacting with the correct contract and network.
- The contract owner is the only one who can add events and settle them.

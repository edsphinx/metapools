// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/MetaPools.sol";

contract MetaPoolsTest is Test {
    MetaPools public metaPools;
    bytes32[] predictions;

    function setUp() public {
        metaPools = new MetaPools();
        metaPools.createPool(5739725000000000, MetaPools.PoolType.Public); // Specify the entry fee in wei directly
    }

    function testJoinPool() public {
        address participant = address(this);
        uint poolCount = 1; // Specify the pool ID to join

        // Make predictions
        predictions = new bytes32[](10);
        for (uint i = 0; i < predictions.length; i++) {
            predictions[i] = bytes32(i);
        }

        // Join the pool
        metaPools.joinPool{value: 5739725000000000}(poolCount, predictions);

        // Assert participant is added and predictions are stored correctly
        address[] memory participants = metaPools.getPoolParticipants(
            poolCount
        );
        assertEq(participants.length, 1);
        assertEq(participants[0], participant);

        bytes32[] memory participantPredictions = metaPools
            .getParticipantPredictions(poolCount, participant);
        assertEq(participantPredictions.length, predictions.length);
    }
}

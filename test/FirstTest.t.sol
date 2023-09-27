// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.19;

// import "forge-std/Test.sol";
// import "../src/MetaPools_v2.sol";
// import "../src/AllowedNFT.sol";
// import "../src/MockNFT.sol";

// contract MetaPoolsTest is Test {
//     MetaPools public metaPools;
//     bytes32[] predictions;
//     uint poolCounter;
//     AllowedNFTs allowedNFTsContract;
//     address nftContractAddressPOAP;
//     MockNFT public mockNFT;

//     function setUp() public {
//         metaPools = new MetaPools();
//         nftContractAddressPOAP = 0x22C1f6050E56d2876009903609a2cC3fEf83B415;
//         mockNFT = new MockNFT();
//         allowedNFTsContract = new AllowedNFTs();
//         metaPools.createPool(5739725000000000, MetaPools.PoolType.Public); // Specify the entry fee in wei directly
//         metaPools.createPool(5739725000000000, MetaPools.PoolType.Private);
//         metaPools.setAllowedNFTsContract(1, nftContractAddressPOAP);
//         poolCounter = 2;
//     }

//     function testJoinPool() public {
//         address participant = address(this);
//         uint publicPoolCount = 0; // Specify the public pool ID to join
//         uint privatePoolCount = 1; // Specify the private pool ID to join

//         // Make predictions
//         predictions = new bytes32[](10);
//         for (uint i = 0; i < predictions.length; i++) {
//             predictions[i] = bytes32(i);
//         }

//         // Join the public pool
//         metaPools.joinPool{value: 5739725000000000}(
//             publicPoolCount,
//             predictions
//         );

//         // Assert participant is added and predictions are stored correctly
//         address[] memory publicParticipants = metaPools.getPoolParticipants(
//             publicPoolCount
//         );

//         assertEq(publicParticipants.length, 1);
//         assertEq(publicParticipants[0], participant);

//         bytes32[] memory publicParticipantPredictions = metaPools
//             .getParticipantPredictions(publicPoolCount, participant);
//         assertEq(publicParticipantPredictions.length, predictions.length);

//         // Join the private pool
//         allowedNFTsContract.hasNFT(privatePoolCount, participant); // Allow participant to join the private pool
//         metaPools.joinPool{value: 5739725000000000}(
//             privatePoolCount,
//             predictions
//         );

//         // Assert participant is added and predictions are stored correctly
//         address[] memory privateParticipants = metaPools.getPoolParticipants(
//             privatePoolCount
//         );
//         assertEq(privateParticipants.length, 1);
//         assertEq(privateParticipants[0], participant);

//         bytes32[] memory privateParticipantPredictions = metaPools
//             .getParticipantPredictions(privatePoolCount, participant);
//         assertEq(privateParticipantPredictions.length, predictions.length);
//     }

//     function testDeclareResults() public {
//         // Join the pools
//         testJoinPool();

//         uint publicPoolCount = 0; // Specify the public pool ID for result declaration
//         uint privatePoolCount = 1; // Specify the private pool ID for result declaration
//         uint winningPredictionCount = 5; // Specify the winning prediction count

//         // Close the pools
//         metaPools.closePool(publicPoolCount);
//         metaPools.closePool(privatePoolCount);

//         bool publicPoolClosed = metaPools.getIsClosed(publicPoolCount);
//         bool privatePoolClosed = metaPools.getIsClosed(privatePoolCount);

//         // Declare results for the public pool
//         require(publicPoolClosed, "Public pool is not closed yet");
//         require(
//             !metaPools.getResultsDeclared(publicPoolCount),
//             "Public pool results already declared"
//         );
//         require(
//             winningPredictionCount <= 10,
//             "Invalid winning prediction count"
//         );

//         metaPools.setWinningPredictionCount(
//             publicPoolCount,
//             winningPredictionCount
//         );
//         metaPools.setPrizePool(
//             publicPoolCount,
//             metaPools.getEntryFee(publicPoolCount) *
//                 metaPools.getPoolParticipantsLength(publicPoolCount)
//         );

//         // Distribute prizes for the public pool
//         address[] memory publicParticipants = metaPools.getPoolParticipants(
//             publicPoolCount
//         );
//         for (uint i = 0; i < publicParticipants.length; i++) {
//             address participant = publicParticipants[i];
//             bytes32[] memory participantPredictions = metaPools
//                 .getParticipantPredictions(publicPoolCount, participant);
//             if (participantPredictions.length == winningPredictionCount) {
//                 payable(participant).transfer(
//                     metaPools.getPrizePool(publicPoolCount) /
//                         metaPools.getWinningPredictionCount(publicPoolCount)
//                 );
//             }
//         }

//         metaPools.setResultsDeclared(publicPoolCount, true);

//         // Assert results are declared correctly for the public pool
//         assertEq(metaPools.getResultsDeclared(publicPoolCount), true);
//         assertEq(
//             metaPools.getWinningPredictionCount(publicPoolCount),
//             winningPredictionCount
//         );
//         assertEq(
//             metaPools.getPrizePool(publicPoolCount),
//             metaPools.getEntryFee(publicPoolCount) *
//                 metaPools.getPoolParticipantsLength(publicPoolCount)
//         );

//         // Declare results for the private pool
//         require(privatePoolClosed, "Private pool is not closed yet");
//         require(
//             !metaPools.getResultsDeclared(privatePoolCount),
//             "Private pool results already declared"
//         );
//         require(
//             winningPredictionCount <= 10,
//             "Invalid winning prediction count"
//         );

//         metaPools.setWinningPredictionCount(
//             privatePoolCount,
//             winningPredictionCount
//         );
//         metaPools.setPrizePool(
//             privatePoolCount,
//             metaPools.getEntryFee(privatePoolCount) *
//                 metaPools.getPoolParticipantsLength(privatePoolCount)
//         );

//         // Distribute prizes for the private pool
//         address[] memory privateParticipants = metaPools.getPoolParticipants(
//             privatePoolCount
//         );
//         for (uint i = 0; i < privateParticipants.length; i++) {
//             address participant = privateParticipants[i];
//             bytes32[] memory participantPredictions = metaPools
//                 .getParticipantPredictions(privatePoolCount, participant);
//             if (participantPredictions.length == winningPredictionCount) {
//                 payable(participant).transfer(
//                     metaPools.getPrizePool(privatePoolCount) /
//                         metaPools.getWinningPredictionCount(privatePoolCount)
//                 );
//             }
//         }

//         metaPools.setResultsDeclared(privatePoolCount, true);

//         // Assert results are declared correctly for the private pool
//         assertEq(metaPools.getResultsDeclared(privatePoolCount), true);
//         assertEq(
//             metaPools.getWinningPredictionCount(privatePoolCount),
//             winningPredictionCount
//         );
//         assertEq(
//             metaPools.getPrizePool(privatePoolCount),
//             metaPools.getEntryFee(privatePoolCount) *
//                 metaPools.getPoolParticipantsLength(privatePoolCount)
//         );
//     }
// }

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {AllowedNFTs} from "./AllowedNFT.sol";

contract MetaPools {
    enum PoolType {
        Public,
        Private
    }

    struct Prediction {
        uint[] teams;
        uint[] matchResults;
        bool submitted;
    }

    struct Pool {
        uint poolId;
        uint entryFee;
        address[] participants;
        mapping(address => bytes32[]) predictions;
        bool closed;
        bool resultsDeclared;
        uint winningPredictionCount;
        uint prizePool;
        PoolType poolType;
        mapping(uint => address) allowedNFTsContracts;
    }

    mapping(uint => Pool) public pools;
    uint public poolCounter;

    event PoolCreated(uint poolId, uint entryFee, PoolType poolType);
    event PredictionSubmitted(uint poolId, address participant);
    event ResultsDeclared(
        uint poolId,
        uint winningPredictionCount,
        uint prizePool
    );

    modifier validPoolId(uint poolId) {
        require(poolId > 0 && poolId <= poolCounter, "Invalid pool ID");
        _;
    }

    function createPool(
        uint entryFee,
        PoolType poolType
    ) external returns (uint) {
        poolCounter++;
        Pool storage newPool = pools[poolCounter];
        newPool.poolId = poolCounter;
        newPool.entryFee = entryFee;
        newPool.poolType = poolType;
        // newPool.allowedNFTsContract = new AllowedNFTs();

        emit PoolCreated(poolCounter, entryFee, poolType);

        return poolCounter;
    }

    function joinPool(
        uint poolId,
        bytes32[] calldata predictions
    ) external payable {
        Pool storage pool = pools[poolId];
        require(!pool.closed, "Pool is closed for predictions");

        if (pool.poolType == PoolType.Private) {
            address allowedNFTsContract = getAllowedNFTsContract(poolId);
            require(
                AllowedNFTs(allowedNFTsContract).hasNFT(poolId, msg.sender),
                "Participant is not allowed to join this private pool"
            );
        }

        require(msg.value == pool.entryFee, "Incorrect entry fee");
        require(predictions.length == 10, "Invalid predictions count");

        pool.participants.push(msg.sender);
        pool.predictions[msg.sender] = predictions;

        emit PredictionSubmitted(poolId, msg.sender);
    }

    // function joinPool(
    //     uint poolId,
    //     bytes32[] calldata predictions
    // ) external payable {
    //     Pool storage pool = pools[poolId];
    //     require(!pool.closed, "Pool is closed for predictions");

    //     if (pool.poolType == PoolType.Private) {
    //         require(
    //             pools[poolId].allowedNFTsContract.hasNFT(poolId, msg.sender),
    //             "Participant is not allowed to join this private pool"
    //         );
    //     }

    //     require(msg.value == pool.entryFee, "Incorrect entry fee");
    //     require(predictions.length == 10, "Invalid predictions count");

    //     pool.participants.push(msg.sender);
    //     pool.predictions[msg.sender] = predictions;

    //     emit PredictionSubmitted(poolId, msg.sender);
    // }

    function closePool(uint poolId) external {
        Pool storage pool = pools[poolId];
        require(pool.participants.length > 0, "No participants in the pool");
        require(!pool.closed, "Pool is already closed");

        pool.closed = true;
    }

    function declareResults(uint poolId, uint winningPredictionCount) external {
        Pool storage pool = pools[poolId];
        require(pool.closed, "Pool is not closed yet");
        require(!pool.resultsDeclared, "Results already declared");
        require(
            winningPredictionCount <= 10,
            "Invalid winning prediction count"
        );

        pool.winningPredictionCount = winningPredictionCount;
        pool.prizePool = pool.entryFee * pool.participants.length;

        for (uint i = 0; i < pool.participants.length; i++) {
            address participant = pool.participants[i];
            if (
                pool.predictions[participant].length == winningPredictionCount
            ) {
                payable(participant).transfer(
                    pool.prizePool / pool.winningPredictionCount
                );
            }
        }

        pool.resultsDeclared = true;

        emit ResultsDeclared(poolId, winningPredictionCount, pool.prizePool);
    }

    // HERE ARE THE GETTERS

    function getPoolId(
        uint poolId
    ) external view validPoolId(poolId) returns (uint) {
        return pools[poolId].poolId;
    }

    function getEntryFee(
        uint poolId
    ) external view validPoolId(poolId) returns (uint) {
        return pools[poolId].entryFee;
    }

    function getIsClosed(
        uint poolId
    ) external view validPoolId(poolId) returns (bool) {
        return pools[poolId].closed;
    }

    function getResultsDeclared(
        uint poolId
    ) external view validPoolId(poolId) returns (bool) {
        return pools[poolId].resultsDeclared;
    }

    function getPoolParticipantsLength(
        uint poolId
    ) external view validPoolId(poolId) returns (uint) {
        return pools[poolId].participants.length;
    }

    function getPoolParticipants(
        uint poolId
    ) external view validPoolId(poolId) returns (address[] memory) {
        return pools[poolId].participants;
    }

    function getParticipantPredictions(
        uint poolId,
        address participant
    ) external view validPoolId(poolId) returns (bytes32[] memory) {
        return pools[poolId].predictions[participant];
    }

    function getWinningPredictionCount(
        uint poolId
    ) external view validPoolId(poolId) returns (uint) {
        return pools[poolId].winningPredictionCount;
    }

    function getPrizePool(
        uint poolId
    ) external view validPoolId(poolId) returns (uint) {
        return pools[poolId].prizePool;
    }

    // Function to get the allowed NFTs contract address for a specific pool
    function getAllowedNFTsContract(
        uint poolId
    ) public view validPoolId(poolId) returns (address) {
        return pools[poolId].allowedNFTsContracts[poolId];
    }

    // HERE ARE THE SETTERS

    function setWinningPredictionCount(
        uint poolId,
        uint winningPredictionCount
    ) external validPoolId(poolId) {
        pools[poolId].winningPredictionCount = winningPredictionCount;
    }

    function setPrizePool(
        uint poolId,
        uint prizePool
    ) external validPoolId(poolId) {
        pools[poolId].prizePool = prizePool;
    }

    function setResultsDeclared(
        uint poolId,
        bool resultsDeclared
    ) external validPoolId(poolId) {
        pools[poolId].resultsDeclared = resultsDeclared;
    }

    // Function to set the allowed NFTs contract address for a specific pool
    function setAllowedNFTsContract(
        uint poolId,
        address contractAddress
    ) public validPoolId(poolId) {
        pools[poolId].allowedNFTsContracts[poolId] = contractAddress;
    }
}

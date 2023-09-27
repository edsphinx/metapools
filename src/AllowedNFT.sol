// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {ERC721} from "../lib/openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

contract AllowedNFTs {
    struct ParticipantNFTs {
        mapping(address => bool) nftContracts;
        bool exists;
    }

    mapping(uint256 => ParticipantNFTs) private allowedNFTs;

    event NFTAdded(uint256 poolId, address nftContractAddress);
    event NFTRemoved(uint256 poolId, address nftContractAddress);

    function addNFT(uint256 poolId, address nftContractAddress) external {
        require(poolId > 0, "Invalid poolId");
        require(
            nftContractAddress != address(0),
            "Invalid NFT contract address"
        );

        allowedNFTs[poolId].nftContracts[nftContractAddress] = true;
        allowedNFTs[poolId].exists = true;

        emit NFTAdded(poolId, nftContractAddress);
    }

    function removeNFT(uint256 poolId, address nftContractAddress) external {
        require(poolId > 0, "Invalid poolId");

        delete allowedNFTs[poolId].nftContracts[nftContractAddress];

        emit NFTRemoved(poolId, nftContractAddress);
    }

    function isNFTAllowed(
        uint256 poolId,
        address nftContractAddress
    ) external view returns (bool) {
        require(poolId > 0, "Invalid poolId");
        return allowedNFTs[poolId].nftContracts[nftContractAddress];
    }

    function setParticipantNFTStatus(
        uint256 poolId,
        address nftContractAddress,
        bool status
    ) external {
        require(poolId > 0, "Invalid poolId");
        allowedNFTs[poolId].nftContracts[nftContractAddress] = status;
    }

    function isParticipantNFTAllowed(
        uint256 poolId,
        address participant
    ) external view returns (bool) {
        require(poolId > 0, "Invalid poolId");
        return allowedNFTs[poolId].nftContracts[participant];
    }

    function hasNFT(
        uint256 poolId,
        address participant
    ) external view returns (bool) {
        require(poolId > 0, "Invalid poolId");
        return
            allowedNFTs[poolId].exists &&
            allowedNFTs[poolId].nftContracts[participant];
    }
}

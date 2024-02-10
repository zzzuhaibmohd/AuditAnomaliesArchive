// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Consider a Staking contract, that mints NFT in return for the ether staked
//The user can mint and burn the NFTs at any time

//Imagine the NFT has a special feature called "split", basically if user wants to split his/her stake into multiple NFT, they can do so by passing the weights they want to divide the NFTs into
//The problem occurs when the function does not validate the input of the weights array, it always assumes the size of greater than 0
//The impact of the issue is the user's NFT is burned and no new NFT is minted, resulting in user losing his/her staked ether

contract SplitTheNFT is ERC721("DivideNRule", "DNR") {
    struct StakingInfo {
        uint256 amount;
        uint256 timestamp;
        address owner;
    }

    mapping(uint256 => StakingInfo) public stakes;

    uint256 public nftId;

    constructor() {}

    function createStake() public payable {
        require(msg.value > 0, "No ether sent");
        _createStake(msg.value);
    }

    function destroyStake(uint256 id) public {
        require(ownerOf(id) == msg.sender, "Not the owner");

        _destroyStake(id, true);
    }

    function splitStake(uint256[] memory weights, uint256 id) external {
        StakingInfo memory theStake = stakes[id];

        require(ownerOf(id) == msg.sender, "Not the owner");

        uint256 totalWeight = 0;
        for (uint256 i = 0; i < weights.length; i++) {
            totalWeight += weights[i];
        }

        _destroyStake(id, false);

        for (uint256 i = 0; i < weights.length; i++) {
            uint256 theValue = (uint256(int256(theStake.amount)) * weights[i]) / totalWeight;
            _createStake(theValue);
        }
    }

    function _createStake(uint256 theValue) internal {
        _mint(msg.sender, nftId);

        stakes[nftId].amount = theValue;
        stakes[nftId].timestamp = block.timestamp;
        stakes[nftId].owner = msg.sender;

        nftId++;
    }

    function _destroyStake(uint256 id, bool isRefund) internal {
        _burn(id);

        uint256 refundAmount = stakes[id].amount;

        stakes[id].amount = 0;
        stakes[id].timestamp = block.timestamp;
        stakes[id].owner = address(0);

        if (isRefund) {
            (bool success,) = payable(msg.sender).call{value: refundAmount}("");
            require(success, "Transfer Failed");
        }
    }

    function getStake(uint256 id) external view returns (StakingInfo memory) {
        return stakes[id];
    }
}

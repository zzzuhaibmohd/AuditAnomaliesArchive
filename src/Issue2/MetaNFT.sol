// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Imagine the following contract as a Escrow contract to mint a NFT
// The NFT has a fixed price and each user can only mint 10 NFT

// The code implemented here is a pseudo version of the actual bug I found in an audit
// The impact of the bug is if (msg.value > PRICE_OF_NFT * amount) then the extra ETH sent by the user is never refunded

contract MetaNFT is Ownable {
    uint256 public constant PRICE_OF_NFT = 0.333 ether; // Fixed Price of NFT to buy set by the dev

    function mintMetaNFT(uint256 amount) external payable {
        require(amount <= 10, "You can mint a maximum of 10");
        require(msg.value >= PRICE_OF_NFT * amount, "Value sent was too low.");

        //imagine a for loop and
        //it generates a random trait for the NFT
        //and use an internal mint function to send it to the user
    }

    function withdraw() external payable onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "Transfer Failed!");
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Issue2/MetaNFT.sol";

contract IssueTwoTest is Test {
    MetaNFT theNFT;

    address userOne = address(0x00a);
    address userTwo = address(0x00b);

    function setUp() public {
        theNFT = new MetaNFT();
        vm.deal(userOne, 10 ether);
        vm.deal(userTwo, 10 ether);
    }

    function testUserSendsRequiredETHER() public {
        vm.startPrank(userOne);

        uint256 nft_to_buy = 5;
        uint256 ether_to_pay = theNFT.PRICE_OF_NFT() * nft_to_buy;

        bytes memory data = abi.encodeWithSignature("mintMetaNFT(uint256)", nft_to_buy);
        (bool success,) = address(theNFT).call{value: ether_to_pay}(data);
        require(success, "External call failed");

        vm.stopPrank();

        //Check if the amount to be sent and balance of NFT Escrow Contract is same
        assertEq(address(theNFT).balance, ether_to_pay);
    }

    function testUserSendsExtraETHER() public {
        vm.startPrank(userTwo);

        uint256 nft_to_buy = 5;
        uint256 ether_to_pay = theNFT.PRICE_OF_NFT() * nft_to_buy;

        bytes memory data = abi.encodeWithSignature("mintMetaNFT(uint256)", nft_to_buy);
        //Generally there are checks in the frontend app to calculate the msg.value
        //But during mint of an NFT, users prefer to directly interact with the contract
        //So that they do not miss the chance to mint an NFT
        //As a result, there is a chance a user may send some extra ETH which never gets refunded
        (bool success,) = address(theNFT).call{value: ether_to_pay + 1 ether}(data);
        require(success, "External call failed");

        vm.stopPrank();

        //Check if the amount to be sent and balance of NFT Escrow Contract is same
        assertGt(address(theNFT).balance, ether_to_pay);
    }
}

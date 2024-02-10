// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test, console2} from "forge-std/Test.sol";
import "src/Issue10/SplitTheNFT.sol";

contract IssueTenTest is Test {
    SplitTheNFT nft;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address owner = makeAddr("owner");

    uint256[] public splitItInto;

    function setUp() public {
        //Load Funds
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(owner, 10 ether);

        //Deploy Contract
        vm.prank(owner);
        nft = new SplitTheNFT();
    }

    function test_split_pass() public {
        //Stake by Alice
        vm.startPrank(alice);
        nft.createStake{value: 10 ether}();

        assertEq(nft.getStake(0).amount, 10 ether);
        assertEq(nft.getStake(0).owner, alice);

        //Split the NFT
        splitItInto = [1, 2, 3];
        nft.splitStake(splitItInto, 0); //(weights[], NFT ID)

        assertEq(nft.getStake(0).owner, address(0));
        assertEq(nft.getStake(1).owner, alice);
        assertEq(nft.getStake(2).owner, alice);
        assertEq(nft.getStake(3).owner, alice);

        vm.stopPrank();
    }

    function test_split_fail() public {
        //Stake by Bob
        vm.startPrank(bob);
        nft.createStake{value: 10 ether}();

        assertEq(nft.getStake(0).amount, 10 ether);
        assertEq(nft.getStake(0).owner, bob);

        //Split the NFT
        splitItInto = new uint256[](0);
        nft.splitStake(splitItInto, 0);

        assertEq(nft.getStake(0).owner, address(0));
        assertEq(nft.getStake(1).owner, address(0));

        assertEq(nft.getStake(1).amount, 0);
        assertEq(nft.getStake(1).amount, 0);

        vm.stopPrank();
    }
}

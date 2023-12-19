// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import "src/Issue9/PauseMePlease.sol";
import "src/helper/ERC20MockMintable.sol";

//import "forge-std/console.sol";

contract IssueNineTest is Test {
    ERC20MockMintable public MagicToken;
    XYZVotingContract public voteContract;
    XYZStakingContract public stakingContract;

    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address eve = makeAddr("eve");

    function setUp() public {
        MagicToken = new ERC20MockMintable("MagicToken", "MAGIC");

        //Mint MagicTokens ERC20 tokens to users
        MagicToken.mint(alice, 100 ether);
        MagicToken.mint(bob, 100 ether);
        MagicToken.mint(eve, 100 ether);

        //Setup the XYZVotingContract
        voteContract = new XYZVotingContract(address(MagicToken));

        //Setup the
        stakingContract = new XYZStakingContract(
            address(MagicToken),
            address(voteContract)
        );
    }

    function testvoteForUserWhenPaused() external {
        //alice and bob stake tokens to the staking contract
        vm.startPrank(alice);
        MagicToken.approve(address(stakingContract), 100 ether);
        stakingContract.lockTheTokens(100 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        MagicToken.approve(address(stakingContract), 50 ether);
        stakingContract.lockTheTokens(50 ether);
        vm.stopPrank();


        // The owner of the stakingContract pauses the contract to fix an issue or update a feature
        vm.prank(stakingContract.owner());
        stakingContract.pause();

        // a new proposal id is live for a limited time with id 44
        //alice, bob and eve try to delegate tokens to voting contract

        vm.prank(alice);
        vm.expectRevert("Pausable: paused"); // the tx fails because the contract is paused
        stakingContract.burnTokensToVote(44, 100 ether);

        vm.startPrank(bob);
        vm.expectRevert("Pausable: paused");
        stakingContract.burnTokensToVote(44, 50 ether); // the tx fails because the contract is paused
        MagicToken.approve(address(voteContract), 50 ether);
        voteContract.voteFor(44, 50 ether);
        vm.stopPrank();

        vm.startPrank(eve);
        MagicToken.approve(address(voteContract), 100 ether);
        voteContract.voteFor(44, 100 ether); // the tx succeds because the voteFor is not using the pausable pattern
        vm.stopPrank();

        //Check the votingPower of each user based on token they sent to voteContract
        assertEq(voteContract.getVoteForId(44, alice), 0);
        assertEq(voteContract.getVoteForId(44, bob), 50 ether);
        assertEq(voteContract.getVoteForId(44, eve), 100 ether);
    }
}

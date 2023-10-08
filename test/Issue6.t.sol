// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import "src/Issue6/BlackList.sol";
import "src/helper/ERC20MockBlackList.sol";

contract IssueSixTest is Test {
    address treasury = makeAddr("treasury");
    address userOne = makeAddr("userOne");

    BlackList theContract;
    ERC20MockBlackList blackListToken;

    function setUp() public {
        blackListToken = new ERC20MockBlackList("Mock Tether", "mUSDT");
        theContract = new BlackList(treasury, address(blackListToken));

        //Mint some mUSDT to userOne
        vm.prank(blackListToken.owner());
        blackListToken.mint(userOne, 100 ether);
    }

    function testCannotPerformTradeWhenTreasuryIsBlackListed() public {
        //Deposit Funds to theContract
        vm.startPrank(userOne);
        blackListToken.approve(address(theContract), blackListToken.balanceOf(userOne));
        theContract.depositUsdt(10 ether);
        vm.stopPrank();

        //The treasury is Blacklisted for some reason
        vm.prank(blackListToken.owner());
        blackListToken.blacklistAddress(treasury);

        //userOne tries to use the protocol but tx fails as the treasury address is blacklisted
        vm.expectRevert("Recipient is blacklisted");
        vm.prank(userOne);
        theContract.performTrade();
    }
}

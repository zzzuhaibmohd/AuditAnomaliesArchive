// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "script/Issue5.s.sol";
import "src/Issue5/SafeOwner.sol";
import "forge-std/console.sol";

contract IssueFiveTest is Test {
    IssueFiveDeploy public deployer;
    address public proxy;

    function setUp() public {
        vm.startPrank(address(0xabcd));
        deployer = new IssueFiveDeploy();
        proxy = deployer.run();
        SafeOwner(proxy).initialize();
        vm.stopPrank();
    }

    function testCallToInitialize() external {
        assertEq(SafeOwner(proxy).owner(), address(0)); //owner set to address(0)
        assertEq(SafeOwner(proxy).collectFee(), true);
    }

    function testCallToOnlyOwnerFunctionFails() public {
        vm.prank(address(0xabcd));
        vm.expectRevert("Ownable: caller is not the owner");
        SafeOwner(proxy).shouldCollectFee(false);
    }
}

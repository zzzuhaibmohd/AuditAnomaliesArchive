// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "forge-std/Test.sol";
import "script/Issue4.s.sol";
import "src/Issue4/Upgradable.sol";

contract IssueFourTest is Test {
    IssueFourDeploy public deployer;
    address public proxy;

    function setUp() public {
        deployer = new IssueFourDeploy();
    }

    function testCallToInitializeFails() external {
        proxy = deployer.run();
        vm.expectRevert("Initializable: contract is already initialized");
        ProductManager(proxy).initialize();
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "src/Issue3/BatchTokenTransfer.sol";
import "src/helper/ERC20MockMintable.sol";

contract IssueThreeTest is Test {
    BatchTokenTransfer target;
    ERC20MockMintable testToken;
    address userOne = address(0xabcd);
    address userTwo = address(0xef);

    function setUp() public {
        target = new BatchTokenTransfer();
        testToken = new ERC20MockMintable("TestToken", "TT");
        testToken.mint(userOne, 10 ether);
        testToken.mint(userTwo, 10 ether);
    }

    function testexecuteTxWithCorrectDecimal() public {
        vm.startPrank(userOne);

        vm.deal(userOne, 1 ether);

        bytes memory data = abi.encodeWithSignature(
            "executeTx(address,uint256,address,uint256)", userTwo, 10 ether, address(testToken), 18
        );
        (bool success,) = address(target).call{value: 0.01 ether}(data);
        require(success, "External call failed");

        vm.stopPrank();

        //Check if the fee of 0.01 ether was collected
        assertEq(address(target).balance, target.platform_fee());
        console.log("Fee Collected: ", address(target).balance);
    }

    function testexecuteTxWithInCorrectDecimal() public {
        vm.startPrank(userTwo);

        vm.deal(userTwo, 1 ether);

        bytes memory data = abi.encodeWithSignature(
            "executeTx(address,uint256,address,uint256)", userOne, 10 ether, address(testToken), 20
        );
        (bool success,) = address(target).call{value: 0}(data);
        require(success, "External call failed");

        vm.stopPrank();

        //Check if the fee of 0.01 ether was collected
        assertEq(address(target).balance, 0);
        console.log("Fee Collected: ", address(target).balance);
    }
}

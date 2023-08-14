// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import {Test} from "forge-std/Test.sol";
import "forge-std/console.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "src/Issue1/Vault4626.sol";

contract IssueOneTest is Test {

    ERC20 public weth_Token;
    ERC20 public usdc_Token;

    address weth_user = 0x4a18a50a8328b42773268B4b436254056b7d70CE;
    address usdc_user = 0x792337D17759a8d8C14DA39b9BD61B5b0537a993;

    Vault4626 theVault;

    function setUp() public {

        vm.createSelectFork("https://rpc.ankr.com/eth", 17907297);

        theVault = new Vault4626();

        weth_Token = ERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
        usdc_Token = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    }

    function testWithdrawWithWETHWillPASS() public {
        vm.startPrank(weth_user);
        
        weth_Token.approve(address(theVault), weth_Token.balanceOf(weth_user));
        theVault.deposit(address(weth_Token), 50);
        theVault.withdraw(address(weth_Token), 50);

        vm.stopPrank();
    }

    function testWithdrawWithUSDCWillFAIL() public {
        vm.startPrank(usdc_user);
        
        usdc_Token.approve(address(theVault), usdc_Token.balanceOf(usdc_user));
        theVault.deposit(address(usdc_Token), 5000);

        vm.expectRevert("ERC20: transfer amount exceeds balance");
        theVault.withdraw(address(usdc_Token), 1);
        //Even though the user has depisited a large amount i.e., 5000 USDC, 
        //Due to the bug in the withdraw function, the user cannot even withdraw 1 USDC

        vm.stopPrank();
    }


}

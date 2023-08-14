// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "forge-std/console.sol";

// Imagine the following contract as a ERC4626 Vault
// Users can deposit any ERC20 based token and earn back the shares for the token
// In the current implementation there are no logic for calculation and transfer of shares
// The below code is to demonstrate the pitfalls when a dev hardcodes the decimals

// The code implemented here is a pseudo version of the actual bug I found in the audit
// The impact of the bug is that once a user deposits the token, it cannot be withdrawn

interface IERC20Extented is IERC20 { // Standard IERC20 does not have an interface to get the ERC20 token decimals
    function decimals() external view returns (uint8);
}

contract Vault4626 {

    error Vault4626__InsufficientBalance();

    uint constant DECIMALS = 18;// THE BUG

    //track the balance of an user (user[token][value])
    mapping (address => mapping (address => uint)) users_balances;


    /**
    * @dev Deposits a specified amount of tokens into the contract.
    * @param token The address of the token to deposit.
    * @param value The amount of tokens to deposit without the decimal. For Example: if users wants to deposit - 1 ether into the contract, then user needs to follow the following representation - deposit(weth, 1)
    */
    function deposit(address token, uint value) external {
        //check if a valid token from the whitelist

        uint amount_to_deposit = value * (10 ** IERC20Extented(token).decimals());

        IERC20(token).transferFrom(msg.sender, address(this), amount_to_deposit);

        users_balances[msg.sender][token] += value;

        //rest of the code
        //not relevant to the Vulnerbility
    }

    /**
    * @dev Withdraws a specified amount of tokens from the contract.
    * @param token The address of the token to deposit.
    * @param value The amount of tokens to withdraw without the decimal. For Example: if users wants to withdraw - 1 ether into the contract, then user needs to follow the following representation - withdraw(weth, 1)
    */
    function withdraw(address token, uint value) external {
        
        uint token_balance = users_balances[msg.sender][token];
        
        if (value > token_balance) revert Vault4626__InsufficientBalance();

        uint amount_to_withdraw = value * (10 ** DECIMALS);
        
        users_balances[msg.sender][token] -= value;

        IERC20(token).transfer(msg.sender, amount_to_withdraw);

        //rest of the code
        //not relevant to the Vulnerbility
    }

    function fetchBalance(address user, address token) external view returns(uint256) {
        return users_balances[user][token];
    }

}
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//Consider a contract that enables users to deposit funds and engage in trading or provide services for which they charge a fee of 2.5%. However, issues arise when the underlying token used for these purposes has a blacklist functionality.
//To make matters worse, the address of the externally owned account (EOA) collecting the fee cannot be updated. This situation is akin to a compromised private key, leading to two potential scenarios: the protocol ceases to function, or the protocol loses all the collected fees.

contract BlackList {
    address immutable platformTreasury;
    address immutable usdtToken;

    uint256 constant FEE = 250;

    mapping(address => uint256) balances;

    constructor(address _platformTreasury, address _usdtToken) {
        platformTreasury = _platformTreasury;
        usdtToken = _usdtToken;
    }

    function depositUsdt(uint256 amount) public {
        IERC20(usdtToken).transferFrom(msg.sender, address(this), amount);

        balances[msg.sender] += amount;
    }

    function performTrade() public {
        require(balances[msg.sender] > 0, "Balance > 0");

        uint256 fee_to_pay = balances[msg.sender] * FEE;

        IERC20(usdtToken).transferFrom(msg.sender, platformTreasury, fee_to_pay);

        //rest of the code
    }
}

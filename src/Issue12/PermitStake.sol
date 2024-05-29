// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./ERC20Permit.sol";

contract PermitStake {

    ERC20PermitToken public erc20;
    mapping(address => uint256) public deposits;

    constructor(address permitToken) {
        erc20 = ERC20PermitToken(permitToken);
    }

    function depositWithPermit(address user, uint256 amount, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
        erc20.permit(user, address(this), amount, deadline, v, r, s);
        require(erc20.transferFrom(user, address(this), amount), "Transfer failed");

        deposits[user] += amount;
    }
    
}
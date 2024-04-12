// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// The Context: CoinSwitch is a migration contract that allows users to migrate from oldToken to newToken.
// The users can do so by calling the swapTokens which swaps thier existing oldToken into this contract and transfers 1:1 newToken to the staking contract
// to keep things simpler imagine the owner transfer the INIT_AMOUNT of tokens to CoinSwitch contract once deployed
// What can go wrong here ?

contract CoinSwitch is Ownable {
    uint256 public constant INIT_AMOUNT = 10000 ether;
    uint256 public constant MIN_LOCK_PERIOD = 90 days;

    // Corrected the contract address format to address type
    address public constant STAKING_CONTRACT = address(5454);

    uint256 public immutable eventEndBlock;
    IERC20Metadata public oldToken;
    IERC20Metadata public newToken;

    constructor(uint256 _eventEndBlock) {
        eventEndBlock = _eventEndBlock;
    }

    function burnOldTokens() external onlyOwner {
        require(block.number > eventEndBlock, "eventEndBlock yet to finish");
        uint256 balanceBMI = oldToken.balanceOf(address(this));
        oldToken.transfer(address(0), balanceBMI);
    }

    function swapTokens(uint256 lockPeriod) external {
        require(block.number <= eventEndBlock, "eventEndBlock reached");
        _swapTokens(lockPeriod, oldToken.balanceOf(msg.sender));
    }

    function _swapTokens(uint256 lockPeriod, uint256 amountoldToken) internal {
        require(lockPeriod >= MIN_LOCK_PERIOD, "lockPeriod < MIN_LOCK_PERIOD");

        // transfer holding oldToken to the contract
        if (amountoldToken > 0) {
            oldToken.transferFrom(msg.sender, address(this), amountoldToken);
        }

        require(amountoldToken > 0, "zero balance");

        // Transfer the newTokens to the staking contract
        // Imagine it creates a new position for the user
        // No issues beyond this point of the code

        newToken.transfer(STAKING_CONTRACT, amountoldToken);

        // rest of the code
    }
}

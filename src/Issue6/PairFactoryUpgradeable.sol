// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "lib/openzeppelin-contracts-upgradeable/contracts/access/OwnableUpgradeable.sol";

contract PairFactoryUpgradeable is OwnableUpgradeable {
    bool public isPaused;
    address public feeManager;

    constructor() {}

    function initialize() public initializer {
        __Ownable_init();
        isPaused = true;
        feeManager = msg.sender;
    }
}

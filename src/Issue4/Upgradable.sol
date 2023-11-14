// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";

// Imagine the OwnerGovernable as a custom contract with two roles owner and governor
// It has a custom function "__owner_governable_init" which can be called only once to set the owner and governor, This contract was written to mimic the OwnerUpgradable

// The code implemented here is a pseudo version of the actual bug I found in an audit
// The impact of the bug is that the deployed contract cannot be initialized due to double initialization casuing DoS. The lack of unit test from the devs casued the issue

contract OwnerGovernable is Initializable {
    address public governor;
    address public owner;

    function __owner_governable_init() internal initializer {
        //custom function
        governor = msg.sender;
        owner = msg.sender;
    }

    modifier onlyGovernor() {
        require(msg.sender == governor, "OwnerGovernable: forbidden");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "OwnerGovernable: forbidden");
        _;
    }
}

contract ProductManager is UUPSUpgradeable, OwnerGovernable {
    bool public discountEnabled = false; // Imagine this to be an important variable to set be once the contract is deployed via Proxy

    //The OwnerGovernable's "__owner_governable_init" is already using an initializer modifier
    //As a result calling the initialize function results in double initialization error
    function initialize() public initializer {
        discountEnabled = true;
        __owner_governable_init();
    }

    function _authorizeUpgrade(address newImplementation) internal pure override {
        (newImplementation);
    }
}

pragma solidity ^0.8.16;

//import "forge-std/console.sol";
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Consider an Upgradable Contract that exclusively employs functions protected by onlyOwner, without relying on the OwnableUpgradable OZ Library. Instead, it utilizes the standard Ownable library, with the owner being set during the contract's constructor execution.
// Utilizing the Ownable library in an Upgradable contract results in a critical issue: the owner's address is never set to the caller and it is address(0).
// The code presented here is a simulated representation of the actual bug I encountered during an audit.

contract SafeOwner is UUPSUpgradeable, Initializable, Ownable {
    bool public collectFee;

    function _authorizeUpgrade(address newImplementation) internal pure override {
        (newImplementation);
        // _onlyOwner();
    }

    function initialize() public initializer {
        collectFee = true;
    }

    function shouldCollectFee(bool _collectFee) external onlyOwner {
        collectFee = _collectFee;
    }
}

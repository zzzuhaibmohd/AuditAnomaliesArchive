// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//Consider a new blockchain Testchain and $TEST as its native currency which is EVM compatible
//There is ERC20 version deployed on mainnet as well
//The purpose of the TestBridge is to allow users to transfer $TEST tokens between Mainnet and Testchain

//The issue that is being discussed is with respect to Denial of Service(DoS).
//The root cause of which is using the "nativeTokenBalance" to track
//The Denial of Service(DoS) is caused by the use of "selfdestruct" by a malicious user

contract TestBridge is Ownable, ReentrancyGuard {
    // Custom Errors
    error InvalidAmount();
    error WithdrawFailed();
    error InvalidTransfer();
    error AddressZeroCheck();
    error InsufficientAvailableBalance();

    using SafeERC20 for IERC20;

    // Address of the $TEST ERC20 token contract on mainnet
    IERC20 private evmERC20Token;

    // Counter to track the number of deposits
    uint256 public depositsCounter;

    // Counter to track the number of withdrawals
    uint256 public withdrawalsCounter;

    // Chain ID of the Humans mainnet
    uint256 private nativeChainId;

    // Chain ID of the Ethereum mainnet
    uint256 private evmChainId;

    // Available balance of the native token
    uint256 private nativeTokenBalance;

    constructor(uint256 _nativeChainId, uint256 _evmChainId, address _evmERC20Token) {
        // Set the native chain ID (where the bridge transfers native tokens)
        nativeChainId = _nativeChainId;

        // Set the evm chain ID (where the bridge transfers ERC20 tokens)
        evmChainId = _evmChainId;

        // Address of the ERC20 token contract that the bridge will transfer on the evm chain
        evmERC20Token = IERC20(_evmERC20Token);
    }

    // Struct to store deposit data
    struct Deposit {
        address sourceNetworkToken;
        address destinationNetworkToken;
        address sender;
        address receiver;
        uint256 amount;
        uint256 sourceChainId;
        uint256 destinationChainId;
        uint256 nonce;
    }

    // Struct to store withdraw data
    struct Withdraw {
        address sourceNetworkToken;
        address destinationNetworkToken;
        address sender;
        address receiver;
        uint256 amount;
        uint256 sourceChainId;
        uint256 destinationChainId;
        uint256 nonce;
    }

    // Mapping to store deposit data
    mapping(uint256 => Deposit) public deposits;

    // Mapping to store withdraw data
    mapping(uint256 => Withdraw) public withdrawals;

    // Mapping to store used messageHash
    mapping(bytes32 messageHash => bool) private used;

    // @notice depositNativeToken() allows users to deposit native $TEST tokens into the bridge
    function depositNativeToken(address receiver) external payable nonReentrant {
        uint256 nonce = depositsCounter;
        // Check input parameters
        if (receiver == address(0)) revert AddressZeroCheck();
        if (msg.value <= 0) revert InvalidAmount();

        // Check if token balance has increased by amount
        if (address(this).balance - msg.value != nativeTokenBalance) {
            revert InvalidTransfer();
        }

        // Increase native token balance
        nativeTokenBalance += msg.value;

        // Store deposit data in mapping
        deposits[nonce] = Deposit(
            address(0), address(evmERC20Token), _msgSender(), receiver, msg.value, nativeChainId, evmChainId, nonce
        );

        // Increment deposits counter
        depositsCounter++;
    }

    //  @notice emergencyWithdrawNative() allows the onlyOwner to withdraw native tokens from the bridge
    function emergencyWithdrawNative() external onlyOwner {
        uint256 balance = address(this).balance;
        if (balance <= 0) revert InsufficientAvailableBalance();

        // Transfer native tokens to the admin
        (bool success,) = payable(_msgSender()).call{value: balance}("");
        if (!success) revert InvalidTransfer();

        // Decrease native token balance
        nativeTokenBalance -= balance;

        // Check if native token balance is zero
        if (address(this).balance != 0) revert WithdrawFailed();
    }
}

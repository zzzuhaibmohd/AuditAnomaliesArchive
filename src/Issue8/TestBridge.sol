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

//The issue that is being discussed is with respect to Cross Function Reentrancy
//The root cause of which is not following the CEI pattern, leading to burning of the signature hash post external call

contract TestBridge is Ownable, ReentrancyGuard {
    // Custom Errors
    error InvalidAmount();
    error WithdrawFailed();
    error InvalidTransfer();
    error AddressZeroCheck();
    error InsufficientAvailableBalance();
    error HashAlreadyUsed();
    error InvalidChainId();

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
    mapping(bytes32 messageHash => bool) public signatureUsed;

    function depositERC20(address receiver, uint256 amount) external nonReentrant {
        // Check input parameters
        uint256 nonce = depositsCounter;
        if (receiver == address(0)) revert AddressZeroCheck();
        if (amount <= 0) revert InvalidAmount();

        // Transfer to-be-deposited tokens from sender to this smart contract
        evmERC20Token.safeTransferFrom(_msgSender(), address(this), amount);

        // Store deposit data in mapping
        deposits[nonce] = Deposit(
            address(evmERC20Token), address(0), _msgSender(), receiver, amount, evmChainId, nativeChainId, nonce
        );

        // Increment deposits counter
        depositsCounter++;
    }

    function withdrawNative(address sender, uint256 amount, uint256 nonce, bytes memory signature)
        external
        nonReentrant
    {
        // Check input parameters
        if (sender == address(0)) revert AddressZeroCheck();
        if (amount <= 0) revert InvalidAmount();
        if (address(this).balance < amount) {
            revert InsufficientAvailableBalance();
        }

        // Generate message hash to verify signature
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(evmERC20Token), address(0), sender, _msgSender(), amount, evmChainId, nativeChainId, nonce
            )
        );

        if (signatureUsed[messageHash]) revert HashAlreadyUsed();

        //Note: Imagine code to verify the signature and if the SIGNER_ROLE has signed the signature

        // Transfer native tokens
        (bool success,) = payable(_msgSender()).call{value: amount}("");
        if (!success) revert InvalidTransfer();

        // Decrease native token balance
        nativeTokenBalance -= amount;

        // Increment withdrawals counter
        withdrawalsCounter++;

        // Mark the signature as used
        signatureUsed[messageHash] = true;

        // Store withdraw data in mapping
        withdrawals[nonce] =
            Withdraw(address(evmERC20Token), address(0), sender, _msgSender(), amount, evmChainId, nativeChainId, nonce);
    }

    function renounceClaim(
        address destinationNetworkToken,
        address sender,
        uint256 amount,
        uint256 nonce,
        bytes memory signature
    ) public {
        uint256 currentChainId = getChainID();

        if (sender == address(0)) revert AddressZeroCheck();
        if (amount <= 0) revert InvalidAmount();

        // Generate message hash to verify signature
        bytes32 messageHash;
        uint256 sourceChainId;
        uint256 destinationChainId;

        if (destinationNetworkToken == address(0)) {
            if (currentChainId == evmChainId) revert InvalidChainId();
            messageHash = keccak256(
                abi.encodePacked(
                    address(evmERC20Token), address(0), sender, _msgSender(), amount, evmChainId, nativeChainId, nonce
                )
            );

            sourceChainId = evmChainId;
            destinationChainId = nativeChainId;
        } else {
            if (currentChainId == nativeChainId) revert InvalidChainId();
            messageHash = keccak256(
                abi.encodePacked(
                    address(0), address(evmERC20Token), sender, _msgSender(), amount, nativeChainId, evmChainId, nonce
                )
            );

            sourceChainId = nativeChainId;
            destinationChainId = evmChainId;
        }

        if (signatureUsed[messageHash]) revert HashAlreadyUsed();

        //Note: Imagine code to verify the signature and if the SIGNER_ROLE has signed the signature

        // Mark the signature as used
        signatureUsed[messageHash] = true;
    }

    // @notice getChainID() returns the current chain ID
    // @dev This function is used to get the current chain ID
    // @return id The current chain ID
    function getChainID() private view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    // @notice receive() allows the contract to receive native tokens
    receive() external payable virtual {
        // Increase native token balance
        nativeTokenBalance += msg.value;
    }

    function getWithdrawMessageHash(address sender, uint256 amount, uint256 nonce) public returns (bytes32) {
        bytes32 messageHash = keccak256(
            abi.encodePacked(
                address(evmERC20Token), address(0), sender, _msgSender(), amount, evmChainId, nativeChainId, nonce
            )
        );

        return messageHash;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;

// Imagine the following is used to send ERC20, native token, ERC721 etc., in batch transactions
// The user has to pay a "platform_fee(0.01 ether)" if the transction value is more than "fee_limit"

// The code implemented here is a pseudo version of the actual bug I found in an audit
// The impact of the bug is due to giving control to user to passs the function input, As a result skip the payment of platform fee

contract BatchTokenTransfer {
    uint256 public constant fee_limit = 1; // accept fee only when fee_limit factor > 1
    uint256 public constant platform_fee = 0.01 ether; // the fee to pay

    function executeTx(
        address to, // Imagine a struct array containing the user list with "to" and "value" params
        uint256 value,
        address contract_address,
        uint256 decimals
    ) public payable {
        //function to calculate the fee
        uint256 fee = getPlatformFee(value, false, decimals);
        //The bug here is that the dev assumes the user will pass the correct decimals value
        //A better approach would be to fetch the current decimal value via the contract_address

        //rest of the code
        //transfer the tokens via safeTransferFrom etc.,
    }

    function getPlatformFee(uint256 _amount, bool _isNative, uint256 decimals) internal returns (uint256) {
        uint256 decimal_amount = _amount / 10 ** decimals;
        if (decimal_amount >= fee_limit) {
            //Collect fee only if decimal_amount >= fee_limit
            if (_isNative) {
                require(msg.value >= _amount + platform_fee, "platform fee required");
            } else {
                require(msg.value >= platform_fee, "platform fee required");
            }
        }
        return decimal_amount;
    }
}

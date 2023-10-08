// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ERC20MockBlackList is ERC20, Ownable {
    mapping(address => bool) public blacklist;

    event Blacklisted(address indexed account);
    event Unblacklisted(address indexed account);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function blacklistAddress(address account) public onlyOwner {
        blacklist[account] = true;
        emit Blacklisted(account);
    }

    function unblacklistAddress(address account) public onlyOwner {
        blacklist[account] = false;
        emit Unblacklisted(account);
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        require(!blacklist[msg.sender], "Sender is blacklisted");
        require(!blacklist[recipient], "Recipient is blacklisted");
        return super.transfer(recipient, amount);
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(!blacklist[sender], "Sender is blacklisted");
        require(!blacklist[recipient], "Recipient is blacklisted");
        return super.transferFrom(sender, recipient, amount);
    }
}

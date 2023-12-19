// SPDX-License-Identifier: MIT
pragma solidity ^0.8.16;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// Consider two contracts XYZStakingContract and XYZVotingContract under the same Token
// One of them uses the Pausable Pattern but other does not
// The bug in the code is related to DoS caused by enabling pausable pattern on some functions while omitting it in others
// This is a minimal code from the actual implemenation to keep it simple and easy to understand 

contract XYZStakingContract is Ownable, Pausable {
    address immutable token;
    mapping(address => uint) tokenBalance;

    XYZVotingContract public voteContract;

    constructor(address _token, address _voteContract) {
        token = _token;
        voteContract = XYZVotingContract(_voteContract);
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function lockTheTokens(uint value) public whenNotPaused {
        require(value > 0, "zero token error");
        IERC20(token).transferFrom(msg.sender, address(this), value);

        tokenBalance[msg.sender] += value;
    }

    function unlockTheTokens(uint value) public whenNotPaused {
        require(
            tokenBalance[msg.sender] >= value,
            "cannot unlock more than balance"
        );
        IERC20(token).transfer(msg.sender, value);
    }

    function burnTokensToVote(uint id, uint value) external whenNotPaused {
        require(
            tokenBalance[msg.sender] >= value,
            "cannot unlock more than balance"
        );

        unlockTheTokens(value);

        tokenBalance[msg.sender] -= value;
        voteContract.voteForUser(id, value, msg.sender);
    }
}

contract XYZVotingContract {
    address immutable token;
    mapping(address => mapping(uint => uint)) public votingPower;

    constructor(address _token) {
        token = _token;
    }

    function voteFor(uint id, uint votes) public {
        //check if valid proposal id

        IERC20(token).transferFrom(msg.sender, address(this), votes);

        votingPower[msg.sender][id] += votes;

        //Reward the user for voting
    }

    function voteForUser(uint id, uint votes, address user) public {
        //check if valid proposal id

        IERC20(token).transferFrom(msg.sender, address(this), votes);

        votingPower[user][id] += votes;

        //Reward the user for voting
    }

    function getVoteForId(uint id, address user) public returns (uint) {
        return votingPower[user][id];
    }
}

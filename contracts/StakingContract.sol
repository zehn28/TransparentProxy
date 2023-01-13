// SPDX-License-Identifier: None
pragma solidity ^0.8.11;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IRewardToken is IERC20 {
    function mint(address, uint256) external;
}

contract StakingContract {
    struct staked {
        uint256 stakedBal;
        uint256 timeLockedTill;
    }

    mapping(address => staked) public StakedUser;
    IERC20 public StakingToken;
    IRewardToken public RewardToken;

    constructor() {}

    function setStakingToken(address _stakingToken) external {
        StakingToken = IERC20(_stakingToken);
    }

    function setRewardToken(address _rewardToken) external {
        RewardToken = IRewardToken(_rewardToken);
    }

    function stake(uint256 _stakingAmount, uint256 _lockingTime) external {
        require(
            StakingToken.balanceOf(msg.sender) >= _stakingAmount,
            "Balance is less"
        );
        if (StakedUser[msg.sender].stakedBal == 0) {
            StakedUser[msg.sender] = staked(
                _stakingAmount,
                block.timestamp + _lockingTime
            );
        } else {
            staked memory user = StakedUser[msg.sender];
            user.stakedBal += _stakingAmount;
            user.timeLockedTill += _lockingTime;
            StakedUser[msg.sender] = user;
        }
        StakingToken.transferFrom(msg.sender, address(this), _stakingAmount);
    }

    function unstake(uint256 _unstakeBalance) external {
        staked memory user = StakedUser[msg.sender];
        require(user.timeLockedTill <= block.timestamp, "cannot unstake");
        require(user.stakedBal >= _unstakeBalance, "not enough staked Balance");
        StakingToken.transfer(msg.sender, _unstakeBalance);
        RewardToken.mint(msg.sender, _unstakeBalance);
        if (user.stakedBal == _unstakeBalance) {
            delete StakedUser[msg.sender];
        } else {
            user.stakedBal -= _unstakeBalance;
            StakedUser[msg.sender] = user;
        }
    }
}

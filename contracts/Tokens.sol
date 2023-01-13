// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract StakingToken is ERC20 {
    constructor() ERC20("StakingToken", "STK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract RewardToken is ERC20 {
    constructor() ERC20("RewardToken", "RTK") {}

    function mint(address to, uint256 amount) external  {
        _mint(to, amount);
    }
}
// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "solidity-interfaces/beethovenx/IBeethovenxChef.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./MockERC20.sol";

contract MockMasterChef is IBeethovenxChef {
  uint256 public rate = 10 ether;
  uint256 public start;
  mapping(uint256=>IERC20) tokens;
  IERC20 public token;
  MockERC20 public reward;
  mapping(uint256=>mapping(address=>uint256)) public balances;
  mapping(uint256=>uint256) public poolBalances;
  mapping(uint256=>mapping(address=>uint256)) public harvested;

  constructor(address[] memory tokens_, address reward_) {
    token = IERC20(tokens_[0]);
    reward = MockERC20(reward_);
    for(uint i = 0; i < tokens_.length; i++) {
      tokens[i] = IERC20(tokens_[i]);
    }
    start = block.number;
  }

  function deposit(uint256 _pid, uint256 _amount, address _to) external override {
    balances[_pid][_to] += _amount;
    poolBalances[_pid] += _amount;
    tokens[_pid].transferFrom(msg.sender, address(this), _amount);
  }
  function withdrawAndHarvest(uint256 _pid, uint256 _amount, address _to) external override {
    uint256 balance = balances[_pid][msg.sender];
    uint256 poolBalance = poolBalances[_pid];
    balances[_pid][msg.sender] = balance - _amount; // Overflow will cause this to revert
    poolBalances[_pid] = poolBalance - _amount;
    harvest(_pid, _to);
    token.transfer(msg.sender, _amount);
  }

  function harvest(uint256 _pid, address _to) public override {
    uint256 amount = userRewardAvail(msg.sender, _pid);
    harvested[_pid][msg.sender] = harvested[_pid][msg.sender] + amount;
    reward.mint(address(this), amount);
    reward.transfer(_to, amount);
  }

  function userInfo(uint256 _pid, address _user) external view override returns (uint256, uint256) {
    return (balances[_pid][_user], userRewardAvail(_user, _pid));
  }

  function emergencyWithdraw(uint256 _pid, address _to) external override {
  }

  function pendingBeets(uint256 _pid, address _to) external view override returns (uint256) {
  }

  function rewarder(uint256 _pid) external view override returns (address) {
  }

  function userRewardAvail(address user, uint256 pid) internal view returns(uint256) {
    uint256 totalAvail = (block.number - start) * rate;
    uint256 poolBalance = poolBalances[pid];
    if (totalAvail == 0 || poolBalance == 0) {
      return 0;
    }
    return ((totalAvail * balances[pid][user]) / poolBalance) - harvested[pid][user];
  }
}

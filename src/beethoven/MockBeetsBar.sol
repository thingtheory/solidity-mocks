// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../MockERC20.sol";
import "../interfaces/beethovenx/IBeetsBar.sol";

contract MockBeetsBar is IBeetsBar, MockERC20 {
  address input;
  constructor(address input_) MockERC20("BeetsBar", "BB") {
    input = input_;
  }

  function enter(uint256 amount_) external override {
    _mint(msg.sender, amount_);
    IERC20(input).transferFrom(msg.sender, address(this), amount_);
  }

  function leave(uint256 amount_) external override {
    _burn(msg.sender, amount_);
    IERC20(input).transfer(msg.sender, amount_);
  }
}


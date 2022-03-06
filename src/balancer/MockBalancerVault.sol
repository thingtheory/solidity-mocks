// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "../interfaces/beethovenx/IBalancerVault.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockBalancerVault is IBalancerVault {
    mapping(bytes32=>address) getPoolData;
    mapping(bytes32=>address[]) poolTokens;

    constructor() {}

    function setGetPool(bytes32 poolID, address pool) public {
      getPoolData[poolID] = pool;
    }

    function setPoolTokens(bytes32 poolID, address[] memory tokens) public {
      poolTokens[poolID] = tokens;
    }

    function swap(
        SingleSwap memory singleSwap,
        FundManagement memory funds,
        uint256 limit,
        uint256 deadline
    ) external override payable returns (uint256){
      return 10 gwei;
    }

    function joinPool(
        bytes32 poolId,
        address sender,
        address recipient,
        JoinPoolRequest memory request
    ) external override{
      IERC20(getPoolData[poolId]).transfer(recipient, 10 ether);
    }

    function getPoolTokens(bytes32 poolId)
        external
        view
        override
        returns (
            address[] memory tokens,
            uint256[] memory balances,
            uint256 lastChangeBlock
        ) {
          tokens = poolTokens[poolId];
          balances = new uint256[](tokens.length);
          for (uint i = 0; i < tokens.length; i++) {
            balances[i] = 10 gwei;
          }
          lastChangeBlock = block.number;
        }

    function getPool(bytes32 poolId)
        external
        view
        override
        returns (address, uint8) {
          return (getPoolData[poolId], uint8(232));
        }

}

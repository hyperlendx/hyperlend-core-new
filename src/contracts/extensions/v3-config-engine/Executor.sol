// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from '../../dependencies/openzeppelin/contracts/Ownable.sol';
import {AaveV3Payload} from './AaveV3Payload.sol';

/**
 * @title HyperLend Governance Excutor
 * @author HyperLend
 */
contract Executor is Ownable {
  function execute(address payload) external onlyOwner() {
    (bool success,) = payload.delegatecall(abi.encodeWithSelector(AaveV3Payload.execute.selector));
    require(success, 'execution failed');
  }
}
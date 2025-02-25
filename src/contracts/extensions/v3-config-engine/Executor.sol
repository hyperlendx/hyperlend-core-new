// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Ownable} from '../../dependencies/openzeppelin/contracts/Ownable.sol';

/**
 * @title HyperLend Governance Excutor
 * @author HyperLend
 */
contract Executor is Ownable {
  function execute(address payload) external onlyOwner() {
    (bool success, bytes memory returndata) = payload.delegatecall(abi.encodeWithSignature('execute()'));
    if (!success) {
      _revertWithReason(returndata);
    }
  }

  
  function _revertWithReason(bytes memory returndata) internal pure {
    if (returndata.length > 0) {
      assembly {
        let returndata_size := mload(returndata)
        revert(add(32, returndata), returndata_size)
      }
    } else {
      revert("execution failed");
    }
  }
}
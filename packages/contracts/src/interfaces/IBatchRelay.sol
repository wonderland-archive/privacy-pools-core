// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

import {ProofLib} from 'contracts/lib/ProofLib.sol';
import {IPrivacyPool} from 'interfaces/IPrivacyPool.sol';

interface IBatchRelay {
  /*///////////////////////////////////////////////////////////////
                              STRUCTS
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Struct for the batch relay data
   * @param recipient The final receiver of funds
   * @param feeRecipient The fee receiver
   * @param relayFeeBPS The relay fee in basis points
   * @param batchSize The number of withdrawals expected
   */
  struct BatchRelayData {
    address recipient;
    address feeRecipient;
    uint256 relayFeeBPS;
    uint8 batchSize;
  }

  /*///////////////////////////////////////////////////////////////
                              ERRORS
  //////////////////////////////////////////////////////////////*/

  /**
   * @notice Error thrown when the batch size is different from the number of proofs
   */
  error InvalidBatchSize();

  /**
   * @notice Error thrown when the processooor is invalid
   */
  error InvalidProcessooor();

  /**
   * @notice Error thrown when the address is zero
   */
  error ZeroAddress();

  /**
   * @notice Error thrown when the native asset transfer fails
   */
  error NativeAssetTransferFailed();

  /**
   * @notice Error thrown when the pool is in an invalid state
   */
  error InvalidPoolState();

  /*///////////////////////////////////////////////////////////////
                              FUNCTIONS
  //////////////////////////////////////////////////////////////*/

  /// @notice Batch relays a set of withdrawals
  /// @param _pool The pool to withdraw from
  /// @param _withdrawal The withdrawal to relay (identical across all notes)
  /// @param _proofs The proofs for the withdrawals
  function batchRelay(
    IPrivacyPool _pool,
    IPrivacyPool.Withdrawal memory _withdrawal,
    ProofLib.WithdrawProof[] memory _proofs
  ) external;
}

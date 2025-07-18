// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

import {IERC20} from '@oz/interfaces/IERC20.sol';
import {SafeERC20} from '@oz/token/ERC20/utils/SafeERC20.sol';
import {Constants} from 'contracts/lib/Constants.sol';
import {ProofLib} from 'contracts/lib/ProofLib.sol';
import {IBatchRelay} from 'interfaces/IBatchRelay.sol';
import {IPrivacyPool} from 'interfaces/IPrivacyPool.sol';

contract BatchRelay is IBatchRelay {
  using SafeERC20 for IERC20;
  using ProofLib for ProofLib.WithdrawProof;

  receive() external payable {}

  /// @inheritdoc IBatchRelay
  function batchRelay(
    IPrivacyPool _pool,
    IPrivacyPool.Withdrawal memory _withdrawal,
    ProofLib.WithdrawProof[] memory _proofs
  ) external {
    // Decode relay data
    BatchRelayData memory _data = abi.decode(_withdrawal.data, (BatchRelayData));

    // Check batch size
    if (_data.batchSize != _proofs.length) revert InvalidBatchSize();

    // Store pool asset
    IERC20 _asset = IERC20(_pool.ASSET());
    uint256 _balanceBefore = _assetBalance(_asset);

    // Batch withdraw
    uint256 _withdrawnAmount;
    for (uint256 i = 0; i < _proofs.length; i++) {
      _pool.withdraw(_withdrawal, _proofs[i]);
      _withdrawnAmount += _proofs[i].withdrawnValue();
    }

    // Deduct fees
    uint256 _amountAfterFees = _deductFee(_withdrawnAmount, _data.relayFeeBPS);

    uint256 _feeAmount = _withdrawnAmount - _amountAfterFees;

    // Transfer withdrawn funds to recipient
    _transfer(_asset, _data.recipient, _amountAfterFees);
    // Transfer fees to fee recipient
    _transfer(_asset, _data.feeRecipient, _feeAmount);

    // Check pool balance has not changed
    uint256 _balanceAfter = _assetBalance(_asset);
    if (_balanceBefore != _balanceAfter) revert InvalidPoolState();
  }

  /**
   * @notice Transfer out an asset to a recipient
   * @param _asset The asset to send
   * @param _recipient The recipient address
   * @param _amount The amount to send
   */
  function _transfer(IERC20 _asset, address _recipient, uint256 _amount) internal {
    if (_recipient == address(0)) revert ZeroAddress();

    if (_asset == IERC20(Constants.NATIVE_ASSET)) {
      (bool _success,) = _recipient.call{value: _amount}('');
      if (!_success) revert NativeAssetTransferFailed();
    } else {
      _asset.safeTransfer(_recipient, _amount);
    }
  }

  /**
   * @notice Fetch asset balance for the Entrypoint
   * @param _asset The asset address
   * @return _balance The asset balance
   */
  function _assetBalance(IERC20 _asset) internal view returns (uint256 _balance) {
    if (_asset == IERC20(Constants.NATIVE_ASSET)) {
      _balance = address(this).balance;
    } else {
      _balance = _asset.balanceOf(address(this));
    }
  }

  /**
   * @notice Deduct fees from an amount
   * @param _amount The amount before fees
   * @param _feeBPS The fee in basis points
   * @return _afterFees The amount after fees are deducted
   */
  function _deductFee(uint256 _amount, uint256 _feeBPS) internal pure returns (uint256 _afterFees) {
    _afterFees = _amount - ((_amount * _feeBPS) / 10_000);
  }
}

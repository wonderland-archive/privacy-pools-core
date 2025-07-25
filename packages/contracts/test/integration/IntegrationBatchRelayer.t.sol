// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

import {IntegrationBase} from './IntegrationBase.sol';
import {IBatchRelayer} from 'interfaces/IBatchRelayer.sol';
import {InternalLeanIMT, LeanIMTData} from 'lean-imt/InternalLeanIMT.sol';

contract IntegrationBatchRelayerSuccessCases is IntegrationBase {
  using InternalLeanIMT for LeanIMTData;

  function test_batchRelay() public {
    // Alice deposits 10 ETH
    Commitment memory _commitment1 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 10 ether, nullifier: 'nullifier_1', secret: 'secret_1'})
    );

    // Alice deposits 20 ETH
    Commitment memory _commitment2 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_2', secret: 'secret_2'})
    );

    // Push ASP root with label included
    vm.prank(_POSTMAN);
    _entrypoint.updateRoot(_shadowASPMerkleTree._root(), 'ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid');

    // Bob withdraws the total amount of Alice's commitment
    WithdrawalParams[] memory _params = new WithdrawalParams[](2);
    _params[0] = WithdrawalParams({
      withdrawnAmount: _commitment1.value,
      newNullifier: 'nullifier_1a',
      newSecret: 'secret_1a',
      recipient: _BOB,
      commitment: _commitment1,
      revertReason: NONE
    });
    _params[1] = WithdrawalParams({
      withdrawnAmount: _commitment2.value,
      newNullifier: 'nullifier_2a',
      newSecret: 'secret_2a',
      recipient: _BOB,
      commitment: _commitment2,
      revertReason: NONE
    });
    _withdrawThroughBatchRelayer(
      address(_batchRelayer),
      _params,
      IBatchRelayer.BatchRelayData({recipient: _BOB, feeRecipient: _RELAYER, relayFeeBPS: 0, batchSize: 2}),
      NONE
    );
  }

  function test_batchRelayOneProofZero() public {
    vm.skip(true);
  }

  function test_batchRelayFullBatchZero() public {
    vm.skip(true);
  }

  function test_batchRelayZeroFees() public {
    vm.skip(true);
  }

  function test_batchRelaySingleProof() public {
    vm.skip(true);
  }
}

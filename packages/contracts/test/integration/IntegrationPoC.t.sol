// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

import {IntegrationBase} from './IntegrationBase.sol';
import {BatchRelay} from 'contracts/BatchRelay.sol';
import {IBatchRelay} from 'interfaces/IBatchRelay.sol';
import {ProofLib} from 'contracts/lib/ProofLib.sol';
import {IPrivacyPool} from 'interfaces/IPrivacyPool.sol';
import {IState} from 'interfaces/IState.sol';
import {InternalLeanIMT, LeanIMTData} from 'lean-imt/InternalLeanIMT.sol';

contract IntegrationPoC is IntegrationBase {
  using InternalLeanIMT for LeanIMTData;

  BatchRelay internal _batchRelay;

  function setUp() public override {
    super.setUp();

    // Deploy BatchRelay contract
    _batchRelay = new BatchRelay();
  }

  function test_PoC() public {
    // Alice deposits 20 ETH
    Commitment memory _commitment1 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_1', secret: 'secret_1'})
    );

    // Alice deposits 20 ETH
    Commitment memory _commitment2 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_2', secret: 'secret_2'})
    );

    // Alice deposits 20 ETH
    Commitment memory _commitment3 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_3', secret: 'secret_3'})
    );

    // Alice deposits 20 ETH
    Commitment memory _commitment4 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_4', secret: 'secret_4'})
    );

    // Alice deposits 20 ETH
    Commitment memory _commitment5 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 20 ether, nullifier: 'nullifier_5', secret: 'secret_5'})
    );

    // Push ASP root with label included
    vm.prank(_POSTMAN);
    _entrypoint.updateRoot(_shadowASPMerkleTree._root(), 'ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid');

    // Bob withdraws 100 eth in 5 proofs
    IBatchRelay.BatchRelayData memory _batchData = IBatchRelay.BatchRelayData({
      recipient: _BOB,
      feeRecipient: _RELAYER,
      relayFeeBPS: _VETTING_FEE_BPS,
      batchSize: 5
    });

    (, ProofLib.WithdrawProof memory _proof1) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: _commitment1.value,
        newNullifier: 'nullifier_1a',
        newSecret: 'secret_1a',
        recipient: _BOB,
        commitment: _commitment1,
        revertReason: NONE
      }),
      _batchData
    );

    (, ProofLib.WithdrawProof memory _proof2) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: _commitment2.value,
        newNullifier: 'nullifier_2a',
        newSecret: 'secret_2a',
        recipient: _BOB,
        commitment: _commitment2,
        revertReason: NONE
      }),
      _batchData
    );

    (, ProofLib.WithdrawProof memory _proof3) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: _commitment3.value,
        newNullifier: 'nullifier_3a',
        newSecret: 'secret_3a',
        recipient: _BOB,
        commitment: _commitment3,
        revertReason: NONE
      }),
      _batchData
    );

    (, ProofLib.WithdrawProof memory _proof4) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: _commitment4.value,
        newNullifier: 'nullifier_4a',
        newSecret: 'secret_4a',
        recipient: _BOB,
        commitment: _commitment4,
        revertReason: NONE
      }),
      _batchData
    );

    (, ProofLib.WithdrawProof memory _proof5) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: _commitment5.value,
        newNullifier: 'nullifier_5a',
        newSecret: 'secret_5a',
        recipient: _BOB,
        commitment: _commitment5,
        revertReason: NONE
      }),
      _batchData
    );

    // Call
    ProofLib.WithdrawProof[] memory _proofs = new ProofLib.WithdrawProof[](5);
    _proofs[0] = _proof1;
    _proofs[1] = _proof2;
    _proofs[2] = _proof3;
    _proofs[3] = _proof4;
    _proofs[4] = _proof5;

    IPrivacyPool.Withdrawal memory _withdrawal =
      IPrivacyPool.Withdrawal({processooor: address(_batchRelay), data: abi.encode(_batchData)});

    vm.prank(_RELAYER);
    _batchRelay.batchRelay(_ethPool, _withdrawal, _proofs);

    assertEq(_balance(_ALICE, _ETH), 0);
    assertEq(_balance(_BOB, _ETH), 98.01 ether);
  }

  function test_PoC1() public {
    // Alice deposits 100 ETH
    Commitment memory _commitment1 = _deposit(
      DepositParams({depositor: _ALICE, asset: _ETH, amount: 100 ether, nullifier: 'nullifier_1', secret: 'secret_1'})
    );

    // Push ASP root with label included
    vm.prank(_POSTMAN);
    _entrypoint.updateRoot(_shadowASPMerkleTree._root(), 'ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid');

    // Bob withdraws 100 eth in 5 proofs
    IBatchRelay.BatchRelayData memory _batchData = IBatchRelay.BatchRelayData({
      recipient: _BOB,
      feeRecipient: _RELAYER,
      relayFeeBPS: _VETTING_FEE_BPS,
      batchSize: 5
    });

    (Commitment memory _commitment2, ProofLib.WithdrawProof memory _proof1) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: 20 ether,
        newNullifier: 'nullifier_1a',
        newSecret: 'secret_1a',
        recipient: _BOB,
        commitment: _commitment1,
        revertReason: NONE
      }),
      _batchData
    );

    (Commitment memory _commitment3, ProofLib.WithdrawProof memory _proof2) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: 20 ether,
        newNullifier: 'nullifier_2a',
        newSecret: 'secret_2a',
        recipient: _BOB,
        commitment: _commitment2,
        revertReason: NONE
      }),
      _batchData
    );

    (Commitment memory _commitment4, ProofLib.WithdrawProof memory _proof3) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: 20 ether,
        newNullifier: 'nullifier_3a',
        newSecret: 'secret_3a',
        recipient: _BOB,
        commitment: _commitment3,
        revertReason: NONE
      }),
      _batchData
    );

    (Commitment memory _commitment5, ProofLib.WithdrawProof memory _proof4) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: 20 ether,
        newNullifier: 'nullifier_4a',
        newSecret: 'secret_4a',
        recipient: _BOB,
        commitment: _commitment4,
        revertReason: NONE
      }),
      _batchData
    );

    (, ProofLib.WithdrawProof memory _proof5) = _withdrawThroughRelayerWithBatchData(
      address(_batchRelay),
      WithdrawalParams({
        withdrawnAmount: 10 ether,
        newNullifier: 'nullifier_5a',
        newSecret: 'secret_5a',
        recipient: _BOB,
        commitment: _commitment5,
        revertReason: NONE
      }),
      _batchData
    );

    // Call
    ProofLib.WithdrawProof[] memory _proofs = new ProofLib.WithdrawProof[](5);
    _proofs[0] = _proof1;
    _proofs[1] = _proof2;
    _proofs[2] = _proof3;
    _proofs[3] = _proof4;
    _proofs[4] = _proof5;

    IPrivacyPool.Withdrawal memory _withdrawal =
      IPrivacyPool.Withdrawal({processooor: address(_batchRelay), data: abi.encode(_batchData)});

    vm.prank(_RELAYER);
    _batchRelay.batchRelay(_ethPool, _withdrawal, _proofs);
  }
}

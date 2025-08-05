// SPDX-License-Identifier: Apache-2.0
pragma solidity ^0.8.0;

import {Entrypoint} from 'contracts/Entrypoint.sol';
import {IPrivacyPool} from 'contracts/PrivacyPool.sol';

import {PrivacyPoolComplex} from 'contracts/implementations/PrivacyPoolComplex.sol';
import {PrivacyPoolSimple} from 'contracts/implementations/PrivacyPoolSimple.sol';


import {Constants} from 'test/helper/Constants.sol';

import {IERC20} from '@oz/interfaces/IERC20.sol';
import {UnsafeUpgrades} from '@upgrades/Upgrades.sol';

import {HandlerActors} from './helpers/Actors.sol';

import {FuzzERC20} from './helpers/FuzzERC20.sol';
import {FuzzUtils, vm} from './helpers/FuzzUtils.sol';
import {GhostStorage} from './helpers/GhostStorage.sol';
import {MockVerifier} from './helpers/MockVerifier.sol';

contract Setup is HandlerActors, GhostStorage, FuzzUtils {
  MockVerifier internal mockVerifier;
  IERC20 internal token;
  Entrypoint internal entrypoint;
  IPrivacyPool internal nativePool;
  IPrivacyPool internal tokenPool;

  uint256 internal MIN_DEPOSIT = 1 ether;

  address internal OWNER = makeAddr('OWNER');
  address internal POSTMAN = makeAddr('POSTMAN');

  constructor() {
    mockVerifier = new MockVerifier();
    token = IERC20(address(new FuzzERC20()));

    address _impl = address(new Entrypoint());
    entrypoint = Entrypoint(
      payable(UnsafeUpgrades.deployUUPSProxy(_impl, abi.encodeCall(Entrypoint.initialize, (OWNER, POSTMAN))))
    );

    nativePool =
      IPrivacyPool(address(new PrivacyPoolSimple(address(entrypoint), address(mockVerifier), address(mockVerifier))));

    tokenPool = IPrivacyPool(
      address(new PrivacyPoolComplex(address(entrypoint), address(mockVerifier), address(mockVerifier), address(token)))
    );

    vm.prank(OWNER);
    entrypoint.registerPool(
      IERC20(Constants.NATIVE_ASSET), IPrivacyPool(nativePool), MIN_DEPOSIT, FEE_VETTING, MAX_RELAY_FEE
    );

    vm.prank(OWNER);
    entrypoint.registerPool(token, IPrivacyPool(tokenPool), MIN_DEPOSIT, FEE_VETTING, MAX_RELAY_FEE);

    vm.prank(POSTMAN);
    entrypoint.updateRoot(1, 'ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid_ipfs_cid');

    createNewActors(5);

    for (uint256 i = 0; i < actors.length; i++) {
      actors[i].call(address(token), 0, abi.encodeCall(IERC20.approve, (address(entrypoint), type(uint256).max)));
    }
  }
}

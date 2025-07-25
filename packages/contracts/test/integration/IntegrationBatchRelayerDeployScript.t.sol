// SPDX-License-Identifier: Apache-2.0
pragma solidity 0.8.28;

import {DeployBatchRelayer} from 'script/BatchRelayer.s.sol';
import {IBatchRelayer} from 'interfaces/IBatchRelayer.sol';
import {Test} from 'forge-std/Test.sol';

contract IntegrationBatchRelayerDeployScript is DeployBatchRelayer, Test {
    function setUp() public {
        vm.createSelectFork(vm.rpcUrl('mainnet'));
    }

    function test_deployScript() public {
        IBatchRelayer _batchRelayer = _deployBatchRelayer();

        assertEq(_batchRelayer.MAX_RELAY_FEE_BPS(), MAX_RELAY_FEE_BPS);
    }
}
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {MetaPools} from "../src/MetaPools.sol";

contract DeploySimpleStorate is Script {
    function run() external returns (MetaPools) {
        vm.startBroadcast();
        MetaPools metaPools = new MetaPools();
        vm.stopBroadcast();
        return metaPools;
    }
}

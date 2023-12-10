// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console2} from "forge-std/Script.sol";
import "../src/BitSplit.sol";

contract BitSplitScript is Script {
    BitSplit public bitSplit;

    function setUp() public {
        bitSplit = new BitSplit();
    }

    function run() public {
        vm.startBroadcast();
        address payable[] memory users = new address payable[](1);
        users[0] = payable(msg.sender);
        bitSplit.createGroup("TestGroup", users);

        string memory expenseName = "icecream";
        uint256 cost = 0.1 ether;
        address payable[] memory debtors = new address payable[](1);
        debtors[0] = payable(msg.sender);
        bitSplit.createExpense(0, expenseName, cost, debtors);

        uint256 expenseId = 0;
        BitSplit.Expense memory expense = bitSplit.getExpense(0, expenseId);
        uint256 amountToPay = expense.costSplit;

        bitSplit.pay{value: amountToPay}(0, expenseId);

        uint256 creditorBalance = bitSplit.balance(expense.creditor);
        require(
            creditorBalance >= amountToPay,
            "Creditor balance did not increase correctly"
        );

        BitSplit.Expense memory updatedExpense = bitSplit.getExpense(
            0,
            expenseId
        );
        bool isDebtorRemoved = true;
        for (uint256 i = 0; i < updatedExpense.debtors.length; i++) {
            if (updatedExpense.debtors[i] == msg.sender) {
                isDebtorRemoved = false;
                break;
            }
        }
        require(
            isDebtorRemoved,
            "Debtor was not removed from the debtors list"
        );

        console2.log("pay function works");
    }
}

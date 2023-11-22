// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {BitSplit} from "../src/BitSplit.sol";

contract BitSplitTest is Test {
    BitSplit public bitSplit;
    uint256 public constant START_BALANCE = 1 ether;
    address payable[] public  users;
    bytes32 internal nextUser = keccak256(abi.encodePacked("user address"));
    
    function getNextUserAddress() internal returns (address payable) {
        address payable user = payable(address(uint160(uint256(nextUser))));
        nextUser = keccak256(abi.encodePacked(nextUser));
        return user;
    }

    function createUsers(uint256 userNum) internal returns (address payable[] memory) {
        address payable[] memory user = new address payable[](userNum);
        for (uint256 i = 0; i < userNum; i++) {
            address payable _user = getNextUserAddress();
            vm.deal(_user, 10 ether);
            user[i] = _user;
        }
        return user;
    }

    function setUp() public {
        users = createUsers(5);
        bitSplit = new BitSplit();
    }

    function testCreateGroup() public {
        vm.prank(users[0]);
        address payable[] memory members = new address payable[](users.length - 1);
        for(uint i = 1; i < users.length; i++) {
            members[i - 1] = users[i];
        }
        bitSplit.createGroup("testGroup", members);

        string memory groupName = bitSplit.getGroupName(0);
        assertEq(groupName, "testGroup", "created group name does not match.");

        address payable[] memory groupMembers = bitSplit.getGroupMembers(0);
        assertEq(groupMembers.length, users.length, "member count doesn't match.");
        bool found = false;
        for(uint i = 0; i < users.length; i++) {
            for (uint j = 0; j < groupMembers.length; j++) {
                if (groupMembers[j] == users[i]) {
                    found = true;
                }
            }
            assertTrue(found, "group member doesn't match.");
            found = false;
        }
    }

    function testInviteMember() public {
        address payable[] memory group = new address payable[](3);
        for (uint256 i = 0; i < 3; i++) {
            group[i] = users[i];
        }

        vm.prank(users[0]);
        bitSplit.createGroup("testGroup", group);

        address payable newMember = users[3];

        vm.prank(users[0]);
        bitSplit.invite(0, newMember);

        address payable[] memory updatedGroupMembers = bitSplit.getGroupMembers(0);
        bool added = false;

        for (uint256 i = 0; i < updatedGroupMembers.length; i++) {
            if (updatedGroupMembers[i] == newMember) {
                added = true;
                break;
            }
        }

        assertTrue(added, "New member was not successfully added");
    }

    function testCreateExpense() public {
        vm.prank(users[0]);
        bitSplit.createGroup("TestGroup", users);

        string memory expenseName = "Buy UT Austin";
        uint256 cost = 500 ether;
        address payable[] memory debtors = new address payable[](2);
        debtors[0] = users[1];
        debtors[1] = users[2];

        vm.prank(users[0]); 
        bitSplit.createExpense(0, expenseName, cost, debtors);

        BitSplit.Expense memory newExpense = bitSplit.getExpense(0, 0);

        assertEq(newExpense.expenseName, expenseName, "Expense name is not the same");
        assertEq(newExpense.cost, cost, "Expense cost is not the same");
        assertEq(newExpense.creditor, users[0], "Expense creditor is not the same");
        assertEq(newExpense.debtors.length, debtors.length, "Expense debtors size is not the same");

        for (uint256 i = 0; i < debtors.length; i++) {
            assertEq(newExpense.debtors[i], debtors[i], "Expense debtor is not the same");
        }
    }
}

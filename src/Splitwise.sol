//SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

contract SplitwiseStorage {
    // @notice: Events for expenses
    struct Expense {
        uint256 expenseId;
        string expenseName;
        uint256 cost;
        address payable creditor;
        address payable[] debtors;
        mapping(address => uint256) amountOwed;
    }

    // @notice: Groups of users for IOUs
    struct Group {
        uint256 groupId;
        string groupName;
        address payable[] members;
        Expense[] expenses;
    }

    Group[] public groups;
}

contract Splitwise is SplitwiseStorage {
    // @notice: Creates new group for tracking IOUs
    // @params: User's wallet addresses or ENS
    function newGroup(address payable[] memory _members) public {}

    // @notice: Allows users to join pre-existing groups
    function invite() public {}

    // @notice: Creates new IOUs
    // @params: User's wallet address or ENS
    function newExpense() public {}

    // @notice: Allows users to reimburse group members
    // @params: User's wallet address or ENS
    function reimburse() public {}
}

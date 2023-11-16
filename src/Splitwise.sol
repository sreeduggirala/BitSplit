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

    event groupFormed(uint256 groupId, address[] members);
    event expenseMade(uint256 groupId, uint256 cost, address[] debtors);
    event reimbursed(address debtor, address creditor);
}

contract Splitwise is SplitwiseStorage {
    // @notice: Checks if given address is within the group of the given ID
    // @params: Group ID, an arbitrary wallet address
    modifier inGroup(uint256 _groupId, address payable _member) {
        bool isIn;
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _member) {
                isIn = true;
                break;
            }
        }

        if (isIn == false) {
            revert("Member is not in group");
        }
        _;
    }

    // @notice: Creates new group for tracking IOUs
    // @params: User's wallet addresses or ENS
    function newGroup(
        string memory _groupName,
        address payable[] memory _members
    ) public {}

    // @notice: Allows users to join pre-existing groups
    function invite(uint256 _groupId, address payable _invitee) public {
        bool isIn;
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _invitee) {
                isIn = true;
                revert("Member is already in group");
            }
        }

        groups[_groupId].members.push(_invitee);
    }

    // @notice: Creates new IOUs
    function newExpense(
        uint256 _groupId,
        string memory _expenseName,
        uint256 _cost,
        address payable[] memory _debtors
    ) public {}

    // @notice: Allows users to reimburse group members
    // @params: Group ID, member's wallet address or ENS
    function reimburse(
        uint256 _groupId,
        address payable _creditor
    ) public inGroup(_groupId, _creditor) {}
}

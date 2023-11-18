//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract SplitwiseStorage {
    // @notice: Expenses
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
        string groupName;
        address payable[] members;
        Expense[] expenses;
    }

    // @notice: Assigns group IDs
    mapping(uint256 => Group) groups;

    // @notice: Tracks total number of groups (to assign IDs)
    uint256 internal totalGroups;

    // @notice: Tracks global user balances
    mapping(address => uint256) balance;
}

contract Splitwise is SplitwiseStorage {
    // @notice: Checks if given address is within the group of the given ID
    // @params: Group ID, an arbitrary wallet address
    function inGroup(
        uint256 _groupId,
        address payable _member
    ) public view returns (bool) {
        bool isIn;
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _member) {
                isIn = true;
            }
        }

        return isIn;
    }

    // @notice: Creates new group for tracking IOUs
    // @params: Users' wallet addresses or ENS
    function newGroup(
        string memory _groupName,
        address payable[] memory _members
    ) public {}

    // @notice: Allows users to join pre-existing groups
    // @params: Group ID, invitee's wallet address or ENS
    function invite(uint256 _groupId, address payable _invitee) public {
        if (inGroup(_groupId, payable(msg.sender)) == false) {
            
        }  else if (inGroup(_groupId, payable(_invitee)) == true) {
            revert("Member already in group");
        }

        groups[_groupId].members.push(_invitee);
    }

    // @notice: Creates new IOUs
    // @params: Group ID, name of expense, magnitude of expense, list of debtors
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
        uint256 _expenseId,
        address payable _creditor
    ) public payable {
        if (inGroup(_groupId, _creditor) == false) {
            revert("User not in this group");
        } else if (
           balance[msg.sender] <
            groups[_groupId].expenses[_expenseId].amountOwed[msg.sender]
        ) {
            revert("Insufficient amount");
        }
    
        balance[_creditor] += msg.value;
        groups[_groupId].expenses[_expenseId].amountOwed[msg.sender] = 0;
    }

    // @notice: Allows users to deposit for in-app balances
    function deposit() public payable {
        balance[msg.sender] += msg.value;
    }

    // @notice: Allows users to withdraw in-app balances
    // @params: Amount to withdraw
    function withdraw(uint256 _amount) public {
        if (balance[msg.sender] < _amount || _amount < 0) {
            revert("Invalid amount");
        }
        balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
    }


}

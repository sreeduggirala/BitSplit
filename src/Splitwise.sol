//SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract SplitwiseStorage {
    // @notice: Expenses
    struct Expense {
        string expenseName;
        uint256 cost;
        address payable creditor;
        address payable[] debtors;
        uint256 costSplit;
        address payable[] paid;
    }

    // @notice: Groups of users for IOUs
    struct Group {
        string groupName;
        address payable[] members;
        Expense[] expenses;
    }

    // @notice: Assigns group IDs
    mapping(uint256 => Group) public groups;

    // @notice: Tracks total number of groups (to assign IDs)
    uint256 internal totalGroups;

    // @notice: Tracks global user balances
    mapping(address => uint256) public balance;
}

contract SplitwiseChecker is SplitwiseStorage {
    // @notice: Checks if inputted address is not address(0); for singular address
    // @params: Arbitrary wallet address
    modifier validAddress (address payable _member) {
        if (_member == payable(address(0))) {
            revert("Invalid address");
        }
        _;
    }
    
    // @notice: Checks if inputted address is not address(0); for multiple addresses
    // @params: Arbitrary wallet address
    modifier validAddresses (address payable[] memory _members) {
        for(uint256 i = 0; i < _members.length; i++) {
            if (_members[i] == payable(address(0))) {
                revert("Invalid address");
            }
        }
        _;
    }

    // @notice: Checks if given address is within the group of the given ID
    // @params: Group ID, an arbitrary wallet address
    function inGroup(
        uint256 _groupId,
        address payable _member
    ) public view returns (bool) {
        for (uint256 i = 0; i < groups[_groupId].members.length; i++) {
            if (groups[_groupId].members[i] == _member) {
                return true;
            }
        }
        return false;
    }

    // Create a mapping to track membership status
    mapping(address => bool) isInGroup;

    // @notice: Checks if given addresses are in the group of the given ID
    // @params: Group ID, arbitrary wallet addresses
    function areInGroup(
        uint256 _groupId, 
        address payable[] memory _members
    ) public returns (bool) {
        // Populate the mapping with the group's members
        address payable[] memory groupMembers = groups[_groupId].members;
        for (uint256 i = 0; i < groupMembers.length; i++) {
            isInGroup[groupMembers[i]] = true;
        }

        // Check if all given addresses are in the group
        for (uint256 j = 0; j < _members.length; j++) {
            if (!isInGroup[_members[j]]) {
                return false;
            }
        }

        return true; 
    }
}

contract Splitwise is SplitwiseChecker {
    // @notice: Creates new group for tracking IOUs
    // @params: Users' wallet addresses or ENS
    function createGroup(
        string memory _groupName,
        address payable[] memory _members
    ) public {
        if (bytes(_groupName).length == 0) {
            revert("Choose a longer name");
        } else if (_members.length < 1) {
            revert("Insufficient group members");
        }

        Group memory newGroup = Group({
            groupName: _groupName,
            members: _members,
            expenses: new Expense[](0)
        });

        totalGroups++;

        groups[totalGroups] = newGroup;
    }

    // @notice: Allows users to join pre-existing groups
    // @params: Group ID, invitee's wallet address or ENS
    function invite(uint256 _groupId, address payable _invitee) public {
        if (inGroup(_groupId, payable(_invitee)) == true) {
            revert("Member already in group");
        }

        groups[_groupId].members.push(_invitee);
    }

    // @notice: Creates new IOUs
    // @params: Group ID, name of expense, magnitude of expense, list of debtors
    function createExpense(
        uint256 _groupId,
        string memory _expenseName,
        uint256 _cost,
        address payable[] memory _debtors
    ) public {
        if (_groupId < 0 || _cost <= 0) {
            revert("Invalid group ID and/or cost");
        } else if (bytes(_expenseName).length == 0) {
            revert("Choose a longer name");
        } else if (_debtors.length < 1) {
            revert("Insufficient debtors");
        }

        Expense memory newExpense = Expense({
            expenseName: _expenseName,
            cost: _cost, 
            creditor: payable(msg.sender),
            debtors: _debtors,
            costSplit: _cost / (_debtors.length + 1),
            paid: new address payable[](0) 
        });

        groups[_groupId].expenses.push(newExpense);
    }

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
           msg.value <
            groups[_groupId].expenses[_expenseId].costSplit
        ) {
            revert("Insufficient amount");
        }
    
        balance[_creditor] += msg.value;

        // Adds msg.sender to array of those who paid
        groups[_groupId].expenses[_expenseId].paid.push(payable(msg.sender));

        // Finds index of msg.sender in debtors array
        address payable[] memory debtors = groups[_groupId].expenses[_expenseId].debtors;
        uint256 debtorIndex;
        for (uint256 i = 0; i < debtors.length; i++) {
            if (debtors[i] == payable(msg.sender)) {
                debtorIndex = i;
                break;
            }
        }

        // Deletes msg.sender from debtors array upon repayment
        groups[_groupId].expenses[_expenseId].debtors[debtorIndex] =  groups[_groupId].expenses[_expenseId].debtors[debtors.length - 1];
        groups[_groupId].expenses[_expenseId].debtors.pop(); 
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

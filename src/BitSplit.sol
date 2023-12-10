//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";

contract BitSplitStorage {
    // @notice: Expenses
    struct Expense {
        string expenseName;
        uint256 cost;
        address payable creditor;
        address payable[] debtors;
        uint256 costSplit;
        address payable[] paid;
    }

    // @notice: Groups of users for multi-person IOUs
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

    function getGroupName(
        uint256 _groupId
    ) public view returns (string memory) {
        return groups[_groupId].groupName;
    }

    function getGroupMembers(
        uint256 _groupId
    ) public view returns (address payable[] memory) {
        return groups[_groupId].members;
    }

    function getExpense(
        uint256 _groupId,
        uint256 _expenseId
    ) public view returns (Expense memory) {
        require(_groupId <= totalGroups, "Group does not exist");
        require(
            _expenseId <= groups[_groupId].expenses.length,
            "Expense does not exist"
        );

        return groups[_groupId].expenses[_expenseId];
    }
}

contract BitSplitChecker is BitSplitStorage {
    // @notice: Checks if inputted address is not address(0); for singular address
    // @params: Arbitrary wallet address
    modifier validAddress(address payable _member) {
        if (_member == payable(address(0))) {
            revert("Invalid address");
        }
        _;
    }

    // @notice: Checks if inputted address is not address(0); for multiple addresses
    // @params: Arbitrary wallet address
    modifier validAddresses(address payable[] memory _members) {
        for (uint256 i = 0; i < _members.length; i++) {
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

    // @notice: Tracks user's membership status
    mapping(address => bool) isInGroup;

    // @notice: Checks if given addresses are in the group of the given ID
    // @params: Group ID, arbitrary wallet addresses
    function areInGroup(
        uint256 _groupId,
        address payable[] memory _members
    ) public returns (bool) {
        bool result;

        // Populate the mapping with the group's members
        address payable[] memory groupMembers = groups[_groupId].members;
        for (uint256 i = 0; i < groupMembers.length; i++) {
            isInGroup[groupMembers[i]] = true;
        }

        // Check if all given addresses are in the group
        for (uint256 j = 0; j < _members.length; j++) {
            if (!isInGroup[_members[j]]) {
                result = false;
            }
        }

        // Reset isInGroup mapping
        for (uint256 i = 0; i < groupMembers.length; i++) {
            isInGroup[groupMembers[i]] = false;
        }

        result = true;
        return result;
    }

    event groupCreated(uint256 groupId, address payable[] members);
    event expenseCreated(
        uint256 groupId,
        uint256 expenseId,
        address creditor,
        address payable[] debtors
    );
    event invited(uint256 groupId, address invitee);
    event paid(address from, uint256 amount, address to);
    event withdrew(address user, uint256 amount);
}

contract BitSplit is BitSplitChecker, Ownable {
    constructor() Ownable(msg.sender) {}

    // @notice: Creates new group for tracking IOUs
    // @params: Users' wallet addresses or ENS
    function createGroup(
        string memory _groupName,
        address payable[] memory _members
    ) public validAddresses(_members) {
        if (bytes(_groupName).length == 0) {
            revert("Choose a longer name");
        } else if (_members.length < 1) {
            revert("Insufficient group members");
        }

        Group storage newGroup = groups[totalGroups];
        newGroup.groupName = _groupName;
        newGroup.members = _members;
        newGroup.members.push(payable(msg.sender));
        totalGroups++;

        emit groupCreated(totalGroups, newGroup.members);
    }

    // @notice: Allows users to join pre-existing groups
    // @params: Group ID, invitee's wallet address or ENS
    function invite(uint256 _groupId, address payable _invitee) public {
        if (inGroup(_groupId, payable(_invitee)) == true) {
            revert("Member already in group");
        }

        groups[_groupId].members.push(_invitee);
        emit invited(_groupId, payable(_invitee));
    }

    // @notice: Creates new IOUs
    // @params: Group ID, name of expense, magnitude of expense, list of debtors
    function createExpense(
        uint256 _groupId,
        string memory _expenseName,
        uint256 _cost,
        address payable[] memory _debtors
    ) public validAddresses(_debtors) {
        if (_groupId < 0 || _cost <= 0) {
            revert("Invalid group ID and/or cost");
        } else if (bytes(_expenseName).length == 0) {
            revert("Choose a longer name");
        } else if (_debtors.length < 1) {
            revert("Insufficient debtors");
        }

        Expense storage newExpense = groups[_groupId].expenses.push();
        newExpense.expenseName = _expenseName;
        newExpense.cost = _cost;
        newExpense.creditor = payable(msg.sender);
        newExpense.debtors = _debtors;
        newExpense.costSplit = _cost / (_debtors.length + 1);

        emit expenseCreated(
            _groupId,
            groups[_groupId].expenses.length - 1,
            payable(msg.sender),
            newExpense.debtors
        );
    }

    // @notice: Allows users to reimburse group members
    // @params: Group ID, member's wallet address or ENS
    function pay(uint256 _groupId, uint256 _expenseId) public payable {
        if (msg.value != groups[_groupId].expenses[_expenseId].costSplit) {
            revert("Insufficient amount");
        }

        balance[groups[_groupId].expenses[_expenseId].creditor] +=
            (msg.value * 98) /
            100;

        // Adds msg.sender to array of those who paid
        groups[_groupId].expenses[_expenseId].paid.push(payable(msg.sender));

        // Finds index of msg.sender in debtors array
        address payable[] memory debtors = groups[_groupId]
            .expenses[_expenseId]
            .debtors;
        uint256 debtorIndex;
        for (uint256 i = 0; i < debtors.length; i++) {
            if (debtors[i] == payable(msg.sender)) {
                debtorIndex = i;
                break;
            }
        }

        // Deletes msg.sender from debtors array upon repayment
        groups[_groupId].expenses[_expenseId].debtors[debtorIndex] = groups[
            _groupId
        ].expenses[_expenseId].debtors[debtors.length - 1];
        groups[_groupId].expenses[_expenseId].debtors.pop();
        emit paid(
            payable(msg.sender),
            msg.value,
            payable(groups[_groupId].expenses[_expenseId].creditor)
        );
    }

    // @notice: Allows users to withdraw in-app balances
    // @params: Amount to withdraw
    function withdraw(uint256 _amount) public {
        if (balance[msg.sender] < _amount || _amount < 0) {
            revert("Invalid amount");
        }
        balance[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit withdrew(payable(msg.sender), _amount);
    }

    // @notice: Allows contract owner to withraw platform fees
    function collectFees() public onlyOwner {
        if (balance[owner()] == 0) {
            revert("No available balance");
        }

        payable(owner()).transfer(balance[owner()]);
        emit withdrew(payable(owner()), balance[owner()]);

        balance[owner()] = 0;
    }

    function renounceOwnership() public virtual override onlyOwner {
        revert("Function disabled");
    }
}
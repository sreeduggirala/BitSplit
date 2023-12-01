//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import { IRouterClient } from "src/node_modules/@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import { OwnerIsCreator } from "lib/chainlink/contracts/src/v0.8/shared/access/OwnerIsCreator.sol";
import { Client } from "src/node_modules/@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import { IERC20 } from "lib/chainlink/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.0/contracts/token/ERC20/IERC20.sol";

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

contract BitSplitCCIP is OwnerIsCreator {

    // descriptive errors
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); 
    error NothingToWithdraw(); 
    error FailedToWithdrawEth(address owner, address target, uint256 value); 
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); 

    // Event emitted when the tokens are transferred to an account on another chain.
    event TokensTransferred(
        bytes32 indexed messageId, 
        uint64 indexed destinationChainSelector, 
        address receiver, 
        address token,
        uint256 tokenAmount,
        address feeToken, 
        uint256 fees 
    );

    // Mapping to keep track of allowlisted destination chains.
    mapping(uint64 => bool) public allowlistedChains;

    IRouterClient private s_router;

    IERC20 private s_linkToken;

    /// @notice Constructor initializes the contract with the router address.
    /// @param _router The address of the router contract.
    /// @param _link The address of the link contract.
    constructor(address _router, address _link) {
        s_router = IRouterClient(_router);
        s_linkToken = IERC20(_link);

        // Hardcodes Polygon Mumbai testnet into allowlistedChains
        allowlistedChains[12532609583862916517] = true;
        // Hardcodes Avalanche Fuji testnet into allowlistedChains
        allowlistedChains[14767482510784806043] = true;
    }

    /// @dev Modifier that checks if the chain with the given destinationChainSelector is allowlisted.
    /// @param _destinationChainSelector The selector of the destination chain.
    modifier onlyAllowlistedChain(uint64 _destinationChainSelector) {
        if (!allowlistedChains[_destinationChainSelector])
            revert DestinationChainNotAllowlisted(_destinationChainSelector);
        _;
    }

    /// @dev Updates the allowlist status of a destination chain for transactions.
    /// @notice This function can only be called by the owner.
    /// @param _destinationChainSelector The selector of the destination chain to be updated.
    /// @param allowed The allowlist status to be set for the destination chain.
    function allowlistDestinationChain(
        uint64 _destinationChainSelector,
        bool allowed
    ) external onlyOwner {
        allowlistedChains[_destinationChainSelector] = allowed;
    }

    /// @notice Transfer tokens to receiver on the destination chain.
    /// @notice pay in LINK.
    /// @notice the token must be in the list of supported tokens.
    /// @notice This function can only be called by the owner.
    /// @dev Assumes your contract has sufficient LINK tokens to pay for the fees.
    /// @param _destinationChainSelector The identifier (aka selector) for the destination blockchain.
    /// @param _receiver The address of the recipient on the destination blockchain.
    /// @param _token token address.
    /// @param _amount token amount.
    /// @param _payFeesIn address of what to pay fees in, 0 for ETH, 1 for Link
    /// @return messageId The ID of the message that was sent.
    function transferTokensPay(
        uint64 _destinationChainSelector,
        address _receiver,
        address _token,
        uint256 _amount,
        uint256 _payFeesIn
    )
        external
        onlyOwner
        onlyAllowlistedChain(_destinationChainSelector)
        returns (bytes32 messageId)
    {
        address _feePayment = _payFeesIn == 1 ? address(s_linkToken) : address(0);
        // Create an EVM2AnyMessage struct in memory with necessary information for sending
        // a cross-chain message address (linkToken) means fees are paid in LINK
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(
            _receiver,
            _token,
            _amount,
            _feePayment
        );

        // Get the fee required to send the message
        uint256 fees = s_router.getFee(
            _destinationChainSelector,
            evm2AnyMessage
        );
        // check if enough fees
        if (_feePayment == address(s_linkToken)) {
            if (fees > s_linkToken.balanceOf(address(s_linkToken))) {
                revert NotEnoughBalance(s_linkToken.balanceOf(address(s_linkToken)), fees);
            }
        } else {
            if (fees > address(0).balance) {
                revert NotEnoughBalance(address(0).balance, fees);
            }
        }

        // approve the Router to transfer LINK tokens on contract's behalf. 
        // It will spend the fees in LINK
        s_linkToken.approve(address(s_router), fees);
        // approve the Router to spend tokens on contract's behalf. 
        // It will spend the amount of the given token
        IERC20(_token).approve(address(s_router), _amount);

        // Send the message through the router and store the returned message ID
        messageId = s_router.ccipSend(
            _destinationChainSelector,
            evm2AnyMessage
        );

        // Emit an event with message details
        emit TokensTransferred(
            messageId,
            _destinationChainSelector,
            _receiver,
            _token,
            _amount,
            _feePayment,
            fees
        );

        // Return the message ID
        return messageId;
    }

    /// @notice Construct a CCIP message.
    /// @dev This function will create an EVM2AnyMessage struct with all the necessary information for tokens transfer.
    /// @param _receiver The address of the receiver.
    /// @param _token The token to be transferred.
    /// @param _amount The amount of the token to be transferred.
    /// @param _feeTokenAddress The address of the token used for fees. Set address(0) for native gas.
    /// @return Client.EVM2AnyMessage Returns an EVM2AnyMessage struct which contains information for sending a CCIP message.
    function _buildCCIPMessage(
        address _receiver,
        address _token,
        uint256 _amount,
        address _feeTokenAddress
    ) internal pure returns (Client.EVM2AnyMessage memory) {
        // Set the token amounts
        Client.EVMTokenAmount[]
            memory tokenAmounts = new Client.EVMTokenAmount[](1);
        tokenAmounts[0] = Client.EVMTokenAmount({
            token: _token,
            amount: _amount
        });

        // Create an EVM2AnyMessage struct in memory with necessary information for sending a cross-chain message
        return
            Client.EVM2AnyMessage({
                receiver: abi.encode(_receiver), // ABI-encoded receiver address
                data: "", // No data
                tokenAmounts: tokenAmounts, // The amount and type of token being transferred
                extraArgs: Client._argsToBytes(
                    // Additional arguments, setting gas limit to 0 as we are not sending any data and non-strict sequencing mode
                    Client.EVMExtraArgsV1({gasLimit: 0, strict: false})
                ),
                // Set the feeToken to a feeTokenAddress, indicating specific asset will be used for fees
                feeToken: _feeTokenAddress
            });
    }

    /// @notice Fallback function to allow the contract to receive Ether.
    /// @dev This function has no function body, making it a default function for receiving Ether.
    /// It is automatically called when Ether is transferred to the contract without any data.
    receive() external payable {}

    /// @notice Allows the contract owner to withdraw the entire balance of Ether from the contract.
    /// @dev This function reverts if there are no funds to withdraw or if the transfer fails.
    /// It should only be callable by the owner of the contract.
    /// @param _beneficiary The address to which the Ether should be transferred.
    function withdraw(
        address _beneficiary
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = address(this).balance;

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        // Attempt to send the funds, capturing the success status and discarding any return data
        (bool sent, ) = _beneficiary.call{value: amount}("");

        // Revert if the send failed, with information about the attempted transfer
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice Allows the owner of the contract to withdraw all tokens of a specific ERC20 token.
    /// @dev This function reverts with a 'NothingToWithdraw' error if there are no tokens to withdraw.
    /// @param _beneficiary The address to which the tokens will be sent.
    /// @param _token The contract address of the ERC20 token to be withdrawn.
    function withdrawToken(
        address _beneficiary,
        address _token
    ) public onlyOwner {
        // Retrieve the balance of this contract
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // Revert if there is nothing to withdraw
        if (amount == 0) revert NothingToWithdraw();

        IERC20(_token).transfer(_beneficiary, amount);
    }
}

contract BitSplit is BitSplitChecker, Ownable, BitSplitCCIP {
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
    function pay(uint256 _groupId, uint256 _expenseId, uint64 _destinationChainSelector, address _token, uint256 _payFeesIn) public payable {
        if (msg.value != groups[_groupId].expenses[_expenseId].costSplit) {
            revert("Insufficient amount");
        }

        transferTokensPay(
            _destinationChainSelector,
            balance[groups[_groupId].expenses[_expenseId].creditor],
            _token,
            (msg.value * 98) / 100,
            _payFeesIn
        );

        // updates group arrays
        updateGroup(_groupId, _expenseId);
    }

    function updateGroup(uint256 _groupId, uint256 _expenseId) public view {
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

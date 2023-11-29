const express = require('express')
const bodyParser = require('body-parser');
const app = express()
const port = 3001

app.use(bodyParser.json());


// Create Group Endpoint
app.post('/createGroup', (req, res) => {
    const {groupName, members} = req.body;
    if (!groupName || !members || members.length < 1) {
        res.status(400).json({success: false, message: 'You must provide a group name and at least one member'})
    }

    //handle create group;
    res.status(200).json({success: true, message: 'Group Name: ' + groupName + ' Members: ' + members})

})

// Add Friend Endpoint
app.post('/addFriend', (req, res) => {
    const { contactName, friendAddress } = req.body;
  
    if (!friendAddress || !contactName) {
      return res.status(400).json({ success: false, message: 'You must provide a friend address and name' });
    }
  
    res.status(200).json({ success: true, message: `Friend ${contactName} added with address ${friendAddress}` });
});

// Add Friend to Group Endpoint
app.post('/addFriendToGroup', (req, res) => {
    const { groupId, friendAddress } = req.body;
  
    if (!friendAddress) {
      return res.status(400).json({ success: false, message: 'You must provide a friend address' });
    }
  
    // handle adding a friend to the group with groupId
    // may need to validate if the group exists, and the friend is not already in the group
  
    res.status(200).json({ success: true, message: `Friend ${friendAddress} added to Group ${groupId}` });
});

// Add Expense Endpoint
app.post('/addExpense', (req, res) => {
    const { groupId, expenseName, cost } = req.body;
  
    if (!expenseName || !cost || cost <= 0 ) {
      return res.status(400).json({ success: false, message: 'Invalid expense details' });
    }
  
    // Handle adding an expense to the group with groupId
  
    res.status(200).json({ success: true, message: `Expense ${expenseName} with amount ${cost} added to Group ${groupId}` });
});

//Get Amount Owed Endpoint
app.get('/getAmountYouAreOwed', (req, res) => {
    // Handle getting the amount owed for the group with groupId
    
    const amount = 10; // replace this with the amount owed
  
    res.status(200).json({ success: true, amount});
});

//Get Amount You Owe Endpoint
app.get('/getAmountYouOwe', (req, res) => {
    // Handle getting the amount you owe for the group with groupId

    const amount = 10; // replace this with the amount you owe
  
    res.status(200).json({ success: true, amount});
});

// Get Friends Endpoint
app.get('/getFriends', (req, res) => {
    // Return a list of friends
  
    const friends = ["friend1", "friend2"]; // replace this with your list of friends

    res.status(200).json({ success: true, friends });
});

// Get Groups Endpoint
app.get('/getGroups', (req, res) => {
    // Return a list of groups
  
    const groups = ["group1", "group2"]; // replace this with your list of groups

    res.status(200).json({ success: true, groups });
});


app.get('/', (req, res) => {
  res.send('Hello World!')
})

app.listen(port, () => {
  console.log(`Listening on port ${port}`)
})
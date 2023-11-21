import React, { useState, useEffect } from 'react';
import Head from 'next/head';
import NavBar from '../components/NavBar';
import CreateGroupModal from '../components/CreateGroupModal';
import AddFriendModal from '../components/AddFriendModal';
import AddExpenseModal from '../components/AddExpenseModal';
import Balances from '../components/Balances';
import YouOwe from '../components/YouOwe';
import YouAreOwed from '../components/YouAreOwed';

const Home = () => {

  const [showCreateGroupModal, setShowCreateGroupModal] = useState(false);
  const [showAddFriendModal, setShowAddFriendModal] = useState(false);
  const [showAddExpenseModal, setShowAddExpenseModal] = useState(false);

  const handleCreateGroup = (groupName, friends) => {
    console.log("Group Name: " + groupName);
    console.log("Friends: " + friends);
  };

  const handleAddFriend = (friendName, friendAddress) => {
    console.log("Friend Name: " + friendName);
    console.log("Friend Address: " + friendAddress);
  };

  const handleAddExpense = () => {
    console.log("Add Expense");
  };

  return (
    <div>
      <Head>
        <title>BitWise</title>
        <meta
          content="SplitWise, but with Crypto."
          name="description"
        />
        <link href="/favicon.ico" rel="icon" />
      </Head>

      <div className={' h-screen w-screen bg-blue-200 flex flex-col justify-start items-center ' + ((showCreateGroupModal || showAddFriendModal || showAddExpenseModal) ? 'blur-md' : "")}>
        <NavBar />
        <div className=' w-4/5 h-full flex flex-col justify-start text-sm py-2 rounded-2xl my-4 bg-blue-300'>
          <div className='flex justify-between items-center p-4 px-16'>
            <h1 className=' text-4xl font-bold text-left '>Dashboard</h1>
            <div className=' flex'>
              <button className='bg-blue-500 hover:bg-blue-700 hover:scale-110 text-white font-bold py-2 px-4 rounded-lg mx-2 text-xl transition' onClick={() => setShowCreateGroupModal(true)}>
                Create Group
              </button>
              <button className='bg-blue-500 hover:bg-blue-700 hover:scale-110 text-white font-bold py-2 px-4 rounded-lg mx-2 text-xl transition' onClick={() => setShowAddFriendModal(true)}>
                Add Friend
              </button>
              <button className='bg-blue-500 hover:bg-blue-700 hover:scale-110 text-white font-bold py-2 px-4 rounded-lg mx-2 text-xl transition' onClick={() => setShowAddExpenseModal(true)}>
                Add Expense
              </button>
            </div>
          </div>
          <div className='flex justify-center items-center'>
            <hr className=" w-[97%] border-blue-500 border-2 rounded-sm mb-6"></hr>
          </div>
          <div className='w-full h-full flex justify-center items-center'>
            <div className=' w-4/5 h-full flex flex-col justify-center items-center'>
              <Balances />
              <div className='w-full h-full flex justify-center items-center'>
                <div className=' w-1/2 h-full p-4'>
                  <YouOwe />
                </div>
                <div className=' w-1/2 h-full p-4'>
                  <YouAreOwed />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      {showCreateGroupModal ? <CreateGroupModal setShow={setShowCreateGroupModal} handler={handleCreateGroup} /> : null}
      {showAddExpenseModal ? <AddExpenseModal setShow={setShowAddExpenseModal} handler={handleAddExpense} /> : null}
      {showAddFriendModal ? <AddFriendModal setShow={setShowAddFriendModal} handler={handleAddFriend} /> : null}
    </div>
  );
};

export default Home;

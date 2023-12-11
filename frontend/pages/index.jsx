import React, { useState, useEffect } from "react";
import Head from "next/head";
import NavBar from "../components/NavBar";
import CreateGroupModal from "../components/CreateGroupModal";
import AddFriendModal from "../components/AddFriendModal";
import AddExpenseModal from "../components/AddExpenseModal";
import Balances from "../components/Balances";
import InfoBox from "../components/InfoBox";
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";

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

  const handleAddExpense = (group, expenseName, expenseAmount) => {
    console.log("Group: " + group);
    console.log("Expense Name: " + expenseName);
    console.log("Expense Amount: " + expenseAmount);
  };

  return (
    <div>
      <Head>
        <title>BitWise</title>
        <meta content="SplitWise, but with Crypto." name="description" />
        <link href="/favicon.ico" rel="icon" />
      </Head>

      <div
        className={
          " h-screen w-screen bg-blue-200 flex flex-col justify-start items-center " +
          (showCreateGroupModal || showAddFriendModal || showAddExpenseModal
            ? "blur-md opacity-60"
            : "")
        }
      >
        <NavBar />
        <div className=" w-4/5 h-full flex flex-col justify-start text-sm py-2 rounded-2xl my-4 bg-blue-300">
          <div className="flex justify-around items-center p-4 mx-max-20">
            <h1 className="hidden md:block md:text-3xl md:font-bold md:text-left md:pr-8">
              Dashboard
            </h1>

            <Stack direction="row" spacing={2}>
              <Button
                className="transition bg-blue-700"
                size="large"
                variant="contained"
                onClick={() => setShowCreateGroupModal(true)}
              >
                Create Group
              </Button>
              <Button
                className=" bg-blue-700"
                size="large"
                variant="contained"
                onClick={() => setShowAddFriendModal(true)}
              >
                Add Friend
              </Button>
              <Button
                className=" bg-blue-700"
                size="large"
                variant="contained"
                onClick={() => setShowAddExpenseModal(true)}
              >
                Add Expense
              </Button>
            </Stack>
          </div>
          <div className="flex justify-center items-center">
            <hr className=" w-full border-blue-900 border-2 rounded-sm "></hr>
          </div>
          <div className="w-full h-full flex justify-center items-center">
            <div className=" w-full h-full flex flex-col justify-center items-center">
              <Balances />
              <div className="w-full my-6 h-full flex flex-col md:flex-row justify-center items-center">
                <div className="w-full h-full p-4">
                  <InfoBox />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      {showCreateGroupModal ? (
        <CreateGroupModal
          setShow={setShowCreateGroupModal}
          handler={handleCreateGroup}
        />
      ) : null}
      {showAddExpenseModal ? (
        <AddExpenseModal
          setShow={setShowAddExpenseModal}
          handler={handleAddExpense}
        />
      ) : null}
      {showAddFriendModal ? (
        <AddFriendModal
          setShow={setShowAddFriendModal}
          handler={handleAddFriend}
        />
      ) : null}
    </div>
  );
};

export default Home;

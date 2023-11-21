import React, { useState, useEffect } from "react";

const Balances = () => {
  const [youOwe, setYouOwe] = useState(0);
  const [youAreOwed, setYouAreOwed] = useState(0);
  const [totalBalance, setTotalBalance] = useState(0);

  useEffect(() => {
    //TODO: replace from data from backend
    var owe = 1000;
    var owed = 500;
    setYouOwe(owe);
    setYouAreOwed(owed);
    setTotalBalance(owed - owe);
  }, []);

  return (
    <div className="w-full h-1/4 flex justify-evenly items-center bg-blue-900 ">
      <div className="  h-full  rounded-xl flex flex-col justify-center items-center ">
        <h1 className=" text-2xl py-3 font-semibold  text-white">You Owe</h1>
        <p className={" text-4xl pb-3 font-bold text-red-600"}>{youOwe}</p>
      </div>
      <div className=" h-full ml-6 m-3 rounded-xl flex flex-col justify-center items-center ">
        <h1 className=" text-2xl py-3 font-semibold  text-white">
          Total Balance
        </h1>
        <p
          className={
            "text-6xl pb-3 font-bold " +
            (totalBalance < 0 ? "text-red-600" : "text-green-400 ")
          }
        >
          {totalBalance}
        </p>
      </div>

      <div className="  h-full mr-6 m-3 rounded-xl flex flex-col justify-center items-center ">
        <h1 className=" text-2xl py-3 font-semibold  text-white ">
          You Are Owed
        </h1>
        <p className={"text-4xl  pb-3 font-bold text-green-400 "}>
          {youAreOwed}
        </p>
      </div>
    </div>
  );
};

export default Balances;

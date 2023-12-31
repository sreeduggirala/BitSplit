import React, {useState, useEffect} from 'react'
import InputPill from './InputPill'
import SelectBox from './SelectBox'

const AddExpenseModal = ({setShow, handler}) => {

    const [selectedGroup, setSelectedGroup] = useState('');
    const [expenseName, setExpenseName] = useState('');
    const [expenseAmount, setExpenseAmount] = useState('');

    const [groups, setGroups] = useState([]);

    useEffect(() => {
      //TODO: replace from data from backend
      var userGroups = [];
      for(var i=0; i<5; i++){
        userGroups.push("Group " + i);
      };
      setGroups(userGroups);
    }, []);

    const handleSubmit = () => {
      handler(selectedGroup, expenseName, expenseAmount);
      setShow(false);
    }

    return (
        <div className="w-full h-full fixed top-0 start-0 z-[60] overflow-x-hidden overflow-y-auto ">
            <div className="mt-7 opacity-100 duration-500 ease-out transition-all sm:max-w-lg sm:w-full m-3 sm:mx-auto min-h-[calc(100%-3.5rem)] flex items-center">
                <div className="w-full flex flex-col bg-white border shadow-sm rounded-xl ">
                    <div className="flex justify-between items-center py-3 px-4 border-blue-400 border-b-2 border-dotted">
                        <div className='w-7'/>
                        <h3 className=" text-3xl font-bold text-gray-800">
                            Add An Expense
                        </h3>
                        <button type="button" className="flex justify-center items-center w-7 h-7 text-sm font-semibold rounded-full border border-transparent text-gray-800 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none" onClick={() => setShow(false)} >
                            <span className="sr-only">Close</span>
                            <svg className="flex-shrink-0 w-4 h-4" xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M18 6 6 18"/><path d="m6 6 12 12"/></svg>
                        </button>
                    </div>
                    <div className="p-4 overflow-y-auto">
                        <SelectBox title="Select Group" options={groups} setSelected={setSelectedGroup}/>
                        <InputPill title="Enter Expense Name" placeholder="Groceries" setState={setExpenseName} inputType="text"/>
                        <InputPill title="Enter Expense Amount" placeholder="1 ETH" setState={setExpenseAmount} inputType="text"/>
                    </div>
                    <div className="flex justify-end items-center gap-x-2 py-3 px-4">
                        <button type="button" className="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-medium rounded-lg border border-gray-200 bg-white text-gray-800 shadow-sm hover:bg-gray-50 disabled:opacity-50 disabled:pointer-events-none " onClick={() => setShow(false)}>
                            Close
                        </button>
                        <button type="button" className="py-2 px-3 inline-flex items-center gap-x-2 text-sm font-semibold rounded-lg border border-transparent bg-blue-600 text-white hover:bg-blue-700 disabled:opacity-50 disabled:pointer-events-none" onClick={handleSubmit}>
                            Add Friend
                        </button>
                    </div>
                </div>
            </div>
        </div>
    );
}

export default AddExpenseModal
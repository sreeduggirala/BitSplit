import React, { useState } from 'react';
import GroupOptions from "../components/GroupOptions";
import ExpenseOptions from "../components/ExpenseOptions";

const InfoBox = () => {
  const [selectedGroup, setSelectedGroup] = useState(null);

  // Dummy data for expenses, replace this with your actual data
  const expensesByGroup = {
    'Group 1': ['Expense 1', 'Expense 2'],
    'Group 2': ['Expense 3', 'Expense 4'],
    'Group 3': ['Expense 5', 'Expense 6'],
  };

  const handleSelectGroup = (group) => {
    setSelectedGroup(group);
  };

  return (
    <div className='w-full h-60 bg-gray-50 flex flex-row'>
        <div className="w-full p-4 overflow-y-auto">
          <GroupOptions onSelectGroup={handleSelectGroup} />
        </div>
        <div className="w-full p-4 overflow-y-auto">
            {selectedGroup && (
              <ExpenseOptions expenses={expensesByGroup[selectedGroup]} />
            )}
          </div>
    </div>
  )
}

export default InfoBox
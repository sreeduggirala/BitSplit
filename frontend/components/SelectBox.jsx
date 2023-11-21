import React from 'react'

const SelectBox = ({title, options, setSelected}) => {
  return (
    <div>
        <label className="block text-lg font-semibold mb-2 text-black ">{title}</label>
        <select className="py-3 px-4 pe-9 block w-full border shadow-lg border-stone-300 rounded-full text-sm " onChange={(e) => setSelected(e.target.value)}>
            <option selected>Select Your Group</option>
            {options.map((option) => (
                <option key={option}>{option}</option>
            ))}
        </select>
    </div>
    
  )
}

export default SelectBox
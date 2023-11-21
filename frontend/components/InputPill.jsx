import React from 'react'

const InputPill = ({title, placeholder, setState, inputType}) => {
  return (
    <div className="my-4">
        <label className="block text-lg font-semibold mb-2 text-black dark:text-white">{title}</label>
        <input type={inputType} className="py-3 px-4 block w-full border border-stone-300 rounded-full text-sm shadow-lg" 
             onChange={(e) => setState(e.target.value)}  placeholder={placeholder}
        />
    </div>
  )
}

export default InputPill;
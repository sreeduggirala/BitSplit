import React, {useState} from 'react'
import ScrollableContent from './ScrollableContent'

const CheckboxList = ({title, list, updateSelected}) => {

  return (
    <div>
        <label className="block text-lg font-semibold py-3 mb-2 text-black dark:text-white">{title}</label>
        <ScrollableContent>
            <ul className="flex flex-col pr-2 ">
                {list.map((item, index) => <CheckboxItem name={item} key={index} index={index} changeSelected={updateSelected}/>)}
            </ul>
        </ScrollableContent>
    </div>
  )
}

const CheckboxItem = ({name, changeSelected, index}) => {
    const [checked, setChecked] = useState(false);
    
    const updateValue = () => {
        changeSelected(index, !checked);
        setChecked(!checked);
    }


    return (
        <li className="inline-flex items-center gap-x-2 py-3 px-4 text-sm font-medium bg-white border text-gray-800 -mt-px 
            first:rounded-t-2xl first:mt-0 last:rounded-b-2xl last:mb-0 border-x-gray-500 first:border-t-gray-500 last:border-b-gray-500">
            <div className="relative flex items-start w-full">
                <div className="flex items-center h-5">
                    <input type="checkbox" className="border-gray-200 rounded " checked={checked} onChange={updateValue}/>
                </div>
                <label className="ml-3.5 block w-full text-sm text-gray-600">
                    {name}
                </label> 
            </div>
        </li>
    )
}

export default CheckboxList
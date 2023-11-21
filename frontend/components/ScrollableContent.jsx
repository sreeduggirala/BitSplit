import React from 'react'

const ScrollableContent = ({children}) => {
  return (
    <div className='max-h-[400px] overflow-y-auto
    [&::-webkit-scrollbar]:w-2
    [&::-webkit-scrollbar-track]:rounded-full
    [&::-webkit-scrollbar-track]:bg-gray-100
    [&::-webkit-scrollbar-thumb]:rounded-full
    [&::-webkit-scrollbar-thumb]:bg-gray-300
    dark:[&::-webkit-scrollbar-track]:bg-slate-700
    dark:[&::-webkit-scrollbar-thumb]:bg-slate-500'>
        {children}
    </div>
  )
}

export default ScrollableContent
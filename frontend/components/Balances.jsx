import React, {useState, useEffect} from 'react'

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
        setTotalBalance(owed-owe);
    }, []);

    return (
        <div className='w-full h-1/4 flex justify-between items-center'>
            <div className=' w-1/3 h-full ml-6 m-3 rounded-xl bg-blue-500 flex flex-col justify-center items-center border-2 border-blue-600'>
                <h1 className=' text-2xl py-3 font-semibold underline text-black'>Total Balance</h1>
                <p className={'text-2xl  pb-3 font-bold ' + (totalBalance < 0 ? 'text-red-600' : 'text-green-400 ')}>{totalBalance}</p>
            </div>
            <div className=' w-1/3 h-full m-3 rounded-xl bg-blue-500 flex flex-col justify-center items-center border-2 border-blue-600'>
                <h1 className=' text-2xl py-3 font-semibold underline text-black'>You Owe</h1>
                <p className={'text-2xl  pb-3 font-bold text-red-600'}>{youOwe}</p>
            </div>
            <div className=' w-1/3 h-full mr-6 m-3 rounded-xl bg-blue-500 flex flex-col justify-center items-center border-2 border-blue-600'>
                <h1 className=' text-2xl py-3 font-semibold underline text-black'>You Are Owed</h1>
                <p className={'text-2xl  pb-3 font-bold text-green-400 '}>{youAreOwed}</p>
            </div>

        </div>
    )
}

export default Balances
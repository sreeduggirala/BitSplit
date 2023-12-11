import React, { useState, useEffect } from 'react';
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";
import { ethers } from 'ethers';
import BitSplitABI from '../../out/BitSplit.sol/BitSplit.json';

const CONTRACT_ADDRESS_POLYGON_MUMBAI = 0x9f4cC6B5bE263a304006F678AC943C49a75CDEC6;
const CONTRACT_ADDRESS_POLYGON_ZKEVM = 0x26c2a3eb005f99db89d1ae160a53d5e96a82d937;
const CONTRACT_ADDRESS_AVA_FUJI = 0xEB368B0a9364c6Fb214150515C230fd06765Aa58;

const GroupOptions = ({ onSelectGroup }) => {
    const [bitSplitContract, setBitSplitContract] = useState(null);
    const groups = ['Group 1', 'Group 2', 'Group 3'];
    const [selectedGroup, setSelectedGroup] = useState(null);

    useEffect(() => {
        if (window.ethereum) {
            const provider = new ethers.providers.Web3Provider(window.ethereum);
            const contract = new ethers.Contract(CONTRACT_ADDRESS_POLYGON_MUMBAI, BitSplitABI.abi, provider.getSigner());
            setBitSplitContract(contract);
        } else {
            console.log('Please install MetaMask!');
        }
    }, []);

    const handleGroupClick = async (group) => {
        setSelectedGroup(group);
        onSelectGroup(group); 
    };

    useEffect(() => {
        const fetchExpenseIDs = async () => {
            if (bitSplitContract && selectedGroup) {
                const provider = new ethers.providers.Web3Provider(window.ethereum);
                const signer = provider.getSigner();
                const address = await signer.getAddress();
                const expenseIDArray = await bitSplitContract.getExpenses(address);
                setExpenseIDs(expenseIDArray);
            }
        };

        fetchExpenseIDs();
    }, [bitSplitContract, selectedGroup]);

    

    return (
        <Stack direction="column" spacing={2}>
            {groups.map((group) => (
                <Button
                    key={group}
                    className={`transition bg-blue-700 ${group === selectedGroup && 'bg-blue-900'}`}
                    size="large"
                    variant="contained"
                    onClick={() => handleGroupClick(group)}
                    >
                    {group}
                </Button>
            ))}
        </Stack>
    )
}

export default GroupOptions
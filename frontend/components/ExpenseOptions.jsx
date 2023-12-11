import React from 'react'
import Button from "@mui/material/Button";
import Stack from "@mui/material/Stack";

const ExpenseOptions = ({ expenses }) => {
    return (
    <Stack direction="column" spacing={2}>
        {expenses.map((expense) => (
            <Button
                key={expense}
                className="bg-blue-700"
                size="large"
                variant="contained"
                >
                {expense}
            </Button>
        ))}
    </Stack>
  )
}

export default ExpenseOptions
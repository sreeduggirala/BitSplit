// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Test, console2} from "forge-std/Test.sol";
import {Splitwise} from "../src/Splitwise.sol";

contract SplitwiseTest is Test {
    Splitwise public splitwise;

    function setUp() public {
        splitwise = new Splitwise();
    }
}

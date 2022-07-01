// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

contract SimpleStorage {
    uint8 public storedData;

    function set(uint8 x) public {
        storedData = x;
    }

    function get() public view returns (uint8) {
        return storedData;
    }
}
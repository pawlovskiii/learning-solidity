// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OxToken {

    string public name = "0xToken";
    string public symbol = "0XT";
    uint public totalSupply = 10000;
    mapping(address => uint) balances;

    constructor() {
        balances[msg.sender] = totalSupply;
    }

    function transfer(address to, uint amount) external {
        require(balances[msg.sender] >= amount, "Not enough tokens");
        balances[msg.sender] -= amount;
        balances[to] += amount;
    }

    function balanceOf(address account) external view returns (uint) {
        return balances[account];
    }
}
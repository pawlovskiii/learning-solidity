// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MonoSogoToken is ERC20 {

    // Inside of the constructor, we call another constructor within ERC20
    constructor() ERC20("MonoSogoToken", "MST") {
        _mint(msg.sender, 1000 * (10 ** 2));
    }

    function decimals() public view virtual override returns (uint8) {
        // default is 18
        return 2;
    }
}
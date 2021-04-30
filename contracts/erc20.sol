// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";

contract MyToken is ERC20 {
    constructor() ERC20("MyToken", "MTK") {}
}
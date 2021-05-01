// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";

contract SharesIssuerV1 is ERC20PresetMinterPauserUpgradeable {
    function initialize(string memory name, string memory symbol, address owner) public virtual initializer{
        __ERC20PresetMinterPauser_init(name, symbol);
        grantRole(keccak256("MINTER_ROLE"),owner);
        grantRole(keccak256("PAUSER_ROLE"),owner);
    }
}
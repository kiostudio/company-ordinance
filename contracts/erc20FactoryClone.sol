// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/presets/ERC20PresetMinterPauserUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract FactoryClone {
    address immutable tokenImplementation;

    constructor(){
        tokenImplementation = address(new ERC20PresetMinterPauserUpgradeable());
    }

    function createToken(string calldata name, string calldata symbol) external returns (address) {
        address clone = Clones.clone(tokenImplementation);
        ERC20PresetMinterPauserUpgradeable(clone).initialize(name, symbol);
        return clone;
    }
}
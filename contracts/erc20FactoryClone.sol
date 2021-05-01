// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./erc20Upgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract FactoryClone {
    address immutable tokenImplementation;

    constructor(){
        tokenImplementation = address(new ERC20Mint());
    }

    function createToken(string calldata name, string calldata symbol, address owner) external returns (address) {
        address clone = Clones.clone(tokenImplementation);
        ERC20Mint(clone).initialize(name, symbol, owner);
        return clone;
    }
}
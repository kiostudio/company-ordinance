// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./sharesIssuerV1.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract SharesIssuerFactoryCloneV1 {
    address immutable tokenImplementation;

    constructor(){
        tokenImplementation = address(new SharesIssuerV1());
    }

    function createShareIssuer(string calldata name, string calldata symbol, address owner) external returns (address) {
        address clone = Clones.clone(tokenImplementation);
        SharesIssuerV1(clone).initialize(name, symbol, owner);
        return clone;
    }

    // function createShareIssuer(string calldata name, string calldata symbol, address owner) external returns (address) {
    //     address clone = Clones.clone(tokenImplementation);
    //     SharesIssuerV1(clone).initialize(name, symbol, owner);
    //     return clone;
    // }
}
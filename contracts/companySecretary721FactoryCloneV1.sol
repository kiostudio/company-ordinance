// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./companySecretary721V1.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract CompanySecretary721FactoryCloneV1 {
    address immutable tokenImplementation;

    constructor(){
        tokenImplementation = address(new CompanySecretary721V1());
    }

    function createCompanySecretary(string calldata name, string calldata symbol, string calldata baseTokenURI, address owner) external returns (address) {
        address clone = Clones.clone(tokenImplementation);
        CompanySecretary721V1(clone).initialize(name, symbol, baseTokenURI, owner);
        return clone;
    }

}
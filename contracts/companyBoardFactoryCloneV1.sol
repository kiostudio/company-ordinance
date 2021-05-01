// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./companyBoardV1.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";

contract CompanyBoardFactoryCloneV1 {
    address immutable tokenImplementation;

    constructor(){
        tokenImplementation = address(new CompanyBoardV1());
    }

    function createCompanyBoard(address[] memory boardMembers, uint256[] memory shares, string memory name, string memory symbol, address factoryAddress) external returns (address) {
        address clone = Clones.clone(tokenImplementation);
        CompanyBoardV1(clone).initialize(boardMembers,shares,name, symbol,factoryAddress);
        return clone;
    }

    // function createShareIssuer(string calldata name, string calldata symbol, address owner) external returns (address) {
    //     address clone = Clones.clone(tokenImplementation);
    //     SharesIssuerV1(clone).initialize(name, symbol, owner);
    //     return clone;
    // }
}
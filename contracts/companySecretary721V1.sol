// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts-upgradeable/token/ERC721/presets/ERC721PresetMinterPauserAutoIdUpgradeable.sol";

contract CompanySecretary721V1 is ERC721PresetMinterPauserAutoIdUpgradeable {
    function initialize(string memory name, string memory symbol, string memory baseTokenURI, address owner) public virtual initializer {
        __ERC721PresetMinterPauserAutoId_init(name, symbol, baseTokenURI);
        grantRole(keccak256("MINTER_ROLE"),owner);
        grantRole(keccak256("PAUSER_ROLE"),owner);
    }
}
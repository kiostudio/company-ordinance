// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract CompanyRegistration is ERC721PresetMinterPauserAutoId {
    constructor() ERC721PresetMinterPauserAutoId("BusinessRegistration", "BR", "https://kios.tech/") {}
}
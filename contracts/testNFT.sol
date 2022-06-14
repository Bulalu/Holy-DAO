// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "./libraries/Base64.sol";
contract TestNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    constructor() ERC721("TestToken", "TEST"){
        
    }

    function mint() public {

        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);

        _tokenIds.increment();
       
    }

} 
    
    


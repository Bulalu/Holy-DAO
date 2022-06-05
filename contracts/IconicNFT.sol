// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { Base64 } from "./libraries/Base64.sol";
contract MyIconicNFT is ERC721URIStorage {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    uint8 constant public MAX_SUPPLY = 100;
    event NewEpicNFTMinted(address sender, uint256 tokenId);

    constructor() ERC721("FunnyNFT", "FUNNY"){
        
    }

    string baseSvg = "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' /><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

    
    string[] firstWords = ["Funny", "Sexy", "Tall", "Short", "Broke", "Richkid", "Fat", "Slim", "Bulalu", "Legend", "Crazy", "Wild", "Hype", "Leader", "Lame", "Stressy", "Weak", "Strong"];
    string[] secondWords = ["Giggity", "WTF", "Laid", "High", "Mofos", "Dev", "BigBunda", "Champ", "GM", "ShitCoin", "Bullish", "Bearish", "ShitCoin", "Ponzi", "Degens", "LFG", "GTFOLH"];
    string[] thirdWords = ["Havana", "Zanzibar", "Madrid", "NewYork", "Paris", "Bali", "Ibiza", "CapeTown", "Nairobi", "DaresSalaam", "London", "Toronto", "Manchester", "Cairo", "Berlin"];
    
    
    function makeAnIconicNFT() public {

        require(_tokenIds.current() <= MAX_SUPPLY, "Can't mint more than 100");

        uint256 newItemId = _tokenIds.current();
        
        string memory first = pickRandomFirstWord(newItemId);
        string memory second = pickRandomSecondWord(newItemId);
        string memory third = pickRandomThirdWord(newItemId);
        string memory combinedWord = string.concat(first, second, third);
        
        
        string memory finalSvg = string.concat(baseSvg, combinedWord, "</text></svg>");

        // Get all JSON metadata in place and base64 encode it
        string memory json = Base64.encode(
            bytes(
                string.concat(
                    '{"name": "',
                    // We set the title of our NFT as the generated word.
                    combinedWord,
                    '", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
                    // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                    Base64.encode(bytes(finalSvg)),
                    '"}'
                )
            )
        );

        

        string memory finalTokenUri = string.concat("data:application/json;base64,", json);
      
        _safeMint(msg.sender, newItemId);

        // set nft data
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();

        emit NewEpicNFTMinted(msg.sender, newItemId);
    }

    function getTotalNFTsMintedSoFar() public returns(uint256 ) {
        return _tokenIds.current();
    }

    // maybe use VRF
    function pickRandomFirstWord(uint256 tokenId) public view returns (string memory) {

        uint256 rand = random(string.concat("FIRST_WORD", Strings.toString(tokenId)));
        
        rand = rand % firstWords.length;
        return firstWords[rand];
    }

    function pickRandomSecondWord(uint256 tokenId) public view returns (string memory) {

        uint256 rand = random(string.concat("SECOND_WORD", Strings.toString(tokenId)));
        rand = rand % secondWords.length;
        return secondWords[rand];
    }

    function pickRandomThirdWord(uint256 tokenId) public view returns (string memory) {

        uint256 rand = random(string.concat("THIRD_WORD", Strings.toString(tokenId)));
        rand = rand % thirdWords.length;
        return thirdWords[rand];
    }

    

    function random(string memory input) internal pure returns (uint256) {
      return uint256(keccak256(abi.encodePacked(input)));
  }
}

// Your JSON is hosted at: https://jsonkeeper.com/b/218N
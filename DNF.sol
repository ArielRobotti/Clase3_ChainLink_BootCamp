// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract DNFT is ERC721, ERC721URIStorage, AutomationCompatibleInterface{
    constructor(){

    }
    function safeMint(address to, string memory /*uri*/) public  {
        require(tokenIdCounter<maxMintableNFTs,"No se pueden mintear mas NFT");
        _safeMint(to, tokenIdCounter);
        nftStatus[tokenIdCounter] = 0;
        tokenIdCounter ++;
    }
    function _burn(uint256 tokenId) internal tokenIdOk(tokenId) override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

} 
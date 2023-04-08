// SPDX-License-Identifier: MIT
//No se ve en opensea - 0x060497FE1fEA36EA2cdf829531E434eA79DbC55C
//address - 0x99c39e4Fd02Ba0D705Fd8c781913aA6Cb35Bf762
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts@4.8.2/utils/Counters.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract DNFT is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    
    //Automation
    uint256 public counter;
    uint256 public immutable interval;
    uint256 public lastTimeStamp;
    constructor(uint256 _interval) ERC721("dNFT", "ARI") {
        interval = _interval;
        lastTimeStamp = block.timestamp;
        counter = 0;
    }
    function checkUpkeep(bytes calldata ) external view override 
        returns(bool upkeepNeeded, bytes memory)
    {
        upkeepNeeded = (block.timestamp - lastTimeStamp) > interval;
    }
    function performUpkeep(bytes calldata ) external override {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            updateAllStatus();
        }
    }
    //end Automation

    mapping (uint256 => uint256) nftStatus;
    string[] ipfsUri = [
        "https://ipfs.io/ipfs/QmR8LzyxnbD42FkUVPuzTWyNzi3cN4Bq47nhboSgy5bKwV/state_0.jpg",
        "https://ipfs.io/ipfs/QmR8LzyxnbD42FkUVPuzTWyNzi3cN4Bq47nhboSgy5bKwV/state_1.jpg",
        "https://ipfs.io/ipfs/QmR8LzyxnbD42FkUVPuzTWyNzi3cN4Bq47nhboSgy5bKwV/state_2.jpg"
    ];
    
    function safeMint(address to, string memory /*uri*/) public  {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        nftStatus[tokenId] = 0;
    }
    modifier tokenIdOk(uint256 _tokenId){
        require(_tokenId<_tokenIdCounter.current(), "Error token ID");
        _;
    }
    function updateStatus(uint _tokenId)public tokenIdOk(_tokenId){
        nftStatus[_tokenId] = (nftStatus[_tokenId]+1) % ipfsUri.length;
    }
    function updateAllStatus()public{
        for(uint i=0; i<_tokenIdCounter.current(); i++){
            updateStatus(i);
        }
    }
    function getNFTStaus(uint256 _tokenId)public tokenIdOk(_tokenId)view returns(uint256){
        return nftStatus[_tokenId];
    }
    function gerUriById(uint256 _tokenId)public tokenIdOk(_tokenId) view returns(string memory){
        return ipfsUri[getNFTStaus(_tokenId)];
    }
    function _burn(uint256 tokenId) internal tokenIdOk(tokenId) override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }
    function tokenURI(uint256 _tokenId)
        public
        tokenIdOk(_tokenId)
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return gerUriById(_tokenId);
    }
}

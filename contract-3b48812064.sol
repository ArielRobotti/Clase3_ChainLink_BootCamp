// SPDX-License-Identifier: MIT
// No se ve en opensea - 0x060497FE1fEA36EA2cdf829531E434eA79DbC55C   Estaba mal el array de uris
// idem                  0x99c39e4Fd02Ba0D705Fd8c781913aA6Cb35Bf762   idem
// 0x750BE99f42e08d6BCD9f851C12Db29970cF4ebCf
// prueba de seguridad - 0xB3C21aE0520B5CBE549Ae2fc06D822F6030eFe34 limite: 1000 NFT
// Prueba de seguridad - 0xB35282eB43f6aF413f350db951b94F5Cf2EBa3F6 limite: 4 NFT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.2/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.2/token/ERC721/extensions/ERC721URIStorage.sol";
import "@chainlink/contracts/src/v0.8/AutomationCompatible.sol";

contract DNFT is ERC721, ERC721URIStorage, AutomationCompatibleInterface {
    //Automation
    uint16 public immutable interval;
    uint16 public immutable maxMintableNFTs;
    uint16 public tokenIdCounter;
    uint256 public lastTimeStamp;
    constructor(uint16 _interval, uint16 _maxMintableNFTs) ERC721("dNFT", "ARI2") {
        interval = _interval;
        maxMintableNFTs = _maxMintableNFTs;
        tokenIdCounter = 0;
        lastTimeStamp = block.timestamp;
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
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_0.json",
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_1.json",
        "https://ipfs.io/ipfs/QmWXJsTejP4688dZferHR475uUPk1aXF23MJLZSUPjhvcK/state_2.json"
    ];

    function safeMint(address to, string memory /*uri*/) public  {
        require(tokenIdCounter<maxMintableNFTs,"No se pueden mintear mas NFT");
        _safeMint(to, tokenIdCounter);
        nftStatus[tokenIdCounter] = 0;
        tokenIdCounter ++;
    }
    modifier tokenIdOk(uint256 _tokenId){
        require(_tokenId < tokenIdCounter, "Error token ID");
        _;
    }
    function updateStatus(uint _tokenId)public tokenIdOk(_tokenId){
        nftStatus[_tokenId] = (nftStatus[_tokenId]+1) % ipfsUri.length;
    }
    function updateAllStatus()public{
        for(uint i=0; i<tokenIdCounter; i++) updateStatus(i); 
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
    function getTotalMinted()public view returns(uint256){
        return tokenIdCounter;
    }
}

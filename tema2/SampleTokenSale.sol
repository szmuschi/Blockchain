// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SampleToken.sol";

contract SampleTokenSale {
    
    SampleToken public tokenContract;
    uint256 public tokenPrice;
    address owner;

    uint256 public tokensSold;

    event Sell(address indexed _buyer, uint256 indexed _amount);

    constructor(SampleToken _tokenContract, uint256 _tokenPrice) {
        owner = msg.sender;
        tokenContract = _tokenContract;
        tokenPrice = _tokenPrice;
    }
    
    function change_tokenPrice(uint256 new_price) public {
        require(msg.sender == owner);
        tokenPrice = new_price;
    }

    function buyTokens(uint256 _numberOfTokens) public payable {
        require(msg.value >= _numberOfTokens * tokenPrice);
        require(tokenContract.transferFrom(owner, msg.sender, _numberOfTokens));
        if(tokensSold/10000 != (tokensSold+_numberOfTokens)/10000)
            tokenContract.mint(owner);
        tokensSold += _numberOfTokens;
        emit Sell(msg.sender, _numberOfTokens);
        payable(msg.sender).transfer(msg.value - (_numberOfTokens * tokenPrice));
    }

    function endSale() public {
        require(tokenContract.transfer(owner, tokenContract.balanceOf(address(this))));
        require(msg.sender == owner);
        payable(msg.sender).transfer(address(this).balance);
    }
}
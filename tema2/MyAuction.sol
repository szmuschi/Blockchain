// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./Auction.sol";
import "./SampleToken.sol";

contract MyAuction is Auction {
    SampleToken public tokenContract;
    event AuctionEnd(address indexed highestBidder, uint256 highestBid);

    constructor (uint _biddingTime, address payable _owner, string memory _brand, string memory _Rnumber, SampleToken _tokenContract) {
        auction_owner = _owner;
        auction_start = block.timestamp;
        auction_end = auction_start + _biddingTime*1 hours;
        STATE = auction_state.STARTED;
        Mycar.Brand = _brand;
        Mycar.Rnumber = _Rnumber;
        tokenContract = _tokenContract;
    } 
    
    function get_owner() public view returns(address) {
        return auction_owner;
    }
    
    function bid(uint256 bidValue) public an_ongoing_auction  override returns (bool) {
        require(bids[msg.sender] == 0, "You can't bid again, only one bid per person");
        require(tokenContract.allowance(msg.sender, address(this)) >= bidValue, "You can't bidt his ammount, request approval from SampleToken contrract");
        require(bids[msg.sender] + bidValue > highestBid,"You can't bid, Make a higher Bid");
        require(tokenContract.transferFrom(msg.sender, address(this), bidValue));
        highestBidder = msg.sender;
        highestBid = bids[msg.sender] + bidValue;
        bidders.push(msg.sender);
        bids[msg.sender] = highestBid;
        emit BidEvent(highestBidder,  highestBid);
        return true;
    } 
    
    function cancel_auction() external only_owner an_ongoing_auction override returns (bool) {
    
        STATE = auction_state.CANCELLED;
        emit CanceledEvent("Auction Cancelled", block.timestamp);
        return true;
    }
    
    function withdraw() public override returns (bool) {
        
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't withdraw, the auction is still open");
        require(msg.sender != highestBidder || STATE == auction_state.CANCELLED,"You can't withdraw, you are the highest bidder");
        uint amount;

        amount = bids[msg.sender];
        bids[msg.sender] = 0;
        tokenContract.transfer(msg.sender, amount);
        emit WithdrawalEvent(msg.sender, amount);
        return true;
      
    }
    
    function destruct_auction() public only_owner returns (bool) {
        require(block.timestamp > auction_end || STATE == auction_state.CANCELLED,"You can't destruct the contract,The auction is still open");
        for(uint i = 0; i < bidders.length; i++)
        {
            if(bidders[i] != highestBidder)
            {
                tokenContract.transfer(bidders[i], bids[bidders[i]]);
                bids[bidders[i]] = 0;
            }
        }
        tokenContract.transfer(msg.sender, highestBid);
        emit AuctionEnd(highestBidder, highestBid);
        selfdestruct(auction_owner);
        return true;
    
    }
}




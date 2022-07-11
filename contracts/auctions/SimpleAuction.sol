// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract SimpleAuction {

    address payable public beneficiary;
    address public owner;
    uint public auctionEndTime;

    address public highestBidder;
    uint public highestBid;

    mapping(address => uint) pendingReturns;

    bool ended;

    // Events that will be emitted on changes.
    event HighestBigIncreased(address bidder, uint amount);
    event AuctionEnded(address winner, uint amount);

    /// The auction has already ended.
    error AuctionAlreadyEnded();
    /// These is already a higher or equal bid.
    error BidNotHighEnough(uint highestBid);
    /// The auction has not ended yet.
    error AuctionNotYetEnded();
    /// The function auctionEnd has already been called.
    error AuctionEndAlreadyCalled();

    modifier onlyOwner {
        require(msg.sender == owner, "Only the owner can end the auction!");
        _;
    }

    constructor(uint biddingTime, address payable beneficiaryAddress) {
        owner = msg.sender;
        beneficiary = beneficiaryAddress;
        auctionEndTime = block.timestamp + biddingTime;
    }

    function bid() external payable {

        if (block.timestamp > auctionEndTime)
            revert AuctionAlreadyEnded();
        
        if (msg.value <= highestBid)
            revert BidNotHighEnough(highestBid);
        
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HighestBigIncreased(msg.sender, msg.value);
    }

    function withdraw() external returns (bool) {
        uint amount = pendingReturns[msg.sender];
        if (amount > 0) {
            // It is important to set this to zero because the recipient 
            // can call this function again as part of the receiving call
            // before 'send' returns.
            pendingReturns[msg.sender] = 0;

            // msg.sender is not a type 'address payable' and must be
            // explicitly converted using 'payable(msg.sender)' in order
            // use the member function 'send()'.
            if (!payable(msg.sender).send(amount)) {
                // No need to call throw here, just reset the amount owing
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        return true;
    }

    function auctionEnd() onlyOwner external {
        // It is a good guideline to structure functions that interact 
        // with other contracts (i.e. they call functions or send Ether)
        // into three phases:
        // 1. checking conditions
        // 2. performing actions (potentially changing conditions)
        // 3. interacting with other contracts
        // If these phases are mixed up, the other contract could call 
        // back into the current contract and modify the state or cause
        // effects (ether payout) to be perfomed multiple times.
        // If functions called internally include interaction with external
        // contracts, they also have to be considered interactions with 
        // external contracts.

        // 1. Conditions
        if (block.timestamp < auctionEndTime)
            revert AuctionNotYetEnded();
        if (ended)
            revert AuctionEndAlreadyCalled();
        
        // 2. Effects
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // 3. Interaction
        beneficiary.transfer(highestBid);
    }
}
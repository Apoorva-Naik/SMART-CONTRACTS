pragma solidity ^0.5.1;

contract Auction{
    address payable public owner; // owner address
    uint public start_time;       // auction start time
    uint public end_time;         // auction  end time
    
    string public ipfsHash;
    
    uint public highestBindingBid;                    // highest bid
    address payable public higestBidder;        // highest bidder's address
    uint public bidIncrement;                   // bid increment
    

    
    
    mapping (address => uint) public bids;
    
    enum State{Started, Running, Cancelled,Ended}
    State public auctionState;
    
    constructor() public{
        owner = msg.sender;
        auctionState =State.Running;
        
        start_time =block.number;
        end_time = start_time + 3 ; // 60(sec)*60 (min)*24hrs(1 day) *7(a week)/ 15 sec(blockchian time)
        ipfsHash ="";
        bidIncrement =1000000000000000000;
    }
   
        modifier notOwner{
            require(msg.sender != owner);
            _;
        }
        
        modifier afterStart{
            require(block.number >= start_time);
            _;
        }
        
        modifier beforeEnd{
            require(block.number <= end_time);
            _;
        }
        
        modifier onlyOwner{
            require(msg.sender == owner);
            _;
            
        }
        
        function min(uint a, uint b) pure internal returns(uint){
            if(a <= b)
                return a;
            else
               return b;
        }
        
        
        // placing a bid by bidders 
        
    function placeBicd() public payable notOwner afterStart beforeEnd returns(bool) {
        require(auctionState == State.Running);
       require(msg.value >= 0.01 ether);
        
        uint currentBid = bids[msg.sender]+ msg.value; 
        
        require(currentBid > highestBindingBid  );
        
        bids[msg.sender]= currentBid;
        
        if(currentBid < bids[higestBidder])
        {
            highestBindingBid = min(currentBid+bidIncrement, bids[higestBidder]);
            
        }
        else
        {
            highestBindingBid = min(currentBid ,bids[higestBidder]+bidIncrement);
            higestBidder= msg.sender;
        }
        
        return true;    
        
    }
    
    function cancelAuction() public onlyOwner {
        auctionState = State.Cancelled;
        
    }
    
    function finalizeAuction() public{
        require(auctionState == State.Cancelled || block.number> end_time);
        require(msg.sender == owner || bids[msg.sender] >0);
        
        
        address payable recepient;
        uint value;
        if(auctionState == State.Cancelled){
            recepient = msg.sender;
            value = bids[msg.sender];
        }else
        {
            if(msg.sender ==  owner ){
                recepient = owner;
                value = highestBindingBid;
                
            }else{
                if(msg.sender == higestBidder){
                    recepient= higestBidder;
                    value = bids[higestBidder] - highestBindingBid;
                }else{
                    recepient = msg.sender;
                    value = bids[msg.sender];
                }
            }
        }
        
        recepient.transfer(value);
         
    }

}

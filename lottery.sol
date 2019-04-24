pragma solidity ^0.5.1;

contract Lottery{
    
    address payable [] public players; //dynamic array with player address
    address  public  manager;
    string public playersName;
    uint public r;
    uint public index;
    
   
    constructor() public {
        manager = msg.sender;
        playersName = "abc"; 
        
     }
     
     function setNMame(string memory _name) public{
         playersName = _name;
         
     }
     
     
     // this fallback function will be called automically when somebody sends ether 
     function() payable  external{
        require(msg.value >= 0.01 ether);
         players.push(msg.sender); // adds the address of the a/c that sends ether to players array
        
     }        
     
     function getBalance() public view returns(uint){
         
         require(msg.sender == manager);
         return address(this).balance;  // gives the balance of the current contract
     }
     
     // selecting a winner by random number
     
     function random() public view returns(uint256) {
        return  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));//returns hash 
         
     }
     
     // selecting the winner  and transfering amount to him
    
     function select_winner() public{
         require(msg.sender == manager);
          r = random();
         
         address payable winner;
          index = (r%players.length);
         winner = players[index];
         
         winner.transfer(address(this).balance); //transfers money to winner
        
       players = new address payable[](0);
       
     }
       
}

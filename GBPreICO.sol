pragma solidity ^0.4.15;

 contract Ownable {

  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
}


contract GBpreICO is Ownable {

  uint public constant BEGIN_TIME = 1506787200;
  uint public constant END_TIME = 1509379200;
  uint public maxCap = 6667 ether;

  uint public ethRaised = 0;
  address public multisig = 0x0;

  uint public totalNumberOfTokens;
  uint public revenue;
  uint public expenses;
  uint public tokenInvested;

  // uint public EBITDA = revenue - expenses;   //(excluding tax, interest, depreciation and amortization)
  // uint public profitSharing = revenue * 60 / 100; 
  // uint public contributorShares = tokenInvested / totalNumberOfTokens; //distribution of sharing would be on March 1, 2019
  // 1 ETH = 15000 GOAL
  state public crowdsaleState = state.pendingStart;
  enum state { pendingStart, crowdsale, crowdsaleEnded }
  event CrowdsaleStarted(uint blockNumber);
  event CrowdsaleEnded(uint blockNumber);

function() payable {
  require(msg.value >= 0.5 ether);
  require(crowdsaleState != state.crowdsaleEnded); // Check if crowdsale has ended
  
  bool stateChanged = checkCrowdsaleState();      // Check blocks and calibrate crowdsale state
  
      if(crowdsaleState == state.crowdsale) {
         ethRaised += msg.value; 
          if (!multisig.send(msg.value)) {
              revert();
          }           
        } else {
          refundTransaction(stateChanged);              // Set state and return funds or throw
        }
      }

  function refundTransaction(bool _stateChanged) internal {
    if (_stateChanged) {
      msg.sender.transfer(msg.value);
    } else {
      revert();
    }
  }

  function checkCrowdsaleState() internal returns (bool) {

    if (ethRaised >= maxCap && crowdsaleState != state.crowdsaleEnded) { // Check if max cap is reached
      crowdsaleState = state.crowdsaleEnded;
      CrowdsaleEnded(block.number); // Raise event
      return true;
    }
    
    if(now >= END_TIME) {   
      crowdsaleState = state.crowdsaleEnded;
      CrowdsaleEnded(block.number); // Raise event
      return true;
    }

    if(now >= BEGIN_TIME && now < END_TIME) {        // Check if we are in crowdsale state
      if (crowdsaleState != state.crowdsale) {                                                   // Check if state needs to be changed
        crowdsaleState = state.crowdsale;                                                       // Set new state
        CrowdsaleStarted(block.number);                                                         // Raise event
        return true;
      }
    }
    
    return false;
  }

  //   function getDiscount(uint percentage, uint tokens) constant returns (uint) {
  //   uint stageBonus = 0;
      
  //   return stageBonus = tokens * 6667 / 10000;;
  // }

  //   function getAmountBonus(uint256 _eth, uint256 tokens) constant returns (uint256) {
  //   uint amountBonus = 0;  
      
  //   if (_eth >= 3000 ether) amountBonus = tokens * 9 / 100;         // GOAL:16350
  //   else if (_eth >= 2000 ether) amountBonus = tokens * 85 / 1000;  // GOAL:16275
  //   else if (_eth >= 1500 ether) amountBonus = tokens * 8 / 100;    // GOAL:16200
  //   else if (_eth >= 1000 ether) amountBonus = tokens * 75 / 1000;  // GOAL:16125
  //   else if (_eth >= 750 ether) amountBonus = tokens * 7 / 100;     // GOAL:16050
  //   else if (_eth >= 500 ether) amountBonus = tokens * 65 / 1000;   // GOAL:15975
  //   else if (_eth >= 300 ether) amountBonus = tokens * 6 / 100;     // GOAL:15900
  //   else if (_eth >= 200 ether) amountBonus = tokens * 55 / 1000;   // GOAL:15825
  //   else if (_eth >= 150 ether) amountBonus = tokens * 5 / 100;     // GOAL:15750
  //   else if (_eth >= 100 ether) amountBonus = tokens * 45 / 1000;   // GOAL:15675
  //   else if (_eth >= 75 ether) amountBonus = tokens * 4 / 100;      // GOAL:15600
  //   else if (_eth >= 50 ether) amountBonus = tokens * 3.5 / 1000;   // GOAL:15525
  //   else if (_eth >= 30 ether) amountBonus = tokens * 3 / 100;      // GOAL:15450
  //   else if (_eth >= 20 ether) amountBonus = tokens * 25 / 1000;    // GOAL:15375
  //   else if (_eth >= 15 ether) amountBonus = tokens * 2 / 100;      // GOAL:15300
  //   else if (_eth >= 10 ether) amountBonus = tokens * 15 / 1000;    // GOAL:15225
  //   else if (_eth >= 7 ether) amountBonus = tokens * 1 / 100;       // GOAL:15150
  //   else if (_eth >= 5 ether) amountBonus = tokens * 5 / 1000;      // GOAL:15075
    
  //   return amountBonus;
  // }

    function setMultisigAddress(address _newAddress) onlyOwner {
    multisig = _newAddress;
  }
}
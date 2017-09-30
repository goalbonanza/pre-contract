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

    function setMultisigAddress(address _newAddress) onlyOwner {
    multisig = _newAddress;
  }
}
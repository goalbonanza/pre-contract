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


contract GBMainICO is Ownable {

  uint public constant BEGIN_TIME = 1510761600;
  uint public constant END_TIME = 1513440000;
  uint public maxCap = 100000 ether;

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
  require(msg.value >= 0.0001 ether);
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

  //Bonus
//   Nov 16, 2017 = Bonus 100%
//   Nov 17, 2017 = Bonus 90%
//   Nov 18, 2017 = Bonus 80%
//   Nov 19, 2017 = Bonus 70%
//   Nov 20, 2017 = Bonus 60%
//   Nov 21, 2017 = Bonus 50%
//   Nov 22, 2017 = Bonus 48%
//   Nov 23, 2017 = Bonus 46%
//   Nov 24, 2017 = Bonus 44%
//   Nov 25, 2017 = Bonus 42%
//   Nov 26, 2017 = Bonus 40%
//   Nov 27, 2017 = Bonus 38%
//   Nov 28, 2017 = Bonus 36%
//   Nov 29, 2017 = Bonus 34%
//   Nov 30, 2017 = Bonus 32%
//   DEC 1, 2017 = Bonus 30%
//   DEC 2, 2017 = Bonus 28%
//   DEC 3, 2017 = Bonus 26%
//   DEC 4, 2017 = Bonus 24%
//   DEC 5, 2017 = Bonus 22%
//   DEC 6, 2017 = Bonus 20%
//   DEC 7, 2017 = Bonus 18%
//   DEC 8, 2017 = Bonus 16%
//   DEC 9, 2017 = Bonus 14%
//   DEC 10, 2017 = Bonus 12%
//   DEC 11, 2017 = Bonus 10%
//   DEC 12, 2017 = Bonus 10%
//   DEC 13, 2017 = Bonus 10%
//   DEC 14, 2017 = Bonus 10%
//   DEC 15, 2017 = Bonus 10%
}
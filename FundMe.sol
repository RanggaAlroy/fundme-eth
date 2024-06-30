// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PriceConverter} from "./PriceConverter.sol";

// gas spend 824,466 we can lowring the gas spend with some teknik with constant and immutable keyword
// gas spend 804,521 after using constant 

error notOwner();


contract fundMe{

    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;  // add immutable to decreasing the gas

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
    require(msg.value.getConversionRate() >= MINIMUM_USD, "did not meet the minimum USD");
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] += msg.value;

    }

    function withdraw() public onlyOwner {
        require(msg.sender == i_owner, "Must be owner");
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
            }
    // reset the array
    funders = new address[](0);
    //withdraw fund has 3 ways 1. transfer, 2. send, 3. call
    //transfer ( if failed it will error)
    // payable(msg.sender).transfer(address(this).balance);
    // // send ( if failed it will send failed msg)
    // bool sendSuccess = payable(msg.sender).send(address(this).balance);
    // require(sendSuccess, "Send Failde");
    //call
    (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(callSuccess, "Call failed");
    revert();
    }

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not owner");
        // decreasing the gas use by handling error with if statement
        if(msg.sender != i_owner) revert notOwner();
        _;
    }

    uint256 public result;

    receive() external payable {
        result= 1;
     }

    fallback() external payable { 
        result = 2;
    }
   

} 



// decreasing the gas use by handling error with if statement

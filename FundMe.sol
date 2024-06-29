// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

contract fundMe{
    using PriceConverter for uint256;

    uint256 public minimumUSD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function fund() public payable {
    require(msg.value.getConversionRate() >= minimumUSD, "did not meet the minimum USD");
    funders.push(msg.sender);
    addressToAmountFunded[msg.sender] += msg.value;

    }

    function withdraw() public onlyOwner {
        require(msg.sender == owner, "Must be owner");
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
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not owner");
        _;
    }

} 

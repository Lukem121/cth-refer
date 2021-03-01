// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import './SafeMath.sol';
import './Ownable.sol';
import './IERC777.sol';

contract ReferUsers is Ownable {
    using SafeMath for uint256;
    
    struct User {
        address id;
        string name;
        uint256 lastClaim;
        uint256 totalClaimed;
        string referrer;
        string[] referrals;
        
        bool isActive;
        bool isValue;
    }
    
    mapping(string => User) nameToUser;
    mapping(address => string) addressToName;
    
    address tokenContract;
    
    uint256 startingBlock;
    uint256 baseReward;
    uint256 timeBetweenClaims;
    
    constructor() {
        tokenContract = 0xEFbd001235B1BdA46539f0fbb054f5B7aE9b7C67;
        
        startingBlock = block.number;
        baseReward = 50 ether;
        timeBetweenClaims = 5760;
    }
    
    function register(string memory name, string memory referrer) public payable {
        require(msg.value == 0.01 ether);
        require(!isAvailable(referrer));
        require(isAvailable(name));
        
        User memory user;
        user.id = msg.sender;
        user.name = name;
        user.lastClaim = block.number;
        user.totalClaimed = 0;
        user.referrer = referrer;
        user.referrals = new string[](0);
        user.isValue = true;
        
        nameToUser[name] = user;
        addressToName[msg.sender] = name;
        
        nameToUser[referrer].referrals.push(name);
    }
    
    function claim() public {
        string memory name = getNameFromAddress(msg.sender);
        uint256 lastClaim = nameToUser[name].lastClaim;
        require(lastClaim >= timeBetweenClaims);
        
        uint256 numberOfReferrals = nameToUser[name].referrals.length;
        
        uint256 tokenBonus = getTokenBonus(numberOfReferrals);
        uint256 tokenReward = baseReward + tokenBonus;
        
        // Payout tokens
    }
    
    function getTokenBonus(uint256 numberOfReferrals) public view returns(uint256) {
        uint256 tokenBonus = numberOfReferrals * ((baseReward / 4) / 3);
        return tokenBonus;
    }
    
    // get the total 
    function getTotalClaimedFromName(string memory name) public view returns(uint256) {
        return nameToUser[name].totalClaimed;
    }
    
    function getActiveFromAddress(address id) public view returns(bool) {
        string memory name = getNameFromAddress(id);
        return getActiveFromName(name);
    }
    
    function getActiveFromName(string memory name) public view returns(bool) {
        return nameToUser[name].isActive;
    }
    
    // get the total amount of tokens claimed by this user
    function getTotalClaimedFromAddress(address id) public view returns(uint256) {
        string memory name = getNameFromAddress(id);
        return getTotalClaimedFromName(name);
    }
    
    // get the last time a username claimed tokens
    function getLastClaimFromName(string memory name) public view returns(uint256) {
        return nameToUser[name].lastClaim;
    }
    
    // get the last time time an address claimed tokens
    function getLastClaimFromAddress(address id) public view returns(uint256) {
        string memory name = getNameFromAddress(id);
        return getLastClaimFromName(name);
    }
    
    // get address from a username
    function getAddressFromName(string memory name) public view returns(address) {
        return nameToUser[name].id;
    }
    
    // get username from an address
    function getNameFromAddress(address id) public view returns(string memory) {
        return addressToName[id];
    }
    
    // check if the username is available, registered usernames must be unique
    function isAvailable(string memory name) public view returns(bool) {
        return !nameToUser[name].isValue;
    }
    
    function setTokenContract(address tknContract) public onlyOwner {
        tokenContract = tknContract;
    }
    
}
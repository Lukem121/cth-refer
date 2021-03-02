// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import './SafeMath.sol';
import './Ownable.sol';
import './IERC223.sol';

contract ReferUsers is Ownable {
    using SafeMath for uint256;
    
    struct User {
        // address of the user
        address id;
        
        // name of the user
        string name;
        
        // last block the user claimed tokens
        uint256 lastClaim;
        
        // total mount of HNY claimed
        uint256 totalClaimed;
        
        // the name of the user that referred this user
        string referrer;
        
        // names of people a user has referred
        string[] referrals;
        
        // the amount of CTH/HNY LP staked
        uint256 totalTeamStake;
        
        // the sum of the last claimed block
        uint256 accumulativeBlockClaimTimes;
        
        // bool to check if this exists
        bool isValue;
    }
    
    mapping(string => User) nameToUser;
    mapping(address => string) addressToName;
    
    address baseTokenContract;
    address liquidityTokenContract;
    
    uint256 startingBlock;
    uint256 baseReward;
    uint256 timeBetweenClaims;
    uint256 registrationCost;
    
    constructor() {
        baseTokenContract = 0xEFbd001235B1BdA46539f0fbb054f5B7aE9b7C67;
        liquidityTokenContract = 0xEFbd001235B1BdA46539f0fbb054f5B7aE9b7C67;
        
        startingBlock = block.number;
        baseReward = 50 ether;
        timeBetweenClaims = 5760;
        registrationCost = 0.01 ether;
    }
    
    function register(string memory name, string memory referrer) public payable {
        require(msg.value >= registrationCost, "Registration Error: Registration fee must be paid");
        require(!isAvailable(referrer), "Registration Error: Referrer does not exist");
        require(isAvailable(name), "Registration Error: Username not available");
        
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
        require(lastClaim >= timeBetweenClaims, "Claim Error: Reward not yet available");
        
        uint256 numberOfReferrals = nameToUser[name].referrals.length;
        
        uint256 tokenBonus = getTokenBonus(numberOfReferrals);
        uint256 tokenReward = baseReward + tokenBonus;
        
        // Payout tokens
        IERC223(baseTokenContract).transfer(msg.sender, tokenReward);
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
        return nameToUser[name].lastClaim + timeBetweenClaims <= block.number ;
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
    
    function setBaseTokenContract(address tknContract) public onlyOwner {
        baseTokenContract = tknContract;
    }
    
    function setLiquidityTokenContract(address tknContract) public onlyOwner {
        liquidityTokenContract = tknContract;
    }
    
}
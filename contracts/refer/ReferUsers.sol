// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import './SafeMath.sol';
import './Ownable.sol';
import './IERC223.sol';
import './IERC20.sol';

contract ReferUsers is Ownable {
    using SafeMath for uint256;
    
    event Stake(uint256 amount);
    event Withdraw(uint256 amount);
    
    struct User {
        // address of the user
        address id;
        
        // name of the user
        string name;
        
        // total amount of tokens staked by this user
        uint256 userStake;
        
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
        
        // bool to check if this exists
        bool isValue;
    }
    
    // mapping of usernames to User
    mapping(string => User) nameToUser;
    
    // mapping of addresses to usernames
    mapping(address => string) addressToName;

    // the ERC777 token used to reward users
    address public baseTokenContract;
    
    // liquidity token that is staked by users
    address public liquidityTokenContract;
    
    // the block which this contract was deployed in
    uint256 public startingBlock;
    uint256 public baseReward;
    uint256 public timeBetweenClaims;
    uint256 public registrationCost;
    
    constructor() {
        baseTokenContract = 0x940395C99e6938BF02165461E86DEeaF3ADC6815;
        liquidityTokenContract = 0xf364f0fdB13F33cA1BEFd5f32e11B67ca91FC1cA;
        
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
        user.userStake = 0;
        user.lastClaim = block.number;
        user.totalClaimed = 0;
        user.referrer = referrer;
        user.referrals = new string[](0);
        user.totalTeamStake = 0;
        user.isValue = true;
        
        nameToUser[name] = user;
        addressToName[msg.sender] = name;
        
        nameToUser[referrer].referrals.push(name);
    }
    
    function stake(uint256 amount) public {
        require(amount > 0, "Stake Error: Amount must be greater than zero");
        
        uint256 allowance = IERC20(liquidityTokenContract).allowance(msg.sender, address(this));
        require(allowance >= amount, "Stake Error: Token Approval too low");
        
        string memory user = getNameFromAddress(msg.sender);
        
        nameToUser[user].userStake += amount;
        nameToUser[nameToUser[user].referrer].totalTeamStake += amount;
        
        IERC20(liquidityTokenContract).transferFrom(msg.sender, address(this), amount);
        
        emit Stake(amount);
    }
    
    function withdraw(uint256 amount) public {
        require(amount > 0, "Withdraw Error: Amount must be greater than zero");
        
        string memory user = getNameFromAddress(msg.sender);
        
        require(amount <= nameToUser[user].userStake);
        
        nameToUser[user].userStake -= amount;
        nameToUser[nameToUser[user].referrer].totalTeamStake -= amount;
        
        IERC20(liquidityTokenContract).transfer(msg.sender, amount);
        
        emit Withdraw(amount);
    }
    
    function claim() public {
        string memory name = getNameFromAddress(msg.sender);
        uint256 lastClaim = nameToUser[name].lastClaim;
        require(lastClaim >= timeBetweenClaims, "Claim Error: Reward not yet available");
        
        uint256 userStake = nameToUser[name].userStake;
        uint256 numberOfReferrals = nameToUser[name].referrals.length;
        uint256 teamStake = nameToUser[name].totalTeamStake;
        
        uint256 tokenBonus = getTokenBonus(userStake, numberOfReferrals, teamStake);
        uint256 tokenReward = baseReward + tokenBonus;
        
        // Payout tokens
        IERC223(baseTokenContract).transfer(msg.sender, tokenReward);
    }
    
    function getTokenBonus(uint256 userStake, uint256 numberOfReferrals, uint256 teamStake) public view returns(uint256) {
        uint256 tokenBonus = numberOfReferrals * ((baseReward / 4) / 3);
        return tokenBonus;
    }
    
    function getActiveTeamStake(string memory name) public view returns(uint256) {
        
    }
    
    function getReferralsFromName(string memory name, uint256 page, uint256 resultsPerPage) public view returns(uint256) {
        
    }
    
    function getTotalStakedFromName(string memory name) public view returns(uint256) {
        return nameToUser[name].userStake;
    }
    
    function getTotalStakedFromAddress(address id) public view returns(uint256) {
        string memory name = getNameFromAddress(id);
        return getTotalStakedFromName(name); 
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
        if(compareStrings(name, "cth")) return false;
        return !nameToUser[name].isValue;
    }
    
    function setBaseTokenContract(address tknContract) public onlyOwner {
        baseTokenContract = tknContract;
    }
    
    function setLiquidityTokenContract(address tknContract) public onlyOwner {
        liquidityTokenContract = tknContract;
    }
    
    function compareStrings(string memory a, string memory b) public view returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
}
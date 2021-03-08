// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import './SafeMath.sol';
import './Ownable.sol';
import './IERC777.sol';
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
        timeBetweenClaims = 10; // Was 5760
        registrationCost = 0.01 ether;
    }
    
    function register(string memory name, string memory referrer) public payable {
        require(bytes(name).length <= 12, "Registration Error: name is too long must be shorter than 13 characters");
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
        
        uint256 tokenBonus = getTokenBonus(userStake, teamStake);
        
        // Payout tokens
        //IERC20(baseTokenContract).transfer(msg.sender, 10);
    }
    
    function getTokenBonus(uint256 userStake, uint256 teamStake) public pure returns(uint256) {
        uint256 teamStakeBonus = preciseDivision(teamStake, (10 ** 18), 18);
        uint256 tokenBonus = preciseDivision(userStake + teamStakeBonus, (24 ** 18), 18);
        
        return tokenBonus;
    }
    
    function getActiveTeamStake(string memory name) public view returns(uint256) {
        
    }

    // Luke added this!
    function getMiningProgressFromName(string memory name) public view returns(uint256 lastClaim, uint256 timeBetween, uint256 currentBlock) {
        lastClaim = nameToUser[name].lastClaim;
        timeBetween = timeBetweenClaims;
        currentBlock = block.number;
        return (lastClaim, timeBetween, currentBlock);
    }
    
    function getMiningProgressFromAddress(address id) public view returns(uint256 lastClaim, uint256 timeBetween, uint256 currentBlock) {
        string memory name = getNameFromAddress(id);
        return getMiningProgressFromName(name);
    }
    //Luke fin here
    
    function getAllReferralsFromName(string memory name) public view returns(string[] memory) {
        return nameToUser[name].referrals;
    }
    
    function getAllReferralsFromAddress(address id) public view returns(string[] memory) {
        string memory name = getNameFromAddress(id);
        return getAllReferralsFromName(name);
    }
    
    function getPagedReferralsFromName(string memory name, uint256 cursor, uint256 resultsPerPage) public view returns(string[] memory values, uint256 newCursor) {
        uint256 length = resultsPerPage;
        string[] memory referrals = getAllReferralsFromName(name);
        
        if (length > referrals.length - cursor) {
            length = referrals.length - cursor;
        }

        values = new string[](length);
        for (uint256 i = 0; i < length; i++) {
            values[i] = referrals[cursor + i];
        }

        return (values, cursor + length);
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
    
    function compareStrings(string memory a, string memory b) public pure returns (bool) {
        a = lower(a);
        b = lower(b);
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }
    
    function lower(string memory _base) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);
        for (uint i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = _lower(_baseBytes[i]);
        }
        return string(_baseBytes);
    }
    
    function _lower(bytes1 _b1) private pure returns (bytes1) {
        if (_b1 >= 0x41 && _b1 <= 0x5A) {
            return bytes1(uint8(_b1) + 32);
        }
        return _b1;
    }
    
    function preciseDivision(uint256 a, uint256 b, uint256 precision) public pure returns (uint256) {
        return a * (10 ** precision) / b;
    }
    
    function floor(uint256 a, uint256 precision) public pure returns (uint256) {
        uint256 m = 10 ** precision;
        return ((a - 1) / m) * m;
    }
    
    function ceil(uint256 a, uint256 precision) public pure returns (uint256) {
        uint256 m = 10 ** precision;
        return ((a + m - 1) / m) * m;
    }
    
}
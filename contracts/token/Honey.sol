pragma solidity ^0.5.1;

import "./ERC223Token.sol";
import "./ERC223Burnable.sol";
import "./ERC223Mintable.sol";

contract Honey is ERC223Token, ERC223Mintable, ERC223Burnable {
    string public name = "Test Honey";
    string public symbol = "TSTHNY";
    uint public decimals = 18;
}

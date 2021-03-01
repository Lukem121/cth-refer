// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "./ERC777/ERC777.sol";
import "../access/AccessControlEnumerable.sol";
import "../utils/Context.sol";

/**
 * @dev {ERC777} token, including:
 *
 *  - Preminted initial supply
 *  - No access control mechanism (for minting/pausing) and hence no governance
 *
 * _Available since v3.4._
 */
contract Honey is Context, AccessControlEnumerable, ERC777 {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    /**
     * @dev Mints `initialSupply` amount of token and transfers them to `owner`.
     *
     * See {ERC777-constructor}.
     */
    constructor(string memory name, string memory symbol, address[] memory defaultOperators, uint256 initialSupply, address owner) ERC777(name, symbol, defaultOperators) {
        _setupRole(MINTER_ROLE, _msgSender());
        _mint(owner, initialSupply, "", "");
    }
    
    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "ERC777: must have minter role to mint");
        _mint(to, amount, "", "");
    }
}
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./common/ERC2981.sol";

contract NFT1155 is
    Context,
    ERC1155Burnable,
    ERC1155Supply,
    ERC2981,
    AccessControl
{
    using Counters for Counters.Counter;
    using Strings for uint256;
    Counters.Counter private _tokenIdTracker;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private usedNonce;
    address public operator;

    // Create a new role identifier for the minter role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");

    string private baseTokenURI;
    string private _name;
    string private _symbol;
    address public owner;
    bool public isRevealed;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    
    event BaseURIChanged(string indexed uri, string indexed newuri);

    constructor(
        string memory _tokenName,
        string memory _tokenSymbol,
        string memory _baseTokenURI,
        address _operator
    ) ERC1155(_baseTokenURI) {
        baseTokenURI = _baseTokenURI;
        owner = _msgSender();
        operator = _operator;
        _setupRole(ADMIN_ROLE, msg.sender);
        _setupRole(OPERATOR_ROLE, operator);
        _name = _tokenName;
        _symbol = _tokenSymbol;
        _tokenIdTracker.increment();
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    /** @dev change the Ownership from current owner to newOwner address
        @param newOwner : newOwner address */

    function transferOwnership(address newOwner)
        external
        onlyRole(ADMIN_ROLE)
        returns (bool)
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _revokeRole(ADMIN_ROLE, owner);
        owner = newOwner;
        _setupRole(ADMIN_ROLE, newOwner);
        emit OwnershipTransferred(owner, newOwner);
        return true;
    }

    function setBaseURI(string memory uri_) external onlyRole(ADMIN_ROLE) returns (bool) {
        emit BaseURIChanged(baseTokenURI, uri_);
        baseTokenURI = uri_;
        return true;
    }

    function mint(
        address to,
        uint256 _tokenId,
        uint256 supply,
        address royaltyAddress,
        uint96 _royaltyFee
    ) external virtual onlyRole(OPERATOR_ROLE) returns (uint256) {
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(to, _tokenId, supply, "");
        _setTokenRoyalty(_tokenId, royaltyAddress, _royaltyFee);
        return _tokenId;
    }
    
    function revealNFT() external onlyRole(ADMIN_ROLE) {
        isRevealed = true;
    }

    function uri(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(
            exists(tokenId),
            "ERC1155URIStorage: URI query for nonexistent token"
        );
        if(isRevealed){

        string memory _tokenURI = _tokenURIs[tokenId];
        // If there is no base URI, return the token URI.
        if (bytes(baseTokenURI).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(baseTokenURI, _tokenURI));
        }
        return
            bytes(baseTokenURI).length > 0
                ? string(abi.encodePacked(baseTokenURI, tokenId.toString()))
                : "";
        }
        else {
                return "https://gateway.pinata.cloud/ipfs/QmfGDJrAPccdbfFyUfjDfHx35CD4jTWE1QvkuDsUFDbRH6";
            }
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(ERC2981, ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(
        address _operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply, ERC1155) {
        super._beforeTokenTransfer(_operator, from, to, ids, amounts, data);
    }
}
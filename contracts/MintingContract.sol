// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.18;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/interfaces/IERC2981.sol";

interface INft {
function mint(address to,uint256 _tokenId,uint256 supply,address royaltyAddress,uint96 _royaltyFee) external returns(uint256);
}

contract Trade is AccessControl {

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event MintingFee(uint256 fee);
    event NftAddressUpdated(address nftAddress);
    event Assetmint(address indexed from,uint256 tokenIds);

    uint256[10] private array;
    uint256 private length = 10;
    uint256 private randNum;
    uint256 public mintingFee = 1 * 10 ** 18;
    address public creator;
    address public nftaddress;
    address _owner;

    // Create a new role identifier for the minter role
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    mapping(uint256 => bool) private usedNonce;


    constructor () {
        _owner = msg.sender;
        _setupRole(ADMIN_ROLE, msg.sender);
        creator = msg.sender;
    }

    function setMintingfee(uint256 fee) external onlyRole(ADMIN_ROLE) returns(bool) {
        mintingFee = fee;
        emit MintingFee(mintingFee);
        return true;
    }

     function updateNFTAddress(address _nftaddress) external onlyRole(ADMIN_ROLE) returns(bool) {
        nftaddress = _nftaddress;
        emit NftAddressUpdated(nftaddress);
        return true;
    }

   /**
        transfers the contract ownership to newowner address.    
        @param newOwner address of newOwner
     */

    function transferOwnership(address newOwner)
        external
        onlyRole(ADMIN_ROLE)
        returns (bool)
    {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _revokeRole(ADMIN_ROLE, _owner);
        _owner = newOwner;
        _setupRole(ADMIN_ROLE, newOwner);
        emit OwnershipTransferred(_owner, newOwner);
        return true;
    }

    function getRandom(uint256 salt) private returns(uint256) {
            require(length != 0,"Minting limit exceeds");
            uint256 rand = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, salt)));
            uint256 randId = rand % length;
            if(array[randId] == 0)
                randNum = randId;
            else
                randNum = array[randId];       
            array[randId] =  array[length-1] == 0 ? length-1 : array[length-1];
            delete array[length-1];
            length--;
            return randNum;
    }

    function getNumber(uint256 salt) internal returns(uint256) {
        uint256 result;
        result = getRandom(salt)+1;
        return result;    
    }

    function mint(uint256 seed) external payable returns(uint256 tokenId) {
      require(seed != 0, "Seed value must be greater than zero");
      require(mintingFee == msg.value,"Invalid amount");
        tokenId = getNumber(seed);
        INft(nftaddress).mint(msg.sender, tokenId, 1, creator, 30);
        emit Assetmint(msg.sender, tokenId);
        return tokenId;
    }

    function withdraw(uint256 amount) 
    external
    onlyRole(ADMIN_ROLE)
    returns (bool) {
      payable(msg.sender).transfer(amount);
   }


}
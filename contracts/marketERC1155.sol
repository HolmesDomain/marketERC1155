//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract marketERC1155 is Ownable {

    event Listing(
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event CancelledListing(address indexed owner, uint256 indexed id);

    event Approval(address indexed owner, address indexed operator, bool approved);


    uint256 public _totalAssets;
    mapping(address => bool) private _listingApproved;
    mapping(address => bool) private _canMint;
    mapping(uint256 => mapping(address => uint256)) private _balances;

    mapping(uint256 => bool) private _listed;
    mapping(address => uint256) private _assetOwner;

    constructor() {
        _canMint[msg.sender] = true;
    }

    function isOwner(address wallet) public view returns (bool) {
        address _owner = owner();
        if(_owner == wallet) {
            return true;
        } else {
            return false;
        }
    }

    function totalAssets() public view returns (uint256) {
        return _totalAssets;
    }

    function assetOwner(address wallet, uint256 id) public view returns (bool) {
        if(id == _assetOwner[wallet]) {
            return true;
        } else {
            return false;
        }
    }

    //Approved addresses can mint an asset
    function newListing(uint256 id, uint256 amount) public isApproved {
        _balances[id][msg.sender] += amount;
        _assetOwner[msg.sender] = id;

        emit Listing(address(this), msg.sender, id, amount);

        _listed[id] = true;
        _totalAssets++;
    }

    function cancelListing(uint256 id) public {
        require(assetOwner(msg.sender, id) != false);
        _listed[id] = false;

        emit CancelledListing(msg.sender, id);
    }

    function buyAsset(uint256 id, address from, uint256 amount) public {
        require(_listed[id] == true, "Asset not listed");
        _balances[id][from] += amount;
    }

    function balanceOf(address wallet, uint256 id) public view returns (uint256) {
        require(wallet != address(0), "ERC1155: balance query for the zero address");
        return _balances[id][wallet];
    }

    function approveMint(address wallet) public onlyOwner {
        _canMint[wallet] = true;

        address contractOwner = owner();
        emit Approval(contractOwner, wallet, true);
    }

    modifier isApproved {
        require(_canMint[msg.sender], "Not approved to mint");
        _;  
    }
}

//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.10;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract marketERC1155 is Ownable {

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 amount
    );

    event StagedListing(address indexed operator, uint256 indexed id);

    event CancelledListing(address indexed owner, uint256 indexed id);

    event Approval(address indexed owner, address indexed operator, bool approved);


    uint256 public _totalAssets;
    mapping(address => mapping(uint256 => uint256)) private _balances;

    mapping(address => bool) private _canMint;
    mapping(uint256 => bool) private _listApproved;
    mapping(uint256 => bool) private _listed;
    mapping(uint256 => uint256) private _listedAmt;

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

    function stageListing(uint256 id) public {
        emit StagedListing(msg.sender, id);
        _assetOwner[msg.sender] = id;
    }

    //Approved addresses can mint an asset
    function newListing(uint256 id, uint256 amount) public isApproved {
        require(_listApproved[id] == true, "Pending admin approval for listing");
        _balances[msg.sender][id] += amount;

        emit Transfer(address(this), msg.sender, id, amount);

        _listed[id] = true;
        _totalAssets += amount;
        _listedAmt[id] = amount;
    }

    //cancel listing is possible if pending approval from admins/org
    function cancelListing(uint256 id) public {
        require(assetOwner(msg.sender, id) == true);
        require(_listApproved[id] == false, "Asset is listed");
        _listed[id] = false;
        _totalAssets -= _listedAmt[id];

        emit CancelledListing(msg.sender, id);
    }

    function transferAsset(uint256 id, address from, address to, uint256 amount) public {
        require(to != address(0), "ERC1155: balance query for the zero address");
        require(_listed[id] == true, "Asset not listed");
        require(assetOwner(msg.sender, id) != false || isOwner(msg.sender));
        _balances[from][id] -= amount;
        
        if(_balances[from][id] <= 0) {
            delete _assetOwner[from];
        }

        _balances[to][id] += amount;
        _assetOwner[to] = id;

        emit Transfer(from, to, id, amount);
    }

    function balanceOf(address wallet, uint256 id) public view returns (uint256) {
        require(wallet != address(0), "ERC1155: balance query for the zero address");
        return _balances[wallet][id];
    }

    function approveMint(address wallet) public onlyOwner {
        _canMint[wallet] = true;

        address contractOwner = owner();
        emit Approval(contractOwner, wallet, true);
    }

    function approveListing(uint256 id) public onlyOwner {
        _listApproved[id] = true;
    }

    modifier isApproved {
        require(_canMint[msg.sender], "Not approved to mint");
        _;  
    }
}

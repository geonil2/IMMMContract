pragma solidity ^0.5.0;

import "../token/KIP17/KIP17.sol";
import "../drafts/Counters.sol";
import "../token/KIP17/IKIP17.sol";

contract IMMMMarket {
    using Counters for Counters.Counter;

    // type of list
    struct list {
        uint256 tokenId;

        address seller;
        uint256 buyPrice;
        uint256 timeStamp;
    }

    // next created list id
    Counters.Counter private _listNum;

    // lists
    mapping (uint256 => list) public _lists;
    // 
    mapping (address => Counters.Counter) private _userListIdsCount;

    function userListCount(address owner) public view returns (uint256) {
        require(owner != address(0), "owner is zero address");

        return _userListIdsCount[owner].current();
    }

    function addList (address token, uint256 tokenId, address seller, uint256 buyPrice, uint256 timeStamp) public {
        IKIP17(token).safeTransferFrom(msg.sender, address(this), tokenId, '0x00');

        uint256 listId = _listNum.current();

        _lists[listId] = list(tokenId, seller, buyPrice, timeStamp);
        _userListIdsCount[seller].increment();
        
        _listNum.increment();
    }

    function buyList(address token, uint256 listId) public payable returns (bool) {
        list memory list = _lists[listId];

        address payable receiver = address(uint160(list.seller));

        receiver.transfer(list.buyPrice);
        IKIP17(token).safeTransferFrom(address(this), msg.sender, list.tokenId, '0x00');
    }

    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        return bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"));
    }
}
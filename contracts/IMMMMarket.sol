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
        require(owner != address(0), "Owner is zero address");

        return _userListIdsCount[owner].current();
    }

    function addList(address token, uint256 tokenId, uint256 buyPrice, uint256 timeStamp) public returns (bool) {
        // seller == msg.sender
        IKIP17(token).safeTransferFrom(msg.sender, address(this), tokenId, '0x00');
        
        uint256 listId = _listNum.current();

        if(listId == 0) {
            _listNum._value = 1;
        }

        _lists[listId] = list(tokenId, msg.sender, buyPrice, timeStamp);
        _userListIdsCount[msg.sender].increment();
        
        _listNum.increment();

        return true;
    }

    function buyList(address token, uint256 listId) public payable returns (bool) {
        list memory list = _lists[listId];

        address payable receiver = address(uint160(list.seller));

        receiver.transfer(list.buyPrice);
        IKIP17(token).safeTransferFrom(address(this), msg.sender, list.tokenId, '0x00');

        return true;
    }

    function cancelList(address token, uint256 listId) public returns (bool) {
        list memory list = _lists[listId];

        require(list.seller == msg.sender, "Your not owner");
        IKIP17(token).safeTransferFrom(address(this), list.seller, list.tokenId, '0x00');

        return true;
    }

    // function closeList(address seller, uint256 listId) internal {
    //     _userListIdsCount[seller].decrement();
    //     uint256 lastListCount = _userListIdsCount[seller].current();

    //     for(uint256 i = 0; i < lastListCount; i++) {

    //     }
    //     // delete _lists[listId];

    // }


    function onKIP17Received(address operator, address from, uint256 tokenId, bytes memory data) public returns (bytes4) {
        return bytes4(keccak256("onKIP17Received(address,address,uint256,bytes)"));
    }


}
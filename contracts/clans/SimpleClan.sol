// SPDX-Licensider-Identifier: MIT

pragma solidity ^0.8.0;

import "./IClan.sol";

contract SimpleClan is IClan {
    address public leader;
    string public name;
    string public symbol;
    address[] public members;

    address public factory;

    event MemberAdded(address indexed member, address indexed addedBy);
    event MemberRemoved(address indexed member, address indexed removedBy);
    event Initialized(address indexed leader);
    event NameChanged(string name, address indexed changedBy);
    event SymbolChanged(string symbol, address indexed changedBy);

    function initialize(
        string memory _name,
        string memory _symbol,
        address _leader
    ) external override {
        require(factory == address(0), "Already initialized");
        factory = msg.sender;
        name = _name;
        symbol = _symbol;
        leader = _leader;
        members.push(_leader);
        emit Initialized(_leader);
    }

    function addMember(address _member) external override {
        require(isMember(_member) == false, "Already a member");
        require(msg.sender == leader, "Only the leader can add members");
        members.push(_member);
        emit MemberAdded(_member, msg.sender);
    }

    function removeMember(address _member) external override {
        require(isMember(_member) == true, "Not a member");
        require(msg.sender == leader, "Only the leader can remove members");
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                members[i] = members[members.length - 1];
                members.pop();
                break;
            }
        }
        emit MemberRemoved(_member, msg.sender);
    }

    function isMember(address _member) public view override returns (bool) {
        for (uint i = 0; i < members.length; i++) {
            if (members[i] == _member) {
                return true;
            }
        }
        return false;
    }

    function getMembers() external view override returns (address[] memory) {
        return members;
    }

    function getLeader() external view override returns (address) {
        return leader;
    }

    function getName() external view override returns (string memory) {
        return name;
    }

    function setName(string memory _name) external override {
        require(msg.sender == leader, "Only the leader can set the name");
        name = _name;
        emit NameChanged(_name, msg.sender);
    }

    function getSymbol() external view override returns (string memory) {
        return symbol;
    }

    function setSymbol(string memory _symbol) external override {
        require(msg.sender == leader, "Only the leader can set the symbol");
        symbol = _symbol;
        emit SymbolChanged(_symbol, msg.sender);
    }
}

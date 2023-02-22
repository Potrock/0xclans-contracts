// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IClan.sol";

contract ClanFactoryClones {
    address public immutable implementation;

    mapping(address => address) public getClans; // leader address => clan address
    address[] public allClans;

    event ClanCreated(
        address indexed leader,
        string name,
        string symbol,
        address indexed clan
    );

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function allClansLength() external view returns (uint) {
        return allClans.length;
    }

    function createClan(
        string memory _name,
        string memory _symbol
    ) public returns (address) {
        require(getClans[msg.sender] == address(0), "Already have a clan");
        address _clone = Clones.clone(implementation);
        IClan(_clone).initialize(_name, _symbol, msg.sender);
        getClans[msg.sender] = _clone;
        allClans.push(_clone);
        emit ClanCreated(msg.sender, _name, _symbol, _clone);
        return _clone;
    }
}

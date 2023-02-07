// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "./IClan.sol";

contract ClanFactoryClones {
    address public immutable implementation;

    mapping(address => address) public getClans; // leader address => clan address
    address[] public allClans;

    constructor(address _implementation) {
        implementation = _implementation;
    }

    function allClansLength() external view returns (uint) {
        return allClans.length;
    }

    function createClan(
        string memory _name,
        string memory _symbol,
        address _leader
    ) public returns (address) {
        address _clone = Clones.clone(implementation);
        IClan(_clone).initialize(_name, _symbol, _leader);
        getClans[_leader] = _clone;
        allClans.push(_clone);
        return _clone;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IClan {
    function initialize(
        string memory _name,
        string memory _symbol,
        address _leader
    ) external;

    function addMember(address _member) external;

    function removeMember(address _member) external;

    function isMember(address _member) external view returns (bool);

    function getMembers() external view returns (address[] memory);

    function getLeader() external view returns (address);

    function getName() external view returns (string memory);

    function setName(string memory _name) external;

    function getSymbol() external view returns (string memory);

    function setSymbol(string memory _symbol) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract UserStats {
    // Use a mapping to store key-value pairs for statistics
    mapping(bytes32 => uint) private playerStat;

    // Events
    event StatUpdated(
        address indexed server,
        address indexed player,
        bytes32 statKey,
        uint statValue
    );

    // Update a specific stat for a player
    function updateStat(
        address _player,
        bytes32 _statKey,
        uint _statValue
    ) public {
        bytes32 playerStatKey = getPlayerStatKey(msg.sender, _player, _statKey);
        playerStat[playerStatKey] = _statValue;

        emit StatUpdated(msg.sender, _player, _statKey, _statValue);
    }

    // Get a specific stat for a player from a server
    function getStat(
        address _server,
        address _player,
        bytes32 _statKey
    ) public view returns (uint) {
        bytes32 playerStatKey = getPlayerStatKey(_server, _player, _statKey);
        return playerStat[playerStatKey];
    }

    // Generate a unique key for a player's stat in the mapping
    function getPlayerStatKey(
        address _server,
        address _player,
        bytes32 _statKey
    ) private pure returns (bytes32) {
        return keccak256(abi.encodePacked(_server, _player, _statKey));
    }
}

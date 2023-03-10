// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AccountLinker is ERC2771Context, Ownable {
    using ECDSA for bytes32;

    address public approvedSigner;
    mapping(address => mapping(string => string)) uuidByAddressByPlatform;
    mapping(string => mapping(string => address)) addressByUUIDByPlatform;

    /**
     * Events
     */

    /**
     * Emitted when an account is linked.
     * @param player The address of the player
     * @param platform The platform the player is linking
     * @param uuid The uuid of the player on the platform
     */
    event AccountLinked(address indexed player, string platform, string uuid);
    event AccountUnlinked(address indexed player, string platform, string uuid);

    constructor(address _trustedForwarder) ERC2771Context(_trustedForwarder) {
        approvedSigner = _msgSender();
    }

    /**
     * Data Reads
     */

    function getUuidByPlatformByPlayer(
        address _player,
        string memory _platform
    ) public view returns (string memory) {
        return uuidByAddressByPlatform[_player][_platform];
    }

    function getAddressByUuidByPlatform(
        string memory _uuid,
        string memory _platform
    ) public view returns (address) {
        string memory lowercaseUuid = _stringToLower(_uuid);
        return addressByUUIDByPlatform[lowercaseUuid][_platform];
    }

    /**
     * Data Writes
     */

    function linkPlayerToUuidByPlatform(
        string calldata _uuid,
        string calldata _platform,
        bytes calldata _signature
    ) public {
        string memory lowercaseUuid = _stringToLower(_uuid);
        require(
            _verifyApprovedSigner(
                keccak256(abi.encode(_msgSender(), lowercaseUuid, _platform)),
                _signature
            ),
            "Invalid signature"
        );

        uuidByAddressByPlatform[_msgSender()][_platform] = lowercaseUuid;
        addressByUUIDByPlatform[lowercaseUuid][_platform] = _msgSender();

        emit AccountLinked(_msgSender(), _platform, lowercaseUuid);
    }

    function unlinkPlayerByPlatform(string calldata _platform) public {
        string memory uuid = uuidByAddressByPlatform[_msgSender()][_platform];
        delete uuidByAddressByPlatform[_msgSender()][_platform];
        delete addressByUUIDByPlatform[uuid][_platform];

        emit AccountUnlinked(_msgSender(), _platform, uuid);
    }

    /**
     * Utils
     */

    function _stringToLower(
        string memory _base
    ) internal pure returns (string memory) {
        bytes memory _baseBytes = bytes(_base);

        for (uint16 i = 0; i < _baseBytes.length; i++) {
            _baseBytes[i] = (_baseBytes[i] >= 0x41 && _baseBytes[i] <= 0x5A)
                ? bytes1(uint8(_baseBytes[i]) + 32)
                : _baseBytes[i];
        }

        return string(_baseBytes);
    }

    function setPrimarySigner(address _approvedSigner) external onlyOwner {
        require(_approvedSigner != address(0), "Invalid address");
        approvedSigner = _approvedSigner;
    }

    /**
     * Security
     */

    function _verifyApprovedSigner(
        bytes32 hash,
        bytes calldata signature
    ) internal view returns (bool) {
        return
            approvedSigner == hash.toEthSignedMessageHash().recover(signature);
    }

    /**
     * Overrides
     */

    function _msgSender()
        internal
        view
        override(Context, ERC2771Context)
        returns (address)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }
}

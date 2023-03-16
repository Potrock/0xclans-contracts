const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("AccountLinker", function () {
	let AccountLinker,
		accountLinker,
		owner,
		approvedSigner,
		player,
		other,
		trustedForwarder;

	beforeEach(async function () {
		AccountLinker = await ethers.getContractFactory("AccountLinker");
		[approvedSigner, player, other, trustedForwarder, ...addrs] =
			await ethers.getSigners();
		accountLinker = await AccountLinker.deploy(trustedForwarder.address);
		await accountLinker.deployed();
	});

	it("Should link and retrieve a UUID correctly", async function () {
		const platform = "steam";
		const uuid = "EXAMPLE_UUID";

		// Generate a signature
		const messageHash = ethers.utils.keccak256(
			ethers.utils.defaultAbiCoder.encode(
				["address", "string", "string"],
				[player.address, uuid.toLowerCase(), platform]
			)
		);
		const signature = await approvedSigner.signMessage(
			ethers.utils.arrayify(messageHash)
		);

		// Link the UUID to the player
		await accountLinker
			.connect(player)
			.linkPlayerToUuidByPlatform(uuid, platform, signature);

		// Retrieve the UUID
		const retrievedUuid = await accountLinker.getUuidByPlatformByPlayer(
			player.address,
			platform
		);
		const retrievedAddress = await accountLinker.getAddressByUuidByPlatform(
			uuid,
			platform
		);

		expect(retrievedUuid).to.equal(uuid.toLowerCase());
		expect(retrievedAddress).to.equal(player.address);
	});

	it("Should unlink a UUID correctly", async function () {
		const platform = "steam";
		const uuid = "EXAMPLE_UUID";

		// Generate a signature
		const messageHash = ethers.utils.keccak256(
			ethers.utils.defaultAbiCoder.encode(
				["address", "string", "string"],
				[player.address, uuid.toLowerCase(), platform]
			)
		);
		const signature = await approvedSigner.signMessage(
			ethers.utils.arrayify(messageHash)
		);

		// Link the UUID to the player
		await accountLinker
			.connect(player)
			.linkPlayerToUuidByPlatform(uuid, platform, signature);

		// Unlink the UUID
		await accountLinker.connect(player).unlinkPlayerByPlatform(platform);

		// Retrieve the UUID
		const retrievedUuid = await accountLinker.getUuidByPlatformByPlayer(
			player.address,
			platform
		);
		const retrievedAddress = await accountLinker.getAddressByUuidByPlatform(
			uuid,
			platform
		);

		expect(retrievedUuid).to.equal("");
		expect(retrievedAddress).to.equal(ethers.constants.AddressZero);
	});

	it("Should not allow linking with an invalid signature", async function () {
		const platform = "steam";
		const uuid = "EXAMPLE_UUID";
		const invalidSignature =
			"0x29a729129414365c6dcaed3f09b6564e243062fcc64eb29232af24862db7d6747b9458a02f5e568e6c2026ed473314ea5619d9a7e50e1e6bbcbe8d5f3d60cecd1b";

		await expect(
			accountLinker
				.connect(player)
				.linkPlayerToUuidByPlatform(uuid, platform, invalidSignature)
		).to.be.revertedWith("Invalid signature");
	});

	it("Should emit AccountLinked and AccountUnlinked events", async function () {
		const platform = "steam";
		const uuid = "EXAMPLE_UUID";

		// Generate a signature
		const messageHash = ethers.utils.keccak256(
			ethers.utils.defaultAbiCoder.encode(
				["address", "string", "string"],
				[player.address, uuid.toLowerCase(), platform]
			)
		);
		const signature = await approvedSigner.signMessage(
			ethers.utils.arrayify(messageHash)
		);

		// Check AccountLinked event
		await expect(
			accountLinker
				.connect(player)
				.linkPlayerToUuidByPlatform(uuid, platform, signature)
		)
			.to.emit(accountLinker, "AccountLinked")
			.withArgs(player.address, platform, uuid.toLowerCase());

		// Check AccountUnlinked event
		await expect(
			accountLinker.connect(player).unlinkPlayerByPlatform(platform)
		)
			.to.emit(accountLinker, "AccountUnlinked")
			.withArgs(player.address, platform, uuid.toLowerCase());
	});

	it("Should allow updating the primary signer", async function () {
		await accountLinker
			.connect(approvedSigner)
			.setPrimarySigner(other.address);
		const updatedSigner = await accountLinker.approvedSigner();
		expect(updatedSigner).to.equal(other.address);
	});

	it("Should not allow updating the primary signer by non-owner", async function () {
		await expect(
			accountLinker.connect(player).setPrimarySigner(other.address)
		).to.be.revertedWith("Ownable: caller is not the owner");
	});
});

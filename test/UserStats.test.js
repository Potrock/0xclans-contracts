const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("UserStats", function () {
	let UserStats, userStats, owner, server1, player1, player2;

	beforeEach(async function () {
		UserStats = await ethers.getContractFactory("UserStats");
		[owner, server1, player1, player2, ...addrs] =
			await ethers.getSigners();
		userStats = await UserStats.deploy();
		await userStats.deployed();
	});

	it("Should update and retrieve stats correctly", async function () {
		const statKey = ethers.utils.keccak256(
			ethers.utils.toUtf8Bytes("totalGames")
		);
		const statValue = 10;

		// Server1 updates player1's stat
		await userStats
			.connect(server1)
			.updateStat(player1.address, statKey, statValue);

		// Check if the stat was updated correctly
		const retrievedStat = await userStats.getStat(
			server1.address,
			player1.address,
			statKey
		);
		expect(retrievedStat).to.equal(statValue);
	});

	it("Should keep data separate between players and servers", async function () {
		const statKey = ethers.utils.keccak256(
			ethers.utils.toUtf8Bytes("totalWins")
		);
		const statValue1 = 3;
		const statValue2 = 7;

		// Server1 updates player1's stat
		await userStats
			.connect(server1)
			.updateStat(player1.address, statKey, statValue1);

		// Server1 updates player2's stat
		await userStats
			.connect(server1)
			.updateStat(player2.address, statKey, statValue2);

		// Check if the stats were updated correctly
		const retrievedStat1 = await userStats.getStat(
			server1.address,
			player1.address,
			statKey
		);
		const retrievedStat2 = await userStats.getStat(
			server1.address,
			player2.address,
			statKey
		);

		expect(retrievedStat1).to.equal(statValue1);
		expect(retrievedStat2).to.equal(statValue2);
	});

	it("Should emit StatUpdated event", async function () {
		const statKey = ethers.utils.keccak256(
			ethers.utils.toUtf8Bytes("totalLosses")
		);
		const statValue = 8;

		// Check if the event is emitted with the correct values
		await expect(
			userStats
				.connect(server1)
				.updateStat(player1.address, statKey, statValue)
		)
			.to.emit(userStats, "StatUpdated")
			.withArgs(server1.address, player1.address, statKey, statValue);
	});
});

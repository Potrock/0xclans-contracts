const hre = require("hardhat");

async function main() {
	const ClanFactory = await hre.ethers.getContractFactory(
		"ClanFactoryClones"
	);
	const clanFactory = await ClanFactory.deploy(
		"0xf2665CC4e237568fB524d7d1AfA0Ae140323F1fD"
	);

	await clanFactory.deployed();

	console.log("Clan Clone Factory deployed to:", clanFactory.address);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});

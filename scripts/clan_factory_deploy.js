const hre = require("hardhat");

async function main() {
	const ClanFactory = await hre.ethers.getContractFactory(
		"ClanFactoryClones"
	);
	const clanFactory = await ClanFactory.deploy(
		"0xa11d5D6f84fD2B3Cdea1a1F3d2ce45c3CB06628c"
	);

	await clanFactory.deployed();

	console.log("Clan Clone Factory deployed to:", clanFactory.address);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});

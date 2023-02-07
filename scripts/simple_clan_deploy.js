const hre = require("hardhat");

async function main() {
	const SimpleClan = await hre.ethers.getContractFactory("SimpleClan");
	const simpleClan = await SimpleClan.deploy();

	await simpleClan.deployed();

	console.log("Simple Clan Template deployed to:", simpleClan.address);
}

main().catch((error) => {
	console.error(error);
	process.exitCode = 1;
});

const hre = require("hardhat");

async function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const tokenContract = await hre.ethers.deployContract("Token");
  await tokenContract.waitForDeployment();
  console.log("Token deployed to:", tokenContract.target);

  const exchangeContract = await hre.ethers.deployContract("Exchange", [
    tokenContract.target,
  ]);
  await exchangeContract.waitForDeployment();
  console.log("Exchange deployed to:", exchangeContract.target);

  await sleep(30 * 1000);

  await hre.run("verify:verify", {
    address: tokenContract.target,
    constructorArguments: [],
    contract: "contracts/Token.sol:Token",
  });

  await hre.run("verify:verify", {
    address: exchangeContract.target,
    constructorArguments: [tokenContract.target],
  });
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

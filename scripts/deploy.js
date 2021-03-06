// We require the Hardhat Runtime Environment explicitly here. This is optional 
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile 
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy
  const ReferUsers = await hre.ethers.getContractFactory("ReferUsers");
  const refUsers = await ReferUsers.deploy();

  const Honey = await hre.ethers.getContractFactory("Honey");
  const hny = await Honey.deploy(
    'LHoney', 
    'THNY', 
    ['0x02C2fCAfCe36B4AAdB39625866Bc6B1699d83043'], 
    1000000000,
    '0x02C2fCAfCe36B4AAdB39625866Bc6B1699d83043', 
    );

  await refUsers.deployed();
  await hny.deployed();

  console.log("ReferUsers deployed to:", refUsers.address);
  console.log("Honey deployed to:", hny.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
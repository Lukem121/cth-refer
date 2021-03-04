async function main() {
  // We get the contract to deploy
  const ReferUser = await ethers.getContractFactory("ReferUser");
  const rfUser = await ReferUser.deploy("Hello, Hardhat!");

  console.log("Greeter deployed to:", rfUser.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
const main = async () => {
  /**
   * This will actually compile our contract and generate the necessary files
   * we need to work with our contract under the artifacts directory.
   *
   * we use hre.ethers, but hre is never imported anywhere
   * The Hardhat Runtime Environment, or HRE for short,
   * is an object containing all the functionality that Hardhat exposes when running a task, test or script.
   * In reality, Hardhat is the HRE.
   */
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");

  /**
   * this deploy our contract to the blockchain
   * What's happening here is Hardhat will create a local Ethereum network for us, but just for this contract.
   * Then, after the script completes it'll destroy that local network.
   * So, every time you run the contract, it'll be a fresh blockchain.
   */
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });

  /**
   * We'll wait until our contract is officially deployed to our local blockchain!
   * Our constructor runs when we actually deploy.
   */
  await waveContract.deployed();

  /**
   * once it's deployed waveContract.address will basically give us the address of the deployed contract
   */
  console.log("Contract addy:", waveContract.address);

  /*
   * Get Contract balance
   */
  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  /**
   * Basically, we need to manually call our functions! Just like we would any normal API.
   * First I call the function to grab the # of total waves. Then, I do the wave. Finally,
   * I grab the waveCount one more time to see if it changed.
   */
  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log(waveCount.toNumber());

  /**
   * Let's try two waves now
   */
  let waveTxn = await waveContract.wave("This is wave #1");
  await waveTxn.wait(); // Wait for the transaction to be mined

  let waveTxn2 = await waveContract.wave("This is wave #2");
  await waveTxn2.wait(); // Wait for the transaction to be mined

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  const allWaves = await waveContract.getAllWaves();
  console.log("All Waves:", allWaves);
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();

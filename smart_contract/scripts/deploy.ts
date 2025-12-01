const hre = require("hardhat");

async function main() {
  console.log("Starting Voting contract deployment...");

  // Define your candidates here
  const candidateNames = [
    "Alice Johnson",
    "Bob Smith",
    "Carol Williams"
  ];

  console.log("Candidates to be added:");
  candidateNames.forEach((name, index) => {
    console.log(`${index + 1}. ${name}`);
  });

  // Deploy the contract
  const Voting = await hre.ethers.getContractFactory("Voting");
  const voting = await Voting.deploy(candidateNames);

  await voting.waitForDeployment();

  const contractAddress = await voting.getAddress();
  
  console.log("\n✅ Voting contract deployed successfully!");
  console.log(`📍 Contract Address: ${contractAddress}`);

  // Verify the deployment by fetching candidates
  console.log("\nVerifying deployment...");
  const allCandidates = await voting.getAllCandidates();
  
  console.log("\nCandidates in the contract:");
  allCandidates.forEach((candidate: { name: any; voteCount: any; }, index: any) => {
    console.log(`${index}. ${candidate.name} - Votes: ${candidate.voteCount}`);
  });

  // Save deployment info
  const deploymentInfo = {
    contractAddress: contractAddress,
    network: hre.network.name,
    deployer: (await hre.ethers.getSigners())[0].address,
    timestamp: new Date().toISOString(),
    candidates: candidateNames
  };

  console.log("\n📋 Deployment Summary:");
  console.log(JSON.stringify(deploymentInfo, null, 2));

  // For verification on block explorers (optional)
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("\n⏳ Waiting for block confirmations...");
    await voting.deploymentTransaction().wait(6);
    
    console.log("\nVerifying contract on block explorer...");
    try {
      await hre.run("verify:verify", {
        address: contractAddress,
        constructorArguments: [candidateNames],
      });
      console.log("✅ Contract verified successfully!");
    } catch (error) {
      console.log("⚠️ Verification failed:", error instanceof Error ? error.message : String(error));
    }
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
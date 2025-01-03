const fs = require("fs");
const { Contract, providers } = require("starknet");
const { verifyZkProof } = require("./verifyProof");

async function sendProofVerificationResult(isValid) {
  const provider = new providers.JsonRpcProvider("http://localhost:5000"); 

  const contractAddress = process.env.CONTRACT_ADDRESS;
  const abi = JSON.parse(fs.readFileSync("contract_abi.json"));
  const contract = new Contract(abi, contractAddress, provider);

  const proofVerificationResult = isValid ? 1 : 0; 

  try {
    await contract.verify_zk_proof(proofVerificationResult);
    console.log("Proof verification result sent to smart contract:", isValid);
  } catch (error) {
    console.error("Error sending verification result to contract:", error);
  }
}

async function processZkProof(proofPath, verificationKeyPath) {
  try {
    const isValid = await verifyZkProof(proofPath, verificationKeyPath);
    await sendProofVerificationResult(isValid);
  } catch (error) {
    console.error("Error during proof verification process:", error);
  }
}

const proofFilePath = "path/to/your/proof.json"; 
const verificationKeyFilePath = "path/to/your/vk.json"; 

processZkProof(proofFilePath, verificationKeyFilePath);

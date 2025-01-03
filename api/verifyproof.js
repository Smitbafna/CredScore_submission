const snarkjs = require("snarkjs");
const fs = require("fs");

async function verifyZkProof(proofPath, verificationKeyPath) {
  const verificationKey = JSON.parse(fs.readFileSync(verificationKeyPath));
  const proofData = JSON.parse(fs.readFileSync(proofPath));

  const result = await snarkjs.groth16.verify(verificationKey, proofData.inputs, proofData.proof);

  return result;
}

module.exports = { verifyZkProof };

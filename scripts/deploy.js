const hre = require("hardhat");

async function main() {
  const FanVault = await hre.ethers.getContractFactory("FanVault"); // Toma el contrato FanVault.sol, lo compila y lo deja listo para ser desplegado.
  const fanVault = await FanVault.deploy(); // Lo despliega (lo sube) a la red blockchain elegida.

  await fanVault.waitForDeployment();
  console.log(`✅ FanVault desplegado en: ${fanVault.target}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("❌ Error al desplegar:", error);
    process.exit(1);
  });


  //npx hardhat run scripts/deploy.js --network sepolia   , con esta linea subimso el contrato directamente en sepolia. 

import "dotenv/config";
import { Ed25519Keypair } from "@mysten/sui/keypairs/ed25519";
import { fromBase64 } from "@mysten/sui/utils";
import { SuiClient, getFullnodeUrl } from "@mysten/sui/client";
import { Transaction } from "@mysten/sui/transactions";
import path, { dirname } from "path";
import { execSync } from "child_process";
import { fileURLToPath } from "url";

const priv_key = process.env.PRIVATE_KEY;
if (!priv_key) {
  console.error("Please set PRIVATE_KEY in .env file");
  process.exit(1);
}

const keyPair = Ed25519Keypair.fromSecretKey(fromBase64(priv_key).slice(1));

const client = new SuiClient({ url: getFullnodeUrl("testnet") });
console.log("Client created", client);

const path_to_contracts = path.join(
  dirname(fileURLToPath(import.meta.url)),
  "../../contracts"
);

const { dependencies, modules } = JSON.parse(
  execSync(
    `sui move build --dump-bytecode-as-base64 --path ${path_to_contracts}`,
    { encoding: "utf-8" }
  )
);

console.log("Deploying contracts...", keyPair.toSuiAddress());
console.log(dependencies, modules);

const deploy_trx = new Transaction();

const [upgradeCap] = deploy_trx.publish({
  modules,
  dependencies,
});

// Transfer the upgrade capability object to the deployer address
deploy_trx.transferObjects([upgradeCap], keyPair.getPublicKey().toSuiAddress());

const { objectChanges, balanceChanges } =
  await client.signAndExecuteTransaction({
    signer: keyPair,
    transaction: deploy_trx,
    options: {
      showBalanceChanges: true,
      showEffects: true,
      showEvents: true,
      showObjectChanges: true,
    },
  });
console.log("Transaction Successful:", objectChanges, balanceChanges);

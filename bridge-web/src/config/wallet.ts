import { connectorsForWallets } from "@rainbow-me/rainbowkit";
import { metaMaskWallet } from "@rainbow-me/rainbowkit/wallets";
import { createConfig, http } from "wagmi";
import { chainConfigs } from "./config";
import { Chain } from "viem/chains";

const mappedChains = Object.values(chainConfigs)
  .map((config) => config.wagmiChain)
  .filter((chain): chain is Chain => chain !== undefined);

if (mappedChains.length === 0) {
  throw new Error("No valid chains found in configuration.");
}

const chains = [mappedChains[0], ...mappedChains.slice(1)] as const; // Ensures readonly tuple type

const projectId = ""; // Add your WalletConnect project ID here

const connectors = connectorsForWallets(
  [
    {
      groupName: "Recommended",
      wallets: [metaMaskWallet],
    },
  ],
  {
    appName: "ZilBridge",
    projectId,
  }
);

export const wagmiConfig = createConfig({
  chains,
  connectors,
  transports: chains.reduce((obj, chainItem) => {
    obj[chainItem.id] = http();
    return obj;
  }, {} as Record<number, ReturnType<typeof http>>),
  ssr: true, // If your app is server-side rendered
});

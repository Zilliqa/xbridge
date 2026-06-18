import { connectorsForWallets } from "@rainbow-me/rainbowkit";
import { zilPayWallet, metaMaskWallet } from "@rainbow-me/rainbowkit/wallets";
import { createConfig, http } from "wagmi";
import { chainConfigs } from "./config";
import { Chain } from "viem/chains";

const mappedChains = Object.values(chainConfigs)
  .map((config) => config.wagmiChain)
  .filter((chain): chain is Chain => chain !== undefined);

if (mappedChains.length === 0) {
  throw new Error("No valid chains found in configuration.");
}

const chains = [mappedChains[0], ...mappedChains.slice(1)] as const;

const projectId = "5f13b7ba-872f-4c0b-9468-dbe8cef53373";

const connectors = connectorsForWallets(
  [
    {
      groupName: "Recommended",
      wallets: [zilPayWallet], 
    },
    {
      groupName: "Popular",
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
  ssr: true, 
});


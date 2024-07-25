import { Chain } from "viem";
import { bsc, bscTestnet, zilliqa, zilliqaTestnet } from "viem/chains";
import fps_token from "../assets/fps_token.png";
import test_hrse_token from "../assets/salami_hrse.webp";
import hrse_token from "../assets/hrse_token.webp";
import seed_token from "../assets/seed_token.png";

export enum TokenManagerType {
  MintAndBurn,
  LockAndRelease,
  ZilBridge
}

export type Chains = "bsc-testnet" | "zq-testnet" | "bsc" | "zq";

function configureCustomRpcUrl(chain: Chain, rpcUrl: string): Chain {
  return {
    ...chain,
    rpcUrls: {
      default: { http: [rpcUrl] },
      public: { http: [rpcUrl] },
    },
  };
}

export const config: SiteConfig = {
  addTokensToMetamask: true
}

export const chainConfigs: Partial<Record<Chains, ChainConfig>> =
  import.meta.env.MODE === "production"
    ? {
        zq: {
          chain: "zq",
          name: "Zilliqa",
          chainGatewayAddress: "0xbA44BC29371E19117DA666B729A1c6e1b35DDb40",
          wagmiChain: zilliqa,
          tokens: [
            {
              name: "HRSE",
              address: "0x63B991C17010C21250a0eA58C6697F696a48cdf3",
              blockExplorer:
                "https://otterscan.zilliqa.com/address/0x63B991C17010C21250a0eA58C6697F696a48cdf3",
              logo: hrse_token,
              tokenManagerAddress: "0x6D61eFb60C17979816E4cE12CD5D29054E755948",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
            {
              name: "FPS",
              address: "0x241c677D9969419800402521ae87C411897A029f",
              blockExplorer:
                "https://otterscan.zilliqa.com/address/0x241c677D9969419800402521ae87C411897A029f",
              logo: fps_token,
              tokenManagerAddress: "0x6D61eFb60C17979816E4cE12CD5D29054E755948",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
          ],
          chainId: 32769,
          isZilliqa: true,
          blockExplorer: "https://otterscan.zilliqa.com/tx/",
          nativeTokenSymbol: "ZIL",
        },
        bsc: {
          chain: "bsc",
          name: "BSC",
          wagmiChain: configureCustomRpcUrl(
            bsc,
            `${import.meta.env.VITE_BSC_MAINNET_API}/${import.meta.env.VITE_BSC_MAINNET_KEY}`,
          ),
          chainGatewayAddress: "0x3967f1a272Ed007e6B6471b942d655C802b42009",
          tokens: [
            {
              name: "HRSE",
              address: "0x3BE0E5EDC58bd55AAa381Fa642688ADC289c05a3",
              blockExplorer:
                "https://bscscan.com/address/0x3BE0E5EDC58bd55AAa381Fa642688ADC289c05a3",
              logo: hrse_token,
              tokenManagerAddress: "0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
            {
              name: "FPS",
              address: "0x351dA1E7500aBA1d168b9435DCE73415718d212F",
              blockExplorer:
                "https://bscscan.com/address/0x351dA1E7500aBA1d168b9435DCE73415718d212F",
              logo: fps_token,
              tokenManagerAddress: "0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
          ],
          chainId: 56,
          isZilliqa: false,
          blockExplorer: "https://bscscan.com/tx/",
          nativeTokenSymbol: "BNB",
        },
      }
    : {
        "zq-testnet": {
          chain: "zq-testnet",
          name: "Zilliqa Testnet",
          chainGatewayAddress: "0x7370e69565BB2313C4dA12F9062C282513919230",
          wagmiChain: zilliqaTestnet,
          tokens: [
            {
              name: "xTST",
              address: "0x8CB156B19947283F9700e5891ed6d013454b0570",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x8CB156B19947283F9700e5891ed6d013454b0570",
              logo: fps_token,
              tokenManagerAddress: "0xBe90AB2cd65E207F097bEF733F8D239A59698b8A",
              tokenManagerType: TokenManagerType.ZilBridge,
            },
            {
              name: "ZBTST",
              address: "0x2A82a13A118c0f9E203a9C006742024354D0f4Ca",
              blockExplorer:
              "https://otterscan.testnet.zilliqa.com/address/0x2A82a13A118c0f9E203a9C006742024354D0f4Ca",
              logo: test_hrse_token,
              tokenManagerAddress: "0x86c4405C2e3914490BC043A19dA5373D6d187aa7",
              tokenManagerType: TokenManagerType.ZilBridge,
            },
            {
              name: "SEED",
              address: "0x28e8d39Fc68eaA27c88797Eb7D324b4B97D5b844",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x28e8d39Fc68eaA27c88797Eb7D324b4B97D5b844",
              logo: seed_token,
            },
          ],
          chainId: 33101,
          isZilliqa: true,
          blockExplorer: "https://otterscan.testnet.zilliqa.com/tx/",
          nativeTokenSymbol: "ZIL",
        },
        "bsc-testnet": {
          chain: "bsc-testnet",
          name: "BSC Testnet",
          wagmiChain: configureCustomRpcUrl(
            bscTestnet,
            `${import.meta.env.VITE_BSC_TESTNET_API}/${import.meta.env.VITE_BSC_TESTNET_KEY}`,
          ),
          chainGatewayAddress: "0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE",
          tokens: [
            {
              name: "TST",
              address: "0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3",
              blockExplorer:
              "https://testnet.bscscan.com/address/0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3",
              logo: fps_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
            {
              name: "eZBTST",
              address: "0x201eDd0521cF4B577399F789e22E05405D500163",
              blockExplorer:
              "https://testnet.bscscan.com/address/0x201eDd0521cF4B577399F789e22E05405D500163",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
            {
              name: "SEED",
              address: "0x486722DbA2F76aeFb9977641D11f3aC3e5bA281f",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x486722DbA2F76aeFb9977641D11f3aC3e5bA281f",
              logo: seed_token,
            },
          ],
          chainId: 97,
          isZilliqa: false,
          blockExplorer: "https://testnet.bscscan.com/tx/",
          nativeTokenSymbol: "BNB",
        },
      };

export type ChainConfig = {
  name: string;
  chain: Chains;
  wagmiChain: Chain;
  chainGatewayAddress: `0x${string}`;
  tokens: TokenConfig[];
  chainId: number;
  isZilliqa: boolean;
  blockExplorer: string;
  nativeTokenSymbol: string;
};

export type TokenConfig = {
  name: string;
  address: `0x${string}`;
  blockExplorer: string;
  logo?: string;
  tokenManagerAddress: `0x${string}`;
  tokenManagerType: TokenManagerType;
};

export type SiteConfig = {
  addTokensToMetamask: boolean
}

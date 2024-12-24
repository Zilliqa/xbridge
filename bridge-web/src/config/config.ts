import { Chain } from "viem";
import { bsc, bscTestnet, zilliqa, zilliqaTestnet } from "viem/chains";
import fps_token from "../assets/fps_token.png";
import test_hrse_token from "../assets/salami_hrse.webp";
import hrse_token from "../assets/hrse_token.webp";
import seed_token from "../assets/seed_token.png";

export enum TokenManagerType {
  MintAndBurn,
  LockAndRelease,
  ZilBridge,
}

export type Chains = "bsc-testnet" | "zq-testnet" | "bsc" | "zq";

export const siteConfig: SiteConfig = {
  addTokensToMetamask: false,
  showAllowance: false,
  allowZeroValueTransfers: false,
  logTxnHashes: false,
};

function configureCustomRpcUrl(chain: Chain, rpcUrl: string): Chain {
  return {
    ...chain,
    rpcUrls: {
      default: { http: [rpcUrl] },
      public: { http: [rpcUrl] },
    },
  };
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
              name: "SEED",
              address: "0xe64cA52EF34FdD7e20C0c7fb2E392cc9b4F6D049",
              blockExplorer:
                "https://otterscan.zilliqa.com/address/0xe64cA52EF34FdD7e20C0c7fb2E392cc9b4F6D049",
              logo: seed_token,
              tokenManagerAddress: "0x6D61eFb60C17979816E4cE12CD5D29054E755948",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
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
              name: "SEED",
              address: "0x9158dF7da69b048a296636D5DE7a3d9A7FB25E88",
              blockExplorer:
                "https://bscscan.com/address/0x9158dF7da69b048a296636D5DE7a3d9A7FB25E88",
              logo: seed_token,
              tokenManagerAddress: "0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
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
              name: "SEED",
              address: "0x28e8d39Fc68eaA27c88797Eb7D324b4B97D5b844",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x28e8d39Fc68eaA27c88797Eb7D324b4B97D5b844",
              logo: seed_token,
              tokenManagerAddress: "0x1509988c41f02014aA59d455c6a0D67b5b50f129",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
            {
              name: "TST",
              address: "0x8618d39a8276D931603c6Bc7306af6A53aD2F1F3",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x8618d39a8276D931603c6Bc7306af6A53aD2F1F3",
              logo: fps_token,
              tokenManagerAddress: "0x1509988c41f02014aA59d455c6a0D67b5b50f129",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
            {
              name: "TSLM Z",
              address: "0xE90Dd366D627aCc5feBEC126211191901A69f8a0",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0xE90Dd366D627aCc5feBEC126211191901A69f8a0",
              logo: test_hrse_token,
              tokenManagerAddress: "0x1509988c41f02014aA59d455c6a0D67b5b50f129",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
            {
              name: "xTST",
              address: "0x9Be4DCfB335A263c65a8A763d55710718bbdb416",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x9Be4DCfB335A263c65a8A763d55710718bbdb416",
              logo: fps_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
            },
            {
              name: "ZBTST",
              address: "0xd3750B930ED52C26584C18B4f5eeAb986D7f3b36",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0xd3750B930ED52C26584C18B4f5eeAb986D7f3b36",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
            },
            {
              name: "zBNB",
              address: "0x40647A0C0024755Ef48Bc7C26a979ED833Eb6a15",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x40647A0C0024755Ef48Bc7C26a979ED833Eb6a15",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
            },
            {
              name: "ZIL",
              address: null,
              blockExplorer: "https://otterscan.testnet.zilliqa.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
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
              name: "SEED",
              address: "0x486722DbA2F76aeFb9977641D11f3aC3e5bA281f",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x486722DbA2F76aeFb9977641D11f3aC3e5bA281f",
              logo: seed_token,
              tokenManagerAddress: "0xA6D73210AF20a59832F264fbD991D2abf28401d0",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
            {
              name: "TST",
              address: "0x5190e8b4Bbe8C3a732BAdB600b57fD42ACbB9F4B",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x5190e8b4Bbe8C3a732BAdB600b57fD42ACbB9F4B",
              logo: fps_token,
              tokenManagerAddress: "0xA6D73210AF20a59832F264fbD991D2abf28401d0",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
            {
              name: "TSLM B",
              address: "0x7Cc585de659E8938Aa7d5709BeaF34bD108bdC03",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x7Cc585de659E8938Aa7d5709BeaF34bD108bdC03",
              logo: test_hrse_token,
              tokenManagerAddress: "0xA6D73210AF20a59832F264fbD991D2abf28401d0",
              tokenManagerType: TokenManagerType.MintAndBurn,
            },
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
              name: "BNB",
              address: null,
              blockExplorer: "https://testnet.bscscan.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.LockAndRelease,
            },
            {
              name: "eZIL",
              address: "0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41",
              blockExplorer:
                "https://testnet.bscscan.com/address/0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
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
  address: `0x${string}` | null;
  blockExplorer: string;
  logo?: string;
  tokenManagerAddress: `0x${string}`;
  tokenManagerType: TokenManagerType;
};

export type SiteConfig = {
  addTokensToMetamask: boolean;
  showAllowance: boolean;
  allowZeroValueTransfers: boolean;
  logTxnHashes: boolean;
};

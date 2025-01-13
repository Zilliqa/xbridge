import { Chain } from "viem";
import { bsc, bscTestnet, zilliqa, zilliqaTestnet, polygon, arbitrum, mainnet } from "viem/chains";
import fps_token from "../assets/fps_token.png";
import test_hrse_token from "../assets/salami_hrse.webp";
import hrse_token from "../assets/hrse_token.webp";
import seed_token from "../assets/seed_token.png";

export enum TokenManagerType {
  MintAndBurn,
  LockAndRelease,
  ZilBridge,
}

export type Chains = "bsc-testnet" | "zq-testnet" | "bsc" | "zq" | "polygon" | "arbitrum" | "ethereum";

export const siteConfig: SiteConfig = {
  addTokensToMetamask: false,
  showAllowance: false,
  allowZeroValueTransfers: false,
  logTxnHashes: false,
  defaultFromNetwork: import.meta.env.MODE == "production" ? "zq" : "zq-testnet",
  defaultToNetwork: import.meta.env.MODE == "production" ? "ethereum" : "bsc-testnet",
  homeNetwork: import.meta.env.MODE == "production" ? "zq" : "zq-testnet"
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
              bridgesTo: [ "bsc" ]
            },
            {
              name: "HRSE",
              address: "0x63B991C17010C21250a0eA58C6697F696a48cdf3",
              blockExplorer:
                "https://otterscan.zilliqa.com/address/0x63B991C17010C21250a0eA58C6697F696a48cdf3",
              logo: hrse_token,
              tokenManagerAddress: "0x6D61eFb60C17979816E4cE12CD5D29054E755948",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "bsc" ]
            },
            {
              name: "FPS",
              address: "0x241c677D9969419800402521ae87C411897A029f",
              blockExplorer:
                "https://otterscan.zilliqa.com/address/0x241c677D9969419800402521ae87C411897A029f",
              logo: fps_token,
              tokenManagerAddress: "0x6D61eFb60C17979816E4cE12CD5D29054E755948",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "bsc" ]
            },
              {
              name: "MATIC",
              address: "0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b",
              logo: test_hrse_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "polygon" ]
            },
            {
              name: "ZIL",
              address: null,
              blockExplorer: "https://otterscan.testnet.zilliqa.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum", "polygon", "arbitrum", "bsc" ]
            },
            {
              name: "XCAD",
              address: "0xCcF3Ea256d42Aeef0EE0e39Bfc94bAa9Fa14b0Ba",
              blockExplorer: "https://otterscan.zilliqa.com/address/0xCcF3Ea256d42Aeef0EE0e39Bfc94bAa9Fa14b0Ba",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
             {
               name: "ETH",
               address: "0x17D5af5658A24bd964984b36d28e879a8626adC3",
               blockExplorer: "https://otterscan.zilliqa.com/address/0x17D5af5658A24bd964984b36d28e879a8626adC3",
               logo: fps_token,
               tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
               tokenManagerType: TokenManagerType.LockAndRelease,
               bridgesTo: [ "ethereum", "arbitrum" ]
             },
            {
              name: "OPUL",
              address: "0x8DEAdC20f7218994c86b59eE1D5c7979fFcAa893",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x17D5af5658A24bd964984b36d28e879a8626adC3",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "BRKL",
              address: "0xD819257C964A78A493DF93D5643E9490b54C5af2",
              blockExplorer: "https://otterscan.zilliqa.com/address/0xD819257C964A78A493DF93D5643E9490b54C5af2",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "WBTC",
              address: "0x2938fF251Aecc1dfa768D7d0276eB6d073690317",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x2938fF251Aecc1dfa768D7d0276eB6d073690317",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "USDT",
              address: "0x2274005778063684fbB1BfA96a2b725dC37D75f9",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x2274005778063684fbB1BfA96a2b725dC37D75f9",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "TRAXX",
              address: "0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "LUNR",
              address: "0xE9D47623bb2B3C497668B34fcf61E101a7ea4058",
              blockExplorer: "https://otterscan.zilliqa.com/address/0xE9D47623bb2B3C497668B34fcf61E101a7ea4058",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "dXCAD",
              address: "0xa0A5795e7eccc43Ba92d2A0b7804696F8B9e1a05",
              blockExplorer: "https://otterscan.zilliqa.com/address/0xa0A5795e7eccc43Ba92d2A0b7804696F8B9e1a05",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "PORT",
              address: "0x1202078D298Ff0358A95b6fbf48Ec166dB414660",
              blockExplorer: "https://otterscan.zilliqa.com/address/0x1202078D298Ff0358A95b6fbf48Ec166dB414660",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
            {
              name: "UNIFEES",
              address: "0xc99ECB82a27B45592eA02ACe9e3C42050f3c00C0",
              blockExplorer: "https://otterscan.zilliqa.com/address/0xc99ECB82a27B45592eA02ACe9e3C42050f3c00C0",
              logo: seed_token,
              tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "ethereum" ]
            },
          ],
          chainId: 32769,
          isZilliqa: true,
          blockExplorer: "https://otterscan.zilliqa.com/tx/",
          nativeTokenSymbol: "ZIL",
        },
      polygon: {
        chain: "polygon",
        name: "POL",
        wagmiChain: configureCustomRpcUrl(
          polygon,
            `${import.meta.env.VITE_POL_MAINNET_API}/${import.meta.env.VITE_POL_MAINNET_KEY}`,
          ),
        chainGatewayAddress: "0x796d796F28b3dB5287e560dDf75BC9B00F0CD609",
        chainId: 137,
        isZilliqa: false,
        blockExplorer: "https://polygonscan.com/tx/",
        nativeTokenSymbol: "POL",
        tokens: [
    {
      name: "ZIL",
      address: "0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17",
      blockExplorer: "https://polygonscan.com/token/0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17",
      logo: test_hrse_token, 
      tokenManagerAddress: "0x3faC7cb5b45A3B59d76b6926bc704Cf3cc522437",
      tokenManagerType: TokenManagerType.ZilBridge,
      bridgesTo: [ "zq" ]
    },
    {
        name: "MATIC",
        address: null,
        blockExplorer: "https://polygonscan.com/token/0x0000000000000000000000000000000000000000",
        logo: test_hrse_token,
        tokenManagerAddress : "0x7519550ae8b6f9d32E9c1A939Fb5C186f660BE5b",
      tokenManagerType: TokenManagerType.LockAndRelease,
      bridgesTo: [ "zq" ]
    },
        ]
      },
      arbitrum: {
        chain: "arbitrum",
        name: "ARB",
        wagmiChain: configureCustomRpcUrl(
          arbitrum,
          `${import.meta.env.VITE_ARB_MAINNET_API}/${import.meta.env.VITE_ARB_MAINNET_KEY}`,
        ),
        chainGatewayAddress: "0xA5AD439b10c3d7FBa00492745cA599250aC21619",
        chainId: 42161,
        isZilliqa: false,
        blockExplorer: "https://arbiscan.io/tx/",
        nativeTokenSymbol: "ARB",
        tokens: [
          {
            name: "ZIL",
            address: "0x1816a0f20bc996f643b1af078e8d84a0aabd772a",
            blockExplorer: "https://arbiscan.io/token/0x1816a0f20bc996f643b1af078e8d84a0aabd772a",
            logo: test_hrse_token,
            tokenManagerAddress: "0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "ARB",
            address: null,
            blockExplorer: "https://arbiscan.io/token/0x0000000000000000000000000000000000000000",
            logo: test_hrse_token,
            tokenManagerAddress : "0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
        ]
      },
      ethereum: {
        chain: "ethereum",
        name: "ETH",
        wagmiChain: configureCustomRpcUrl(
          mainnet,
          `${import.meta.env.VITE_ETH_MAINNET_API}/${import.meta.env.VITE_ETH_MAINNET_KEY}`,
        ),
        chainGatewayAddress: "0x49EA20823c953dd00619E2090DFa3965C89269C3",
        chainId: 1,
        isZilliqa: false,
        blockExplorer: "https://etherscan.io/tx/",
        nativeTokenSymbol: "ETH",
        tokens: [
          {
            name: "ZIL",
            address: "0x6EeB539D662bB971a4a01211c67CB7f65B09b802",
            blockExplorer:
            "https://etherscan.io/token/0x6EeB539D662bB971a4a01211c67CB7f65B09b802",
            logo: seed_token,
            tokenManagerAddress: "0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "LUNR",
            address: "0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A",
            blockExplorer:
            "https://etherscan.io/token/0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A",
            logo: seed_token,
            tokenManagerAddress: "0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "dXCAD",
            address: "0xBd636FFfbF349A4479db315c585E823164cF58F0",
            blockExplorer:
            "https://etherscan.io/token/0xBd636FFfbF349A4479db315c585E823164cF58F0",
            logo: seed_token,
            tokenManagerAddress: "0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "PORT",
            address: "0x0c7c5b92893A522952EB4c939aA24B65FF910C48",
            blockExplorer:
            "https://etherscan.io/token/0x0c7c5b92893A522952EB4c939aA24B65FF910C48",
            logo: seed_token,
            tokenManagerAddress: "0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "FEES",
            address: "0xf7030C3f43b85874ae12B57F44cd682196568b47",
            blockExplorer:
            "https://etherscan.io/token/0xf7030C3f43b85874ae12B57F44cd682196568b47",
            logo: seed_token,
            tokenManagerAddress: "0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695",
            tokenManagerType: TokenManagerType.ZilBridge,
            bridgesTo: [ "zq" ]
          },
          {
            name: "XCAD",
            address: "0x7659CE147D0e714454073a5dd7003544234b6Aa0",
            blockExplorer:
            "https://etherscan.io/token/0x7659CE147D0e714454073a5dd7003544234b6Aa0",
            logo: seed_token,
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "OPUL",
            address: "0x80D55c03180349Fff4a229102F62328220A96444",
            blockExplorer:
            "https://etherscan.io/token/0x80D55c03180349Fff4a229102F62328220A96444",
            logo: seed_token,
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "ETH",
            address: null,
            blockExplorer: "https://etherscan.io/token/0x0000000000000000000000000000000000000000",
            logo: seed_token,
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "BRKL",
            address: "0x4674a4F24C5f63D53F22490Fb3A08eAAAD739ff8",
            blockExplorer: "https://etherscan.io/token/0x4674a4F24C5f63D53F22490Fb3A08eAAAD739ff8",
            logo: seed_token,
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "WBTC",
            address: "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
            logo: seed_token,
            blockExplorer: "https://etherscan.io/token/0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599",
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "USDT",
            address: "0xdAC17F958D2ee523a2206206994597C13D831ec7",
            logo: seed_token,
            blockExplorer: "https://etherscan.io/token/0xdAC17F958D2ee523a2206206994597C13D831ec7",
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
          {
            name: "TRAXX",
            address: "0xD43Be54C1aedf7Ee4099104f2DaE4eA88B18A249",
            logo: seed_token,
            blockExplorer: "https://etherscan.io/token/0xD43Be54C1aedf7Ee4099104f2DaE4eA88B18A249",
            tokenManagerAddress: "0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5",
            tokenManagerType: TokenManagerType.LockAndRelease,
            bridgesTo: [ "zq" ]
          },
        ],
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
              bridgesTo: [ "zq" ]
            },
            {
              name: "HRSE",
              address: "0x3BE0E5EDC58bd55AAa381Fa642688ADC289c05a3",
              blockExplorer:
                "https://bscscan.com/address/0x3BE0E5EDC58bd55AAa381Fa642688ADC289c05a3",
              logo: hrse_token,
              tokenManagerAddress: "0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq" ]
            },
            {
              name: "FPS",
              address: "0x351dA1E7500aBA1d168b9435DCE73415718d212F",
              blockExplorer:
                "https://bscscan.com/address/0x351dA1E7500aBA1d168b9435DCE73415718d212F",
              logo: fps_token,
              tokenManagerAddress: "0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq" ]
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
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "TST",
              address: "0x8618d39a8276D931603c6Bc7306af6A53aD2F1F3",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x8618d39a8276D931603c6Bc7306af6A53aD2F1F3",
              logo: fps_token,
              tokenManagerAddress: "0x1509988c41f02014aA59d455c6a0D67b5b50f129",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "TSLM",
              address: "0xE90Dd366D627aCc5feBEC126211191901A69f8a0",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0xE90Dd366D627aCc5feBEC126211191901A69f8a0",
              logo: test_hrse_token,
              tokenManagerAddress: "0x1509988c41f02014aA59d455c6a0D67b5b50f129",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "TST2",
              address: "0x9Be4DCfB335A263c65a8A763d55710718bbdb416",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x9Be4DCfB335A263c65a8A763d55710718bbdb416",
              logo: fps_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "ZBTST",
              address: "0xd3750B930ED52C26584C18B4f5eeAb986D7f3b36",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0xd3750B930ED52C26584C18B4f5eeAb986D7f3b36",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "BNB",
              address: "0x40647A0C0024755Ef48Bc7C26a979ED833Eb6a15",
              blockExplorer:
                "https://otterscan.testnet.zilliqa.com/address/0x40647A0C0024755Ef48Bc7C26a979ED833Eb6a15",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "ZIL",
              address: null,
              blockExplorer: "https://otterscan.testnet.zilliqa.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "bsc-testnet" ]
            },
            {
              name: "SCLD",
              address: "0xd6B5231DC7A5c37461A21A8eB42610e09113aD1a",
              blockExplorer: "https://otterscan.testnet.zilliqa.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x41823941D00f47Ea1a98D75586915BF828F4a038",
              tokenManagerType: TokenManagerType.ZilBridge,
              bridgesTo: [ "bsc-testnet" ]
            }
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
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "TST",
              address: "0x5190e8b4Bbe8C3a732BAdB600b57fD42ACbB9F4B",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x5190e8b4Bbe8C3a732BAdB600b57fD42ACbB9F4B",
              logo: fps_token,
              tokenManagerAddress: "0xA6D73210AF20a59832F264fbD991D2abf28401d0",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "TSLM",
              address: "0x7Cc585de659E8938Aa7d5709BeaF34bD108bdC03",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x7Cc585de659E8938Aa7d5709BeaF34bD108bdC03",
              logo: test_hrse_token,
              tokenManagerAddress: "0xA6D73210AF20a59832F264fbD991D2abf28401d0",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "TST2",
              address: "0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3",
              blockExplorer:
                "https://testnet.bscscan.com/address/0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3",
              logo: fps_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "ZBTST",
              address: "0x201eDd0521cF4B577399F789e22E05405D500163",
              blockExplorer:
                "https://testnet.bscscan.com/address/0x201eDd0521cF4B577399F789e22E05405D500163",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "BNB",
              address: null,
              blockExplorer: "https://testnet.bscscan.com/",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.LockAndRelease,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "ZIL",
              address: "0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41",
              blockExplorer:
                "https://testnet.bscscan.com/address/0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            },
            {
              name: "SCLD",
              address:"0xBA97f1F72b217BdC5684Ec175bE5615C0E50aBda",
              blockExplorer:
              "https://bscscan.com/address/0xBA97f1F72b217BdC5684Ec175bE5615C0E50aBda",
              logo: test_hrse_token,
              tokenManagerAddress: "0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7",
              tokenManagerType: TokenManagerType.MintAndBurn,
              bridgesTo: [ "zq-testnet" ]
            }
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
  bridgesTo: string[];
};

export type SiteConfig = {
  addTokensToMetamask: boolean;
  showAllowance: boolean;
  allowZeroValueTransfers: boolean;
  logTxnHashes: boolean;
  defaultFromNetwork: Chains;
  defaultToNetwork: Chains;
  homeNetwork: Chains;
};

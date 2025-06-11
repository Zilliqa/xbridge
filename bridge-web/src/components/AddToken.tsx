import { TokenConfig } from "../config/config";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import { useAccount } from "wagmi";
import { getConnectorClient } from "@wagmi/core";
import { wagmiConfig } from "../config/wallet";
import { toast } from "react-toastify";
import { FC } from "react";
// import { EIP1193Provider } from "viem"; // No longer needed

interface AddTokenProps {
  info: TokenConfig;
  decimals: number;
  symbol: string;
}

const AddToken: FC<{ info: TokenConfig; decimals: number; symbol: string }> = ({
  info,
  decimals,
  symbol,
}: AddTokenProps) => {
  const { connector, chainId } = useAccount(); // Added chainId

  let addToMetamask = async () => {
    let toastOpts = { autoClose: 5000 };
    if (!connector || !chainId) {
      toast.error("Wallet not connected or chainId is undefined.", toastOpts);
      return;
    }
    try {
      toast.info("Confirm token add in wallet", toastOpts);
      const client = await getConnectorClient(wagmiConfig, { chainId }); // pass chainId
      // Type guard to ensure client is not undefined (though getConnectorClient should throw if connector not found)
      if (!client) {
        toast.error("Could not get wallet client.", toastOpts);
        return;
      }
      // const provider = client.transport?.provider as EIP1193Provider | undefined; // client itself is the provider

      // if (provider && typeof provider.request === 'function') {
      const wasAdded = await client.request({ // Use client.request directly
        method: "wallet_watchAsset",
        params: {
          type: "ERC20",
          options: {
            address: info.address!,
            symbol: symbol,
            decimals: decimals,
            image: info.logo,
          },
        },
      });

      if (wasAdded) {
        toast.success(`Added token ${info.name}`, toastOpts);
      } else {
        toast.error(`Couldn't add token ${info.name}. User may have rejected the request.`, toastOpts);
      }
      // } else {
      //   toast.error("Wallet provider is not available or does not support direct requests.", toastOpts);
      // }
    } catch (e: unknown) {
      console.error("Error watching asset:", e);
      toast.error(`Failed to add token ${info.name}: ${(e as Error)?.message || 'Unknown error'}`, toastOpts);
    }
  };

  var result = <div />;
  if (connector) {
    result = (
      <button
        className="btn join-item"
        onClick={() => {
          addToMetamask();
        }}
      >
        <FontAwesomeIcon icon={faPlus} color="white" className="ml-auto" />{" "}
      </button>
    );
  }

  return result;
};

export default AddToken;

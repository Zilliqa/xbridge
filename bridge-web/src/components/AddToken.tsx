import { TokenConfig } from "../config/config";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import { useAccount } from "wagmi";
import { getConnectorClient } from "@wagmi/core";
import { wagmiConfig } from "../config/wallet";
import { toast } from "react-toastify";
import { FC } from "react";

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
  const { connector, chainId } = useAccount(); 

  const addToMetamask = async () => {
    const toastOpts = { autoClose: 5000 };
    if (!connector || !chainId) {
      toast.error("Wallet not connected or chainId is undefined.", toastOpts);
      return;
    }
    try {
      toast.info("Confirm token add in wallet", toastOpts);
      const client = await getConnectorClient(wagmiConfig, { chainId }); // pass chainId
      if (!client) {
        toast.error("Could not get wallet client.", toastOpts);
        return;
      }
      
      const wasAdded = await client.request({ 
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
    } catch (e: unknown) {
      console.error("Error watching asset:", e);
      toast.error(`Failed to add token ${info.name}: ${(e as Error)?.message || 'Unknown error'}`, toastOpts);
    }
  };

  let result = <div />;
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

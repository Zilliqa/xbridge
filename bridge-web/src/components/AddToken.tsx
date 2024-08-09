import { TokenConfig } from "../config/config";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import { useAccount } from "wagmi";
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
  const { connector } = useAccount();

  let addToMetamask = async () => {
    const provider = connector!.options.getProvider();
    let toastOpts = { autoClose: 5000 };
    try {
      toast.info("Confirm token add in wallet", toastOpts);
      const wasAdded = await provider.request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC20",
          options: {
            address: info.address,
            symbol: symbol,
            decimals: decimals,
            image: info.logo,
          },
        },
      });

      if (wasAdded) {
        toast.success(`Added token ${info.name}`, toastOpts);
      } else {
        toast.error(`Couldn't add token ${info.name}`, toastOpts);
      }
    } catch (e: unknown) {
      toast.error(`Can't add token ${info.name}`, toastOpts);
    }
  };

  var result = <div />;
  if (connector && connector.options.getProvider()) {
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

import { TokenConfig } from "../config/config";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faPlus } from "@fortawesome/free-solid-svg-icons";
import { useAccount } from "wagmi";
import { Id, toast } from "react-toastify";

interface AddTokenProps {
  info: TokenConfig,
  decimals: number,
  symbol: string
};


const AddToken : FC = ({ info, decimals, symbol }: AddTokenProps) =>  {
  const { connector } = useAccount();

  let addToMetamask = async () => {
    const provider = connector.options.getProvider();
    let toastOpts = { autoClose: 5000 };
    try {
      toast.info('Please confirm token add in Metamask', toastOpts);
      const wasAdded = await provider.request({
        method: "wallet_watchAsset",
        params: {
          type: "ERC20",
          options: {
            address: info.address,
            symbol: symbol,
            decimals: decimals,
            image: info.logo
          }
        }
      });

      if (wasAdded) {
        toast.success(`Added token ${info.name} to metamask`, toastOpts);
      } else {
        toast.error(`Couldn't add token ${info.name} to metamask`, toastOpts);
      }
    } catch (e: Exception) {
      toast.error(`Can't add token ${info.name}`, toastOpts);
    }
  };

  var result = <div />;
  if (connector && connector.options.getProvider()) {
    result =  <button className="btn join-item" onClick={() => {
      addToMetamask()}}><FontAwesomeIcon icon={faPlus} color="white" className="ml-auto" /> </button>;
  }

  return (result);
}

export default AddToken;


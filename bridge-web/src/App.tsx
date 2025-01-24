import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import {
  faArrowRight,
  faArrowUpRightFromSquare,
  faChevronDown,
} from "@fortawesome/free-solid-svg-icons";
import { useEffect, useState } from "react";
import {
  Chains,
  TokenConfig,
  ChainConfig,
  chainConfigs,
  siteConfig,
} from "./config/config";
import {
  erc20ABI,
  useAccount,
  useBalance,
  useContractRead,
  useContractWrite,
  useNetwork,
  usePrepareContractWrite,
  usePublicClient,
  useSwitchNetwork,
  useWaitForTransaction,
} from "wagmi";
import {
  getAddress,
  formatEther,
  formatUnits,
  getAbiItem,
  parseUnits,
  zeroAddress,
} from "viem";
import { Id, toast } from "react-toastify";
import { tokenManagerAbi } from "./abi/TokenManager";
import { ZilTokenManagerAbi } from "./abi/ZilTokenManager";
import Navbar from "./components/Navbar";
import useRecipientInput from "./hooks/useRecipientInput";
import RecipientInput from "./components/RecipientInput";
import { chainGatewayAbi } from "./abi/ChainGateway";
import AddToken from "./components/AddToken";

type TxnType = "approve" | "bridge" | "approvalclearance";

function printAddress(token: TokenConfig | null): string {
  return token ? (token.address ?? "0x00000000000000000000") : "(none)";
}

function getTargetToken(toChainConfig: ChainConfig, token: TokenConfig | null) {
  if (!token) {
    return null;
  }
  const val = toChainConfig?.tokens.filter((tok) => tok.name == token.name);
  return val ? val[0] : null;
}

function getAvailableTokens(
  fromChainConfig: ChainConfig,
  toChainConfig: ChainConfig,
) {
  const avail = Array.from(fromChainConfig.tokens)
    .filter((tok) =>
      tok.bridgesTo.find((network) => network == toChainConfig.chain),
    )
    .sort((a, b) => a.name.localeCompare(b.name, "en"));
  //let names = avail.map((x) => (x.name));
  return avail;
}

function App() {
  const { address: account } = useAccount();
  const { switchNetwork } = useSwitchNetwork({
    onError({}) {
      alert("Failed to switch networks");
    },
  });
  const { chain } = useNetwork();

  const [pendingChains, setPendingChains] = useState<[Chains, Chains]>([
    chainConfigs[siteConfig.defaultFromNetwork]!.chain,
    chainConfigs[siteConfig.defaultToNetwork]!.chain,
  ]);

  const [currentChains, setCurrentChains] = useState<[Chains, Chains]>([
    chainConfigs[siteConfig.defaultFromNetwork]!.chain,
    chainConfigs[siteConfig.defaultToNetwork]!.chain,
  ]);
  const [amount, setAmount] = useState<string | undefined>();
  const isAmountNonZero = Number(amount) > 0;
  const [latestTxn, setLatestTxn] = useState<[TxnType, `0x${string}`]>();
  const [loadingId, setLoadingId] = useState<Id>();
  const [token, selectedToken] = useState<TokenConfig>(
    Object.values(chainConfigs)[0].tokens[0],
  );

  const { recipientEth, isAddressValid } = useRecipientInput();

  const fromChainConfig = chainConfigs[currentChains[0]]!;
  const toChainConfig = chainConfigs[currentChains[1]]!;
  const pendingFromChainConfig = chainConfigs[pendingChains[0]]!;
  const pendingToChainConfig = chainConfigs[pendingChains[1]]!;
  // Don't query whilst we're switching chains.
  const pendingChainSwitch = chain?.id != fromChainConfig?.wagmiChain?.id;

  const fromChainClient = usePublicClient({ chainId: fromChainConfig.chainId });
  const toChainClient = usePublicClient({ chainId: toChainConfig.chainId });

  // This fires when we set pendingChainsConfig() to trigger a from network switch.
  useEffect(() => {
    switchNetwork && switchNetwork(pendingFromChainConfig.chainId);
  }, [pendingChains, switchNetwork]);

  // This fires when switchNetwork() has completed and the chain has been changed in the wallet, or
  // when we just change the to network.
  useEffect(() => {
    let goTo = pendingToChainConfig.chain;
    let goFrom = pendingFromChainConfig.chain;
    if (chain !== fromChainConfig.wagmiChain) {
      // Because we can fire this on our own by switching networks in the wallet.
      const newFromChain = Object.values(chainConfigs).find(
        (chainConfig) => chainConfig.chainId == chain?.id,
      );
      if (!newFromChain?.chain) {
        return;
      }
      if (newFromChain.chain != siteConfig.homeNetwork) {
        goTo = siteConfig.homeNetwork;
      } else {
        if (goTo == siteConfig.homeNetwork) {
          if (goFrom != siteConfig.homeNetwork) {
            goTo = goFrom;
          } else {
            let firstNetwork = Object.values(chainConfigs).find(
              (config) => config.chain !== siteConfig.homeNetwork,
            );
            goTo = firstNetwork!.chain;
          }
        }
      }
      goFrom = newFromChain?.chain;
    }
    if (toChainConfig.chain != goTo || fromChainConfig.chain != goFrom) {
      setCurrentChains([goFrom, goTo]);
    }
  }, [chain, pendingToChainConfig]);

  // Fires when currentChains is set - chooses a token.
  useEffect(() => {
    const availableTokens = getAvailableTokens(fromChainConfig, toChainConfig);
    const newToken = availableTokens.find((tok) => tok.name == token.name);
    if (newToken === undefined) {
      selectedToken(availableTokens[0]);
    } else {
      selectedToken(newToken);
    }
  }, [currentChains, toChainConfig.tokens, fromChainConfig.tokens]);

  const { data: contractDecimals } = useContractRead({
    abi: erc20ABI,
    functionName: "decimals",
    address: token.address ?? zeroAddress,
    enabled: !!token.address && !pendingChainSwitch,
  });
  const { data: contractSymbol } = useContractRead({
    abi: erc20ABI,
    functionName: "symbol",
    address: token.address ?? zeroAddress,
    enabled: !!token.address && !pendingChainSwitch,
  });
  const { data: fees } = useContractRead({
    abi: tokenManagerAbi,
    functionName: "getFees",
    address: token.tokenManagerAddress,
    enabled: !!token.tokenManagerAddress && !pendingChainSwitch,
  });
  const { data: paused } = useContractRead({
    abi: tokenManagerAbi,
    functionName: "paused",
    address: token.tokenManagerAddress,
    enabled: !!token.tokenManagerAddress && !pendingChainSwitch,
  });

  const isNative = token.address === null;
  const { data: nativeBalanceData } = useBalance({
    address: account,
    enabled: !!account && !!token.address && !pendingChainSwitch,
    watch: true,
  });

  let { data: contractBalance } = useContractRead({
    abi: erc20ABI,
    functionName: "balanceOf",
    args: account ? [account!] : undefined,
    address: token.address ?? zeroAddress,
    enabled: !!account && !!token.address && !pendingChainSwitch,
    watch: true,
  });

  contractBalance = contractBalance ?? BigInt(0);
  let nativeBalance =
    nativeBalanceData && nativeBalanceData.value
      ? nativeBalanceData.value
      : BigInt(0);
  let nativeDecimals =
    nativeBalanceData && nativeBalanceData.decimals
      ? nativeBalanceData.decimals
      : 0;
  const balance = isNative ? nativeBalance : contractBalance;
  const decimals = isNative ? nativeDecimals : contractDecimals;
  // We always say that native token transfers have enough allowance.
  const { data: allowance } = useContractRead({
    abi: erc20ABI,
    functionName: "allowance",
    address: token.address ?? zeroAddress,
    args: [account!, token.tokenManagerAddress],
    enabled:
      !isNative &&
      !!account &&
      !!token.address &&
      !!token.tokenManagerAddress &&
      !pendingChainSwitch,
    watch: true,
  });
  const hasEnoughAllowance =
    siteConfig.allowZeroValueTransfers ||
    isNative ||
    (decimals && isAmountNonZero
      ? (allowance ?? 0n) >= parseUnits(amount!, decimals)
      : true);

  const hasEnoughBalance =
    siteConfig.allowZeroValueTransfers ||
    (decimals && balance && amount
      ? parseUnits(amount, decimals) <= balance
      : false);

  let transferAmount = fees ?? BigInt(0);
  if (isNative) {
    const toTransfer = amount ? parseUnits(amount, decimals ?? 0) : 0n;
    transferAmount = transferAmount + BigInt(toTransfer);
  }

  let addressForTokenManager = isNative
    ? zeroAddress
    : getAddress(token.address ?? zeroAddress);
  const { config: transferConfig } = usePrepareContractWrite({
    address: token.tokenManagerAddress,
    abi: tokenManagerAbi,
    args: recipientEth && [
      addressForTokenManager,
      BigInt(toChainConfig.chainId),
      recipientEth,
      amount ? parseUnits(amount, decimals ?? 0) : 0n,
    ],
    functionName: "transfer",
    value: transferAmount ?? 0n,
    enabled: !!(
      hasEnoughAllowance &&
      toChainConfig &&
      fromChainConfig &&
      !fromChainConfig.isZilliqa &&
      recipientEth &&
      decimals
    ),
  });

  const { writeAsync: bridge, isLoading: isLoadingBridge } =
    useContractWrite(transferConfig);

  // From Zilliqa Bridging
  const {
    writeAsync: bridgeFromZilliqa,
    isLoading: isLoadingBridgeFromZilliqa,
  } = useContractWrite({
    mode: "prepared",
    request: {
      address: token.tokenManagerAddress,
      abi: ZilTokenManagerAbi,
      args: [
        addressForTokenManager,
        BigInt(toChainConfig.chainId),
        recipientEth!,
        amount ? parseUnits(amount, decimals ?? 0) : 0n,
      ],
      chain: fromChainConfig.wagmiChain,
      account: account!,
      value: transferAmount ?? 0n,
      functionName: "transfer",
      gas: 8_000_000n,
      type: "legacy",
    },
  });

  // Approvals
  const { config: approveZeroConfig } = usePrepareContractWrite({
    address: token.address ?? zeroAddress,
    abi: token.abi ?? erc20ABI,
    args: [token.tokenManagerAddress, 0n],
    functionName: "approve",
    gas: fromChainConfig.isZilliqa ? 400_000n : undefined,
    type: fromChainConfig.isZilliqa ? "legacy" : "eip1559",
    enabled: !hasEnoughAllowance,
  });

  const { writeAsync: approveZero, isLoading: isLoadingApproveZero } =
    useContractWrite(approveZeroConfig);

  const { config: approveConfig } = usePrepareContractWrite({
    address: token.address ?? zeroAddress,
    abi: token.abi ?? erc20ABI,
    args: [
      token.tokenManagerAddress,
      amount ? parseUnits(amount, decimals ?? 0) : 0n,
    ],
    functionName: "approve",
    gas: fromChainConfig.isZilliqa ? 400_000n : undefined,
    type: fromChainConfig.isZilliqa ? "legacy" : "eip1559",
    enabled: !hasEnoughAllowance,
  });

  const { writeAsync: approve, isLoading: isLoadingApprove } =
    useContractWrite(approveConfig);

  // Bit horrid - if approve isn't available, we'll assume we have to clear the old
  // approval first. USDT on ethereum requires this.
  const requiresApprovalClearance =
    approve == undefined && token.needsAllowanceClearing;

  const canBridge =
    (siteConfig.allowZeroValueTransfers || isAmountNonZero) &&
    isAddressValid &&
    hasEnoughAllowance &&
    hasEnoughBalance &&
    !paused &&
    (fromChainConfig.isZilliqa
      ? !isLoadingBridgeFromZilliqa
      : !isLoadingBridge);

  const {
    data: txnReceipt,
    isLoading: isWaitingForTxn,
    error,
    refetch,
  } = useWaitForTransaction({
    hash: latestTxn?.[1],
    enabled: !!latestTxn?.[1],
  });

  useEffect(() => {
    if (error) {
      // Little hack to get Zilliqa to refetch the pending txns
      refetch();
    }
  }, [error, refetch]);

  useEffect(() => {
    if (txnReceipt && loadingId && latestTxn) {
      let description;
      if (latestTxn[0] === "bridge") {
        description = (
          <div>
            Bridge request txn sent. From {fromChainConfig.name} to{" "}
            {toChainConfig.name} {amount} {token.name} tokens. View on{" "}
            <a
              className="link text-ellipsis w-10"
              onClick={() =>
                window.open(
                  `${fromChainConfig.blockExplorer}${txnReceipt.transactionHash}`,
                  "_blank",
                )
              }
            >
              block explorer
            </a>
          </div>
        );
        (async () => {
          const logs = await fromChainClient.getLogs({
            address: fromChainConfig.chainGatewayAddress,
            event: getAbiItem({
              abi: chainGatewayAbi,
              name: "Relayed",
              args: [toChainConfig.chainId],
            }),
            blockHash: txnReceipt.blockHash,
          });
          const nonce = logs.find(
            (log) => log.transactionHash === txnReceipt.transactionHash,
          )?.args.nonce;

          const id = toast.loading(`Bridging to ${toChainConfig.name}...`);

          // TODO: find a way to stop watching once event arrives
          toChainClient.watchContractEvent({
            abi: chainGatewayAbi,
            address: toChainConfig.chainGatewayAddress,
            eventName: "Dispatched",
            args: {
              nonce,
            },
            onLogs: (logs) => {
              toast.update(id, {
                render: (
                  <div>
                    Bridge txn complete, funds arrived on {toChainConfig.name}{" "}
                    chain. View on{" "}
                    <a
                      className="link text-ellipsis w-10"
                      onClick={() =>
                        window.open(
                          `${toChainConfig.blockExplorer}${logs[0].transactionHash}`,
                          "_blank",
                        )
                      }
                    >
                      block explorer
                    </a>
                  </div>
                ),
                type: "success",
                isLoading: false,
              });
            },
          });

          // Double check if it has already been dispatched before event listener catches it
          const blockNumber = await toChainClient.getBlockNumber();
          const dispatched = await toChainClient.getLogs({
            address: toChainConfig.chainGatewayAddress,
            event: getAbiItem({
              abi: chainGatewayAbi,
              name: "Dispatched",
            }),
            args: {
              nonce,
            },
            fromBlock: blockNumber - 50n,
            toBlock: "latest",
          });

          if (dispatched.length > 0) {
            toast.update(id, {
              render: (
                <div>
                  Bridge txn complete, funds arrived at {toChainConfig.name}{" "}
                  chain. View on{" "}
                  <a
                    className="link text-ellipsis w-10"
                    onClick={() =>
                      window.open(
                        `${toChainConfig.blockExplorer}${dispatched[0].transactionHash}`,
                        "_blank",
                      )
                    }
                  >
                    block explorer
                  </a>
                </div>
              ),
              type: "success",
              isLoading: false,
            });
          }
        })();

        setAmount("");
      } else if (latestTxn[0] === "approve") {
        description = (
          <div>
            Approve txn successful. View on{" "}
            <a
              className="link text-ellipsis w-10"
              onClick={() =>
                window.open(
                  `${fromChainConfig.blockExplorer}${txnReceipt.transactionHash}`,
                  "_blank",
                )
              }
            >
              block explorer
            </a>
          </div>
        );
      } else if (latestTxn[0] === "approvalclearance") {
        description = (
          <div>
            Previous approval cleared. Ready for approval. View on{" "}
            <a
              className="link text-ellipsis w-10"
              onClick={() =>
                window.open(
                  `${fromChainConfig.blockExplorer}${txnReceipt.transactionHash}`,
                  "_blank",
                )
              }
            >
              block explorer
            </a>
          </div>
        );
      } else {
        return;
      }
      toast.update(loadingId, {
        render: description,
        type: "success",
        isLoading: false,
      });
      setLoadingId(undefined);
      setLatestTxn(undefined);
    }
  }, [
    isWaitingForTxn,
    txnReceipt,
    loadingId,
    latestTxn,
    fromChainConfig.name,
    fromChainConfig.blockExplorer,
    toChainConfig.name,
    amount,
    token.name,
    fromChainConfig.chainGatewayAddress,
    toChainConfig.chainId,
    toChainConfig.chainGatewayAddress,
    fromChainClient,
    toChainClient,
    toChainConfig.blockExplorer,
  ]);

  useEffect(() => {
    if (!loadingId && isWaitingForTxn && latestTxn) {
      const id = toast.loading("Transaction being processed...");
      setLoadingId(id);
    }
  }, [isWaitingForTxn, latestTxn, loadingId]);

  const showLoadingButton =
    isLoadingBridgeFromZilliqa ||
    isLoadingBridge ||
    isLoadingApprove ||
    isLoadingApproveZero ||
    isWaitingForTxn;

  const selectTokenOnDropdown = (token: TokenConfig) => {
    const elem = document.activeElement;
    if (elem) {
      elem && (elem as any).blur();
    }
    selectedToken(token);
  };

  let addTokenComponent = <div />;
  if (
    !isNative &&
    siteConfig.addTokensToMetamask &&
    decimals &&
    contractSymbol
  ) {
    addTokenComponent = (
      <AddToken info={token} decimals={decimals!} symbol={contractSymbol!} />
    );
  }
  let allowanceDisplay = <span />;
  if (siteConfig.showAllowance) {
    allowanceDisplay = (
      <span>
        {" "}
        Allowance:{" "}
        {allowance !== undefined && decimals
          ? formatUnits(allowance, decimals)
          : null}{" "}
      </span>
    );
  }

  return (
    <>
      <div className="h-screen flex items-center justify-center">
        <Navbar />
        <div className="card min-h-96 bg-neutral shadow-xl">
          <div className="card-body">
            <div className="card-title">
              <p className="text-4xl text-center tracking-wide">BRIDGE</p>
            </div>
            <div className="form-control">
              <div className="label">
                <span>Networks</span>
              </div>
              <div className="join">
                <div className="dropdown w-1/2">
                  <div tabIndex={0} role="button" className="btn w-full">
                    <p className="w-12">{fromChainConfig.name}</p>
                    <FontAwesomeIcon
                      icon={faChevronDown}
                      className="ml-auto"
                      color="white"
                    />
                  </div>
                  <ul
                    tabIndex={0}
                    className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-full"
                  >
                    {Object.values(chainConfigs)
                      .filter(
                        (config) => config.chain !== fromChainConfig.chain,
                      )
                      .map(({ chain, name }) => (
                        <li
                          key={`from${chain}`}
                          onClick={() => {
                            if (fromChainConfig.chain != chain) {
                              // If this chain is the home network
                              let goToChain = toChainConfig.chain;
                              if (chain == siteConfig.homeNetwork) {
                                if (
                                  toChainConfig.chain == siteConfig.homeNetwork
                                ) {
                                  let firstNetwork = Object.values(
                                    chainConfigs,
                                  ).find(
                                    (config) =>
                                      config.chain !== siteConfig.homeNetwork,
                                  );
                                  goToChain = firstNetwork!.chain;
                                } else {
                                  // Ignore
                                }
                              } else {
                                goToChain = siteConfig.homeNetwork;
                              }
                              setPendingChains([chain, goToChain]);
                            }
                            blur();
                          }}
                        >
                          <a>{name}</a>
                        </li>
                      ))}
                  </ul>
                </div>
                <FontAwesomeIcon
                  className="w-1/6 self-center"
                  icon={faArrowRight}
                  color="white"
                />
                <div className="dropdown w-1/2">
                  <div tabIndex={0} role="button" className="btn w-full">
                    <p className="w-12">{toChainConfig.name}</p>
                    <FontAwesomeIcon
                      icon={faChevronDown}
                      color="white"
                      className="ml-auto"
                    />
                  </div>
                  <ul
                    tabIndex={0}
                    className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-full"
                  >
                    {Object.values(chainConfigs)
                      .filter(({ chain }) => chain !== toChainConfig.chain)
                      .map(({ chain, name }) => (
                        <li
                          key={`to${chain}`}
                          onClick={() => {
                            // Sets the to chain.
                            //  - if the new to chain is the home network
                            //     - if the from chain is the home network, set it to the first non-home network.
                            //     - if the from chain is not the home network, ignore.
                            //  - if the new to chain is not the home network
                            //     - set the from chain to the home network.
                            let nextFromChain = fromChainConfig.chain;
                            if (chain === siteConfig.homeNetwork) {
                              if (
                                toChainConfig.chain === siteConfig.homeNetwork
                              ) {
                                // Set the fromChain to the first non-home network, if there is one.
                                let firstNetwork = Object.values(
                                  chainConfigs,
                                ).find(
                                  (config) =>
                                    config.chain !== siteConfig.homeNetwork,
                                );
                                nextFromChain = firstNetwork!.chain;
                              } else {
                                // Flip from and to chains.
                                nextFromChain = toChainConfig.chain;
                              }
                            } else {
                              nextFromChain = siteConfig.homeNetwork;
                            }
                            setPendingChains([nextFromChain, chain]);
                            blur();
                          }}
                        >
                          <a>{name}</a>
                        </li>
                      ))}
                  </ul>
                </div>
              </div>
            </div>

            <RecipientInput />

            <div className="form-control">
              <div className="label">
                <span>Token</span>
                <span className="label-text-alt self-end">
                  Balance:{" "}
                  {balance !== undefined && decimals
                    ? formatUnits(balance, decimals)
                    : null}{" "}
                  {allowanceDisplay}
                </span>
              </div>
              <div className="join">
                <div className="indicator">
                  <div className="join-item">
                    <div className="dropdown ">
                      <button tabIndex={0} role="button" className="btn w-40">
                        {token.logo && (
                          <img
                            src={token.logo}
                            className="h-8"
                            alt="Token Logo"
                          />
                        )}
                        <p>{token.name}</p>

                        <FontAwesomeIcon
                          icon={faChevronDown}
                          color="white"
                          className="ml-auto"
                        />
                      </button>

                      <ul
                        tabIndex={0}
                        className="dropdown-content z-[1] menu p-2 shadow bg-base-100 rounded-box w-52"
                      >
                        {getAvailableTokens(fromChainConfig, toChainConfig)
                          .filter((tok) => tok.name != token.name)
                          .map((tok) => (
                            <li
                              key={tok.address}
                              onClick={() => selectTokenOnDropdown(tok)}
                            >
                              <div className="flex items-center gap-2">
                                {tok.logo && (
                                  <img
                                    src={tok.logo}
                                    className="h-8"
                                    alt="Token Logo"
                                  />
                                )}
                                <p>{tok.name}</p>
                              </div>
                            </li>
                          ))}
                      </ul>
                    </div>
                  </div>

                  <button
                    onClick={() => window.open(token.blockExplorer, "_blank")}
                    className="btn join-item"
                  >
                    <FontAwesomeIcon
                      icon={faArrowUpRightFromSquare}
                      color="white"
                      className="ml-auto"
                    />
                  </button>
                  {addTokenComponent}
                </div>
                <input
                  className={`input join-item input-bordered w-full text-right ${
                    !hasEnoughBalance && isAmountNonZero
                      ? "input-error"
                      : !hasEnoughAllowance &&
                        isAmountNonZero &&
                        !!allowance &&
                        "input-warning"
                  }`}
                  placeholder="Amount"
                  type="number"
                  value={amount}
                  onChange={({ target }) => setAmount(target.value)}
                />
              </div>
              {!hasEnoughBalance && isAmountNonZero ? (
                <div className="label align-bottom place-content-end">
                  <span className="label-text-alt text-error">
                    Insufficient balance
                  </span>
                </div>
              ) : (
                !hasEnoughAllowance &&
                isAmountNonZero &&
                !!allowance && (
                  <div className="label align-bottom place-content-end">
                    <span className="label-text-alt text-warning">
                      Insufficient allowance
                    </span>
                  </div>
                )
              )}
            </div>

            {!!token && (
              <div className="flex flex-col gap-1">
                <div className="divider"></div>

                <div className="flex justify-center">
                  <label className="label-text-alt">
                    From{" "}
                    <a
                      className="link text-white no-underline"
                      target="_blank"
                      rel="noopener noreferrer"
                      href={token.blockExplorer}
                    >
                      {printAddress(token)}
                    </a>{" "}
                    on {fromChainConfig.name}
                  </label>
                </div>
                {!!getTargetToken(toChainConfig, token) && (
                  <div className="flex justify-center">
                    <label className="label-text-alt">
                      To{" "}
                      <a
                        className="link text-white no-underline"
                        target="_blank"
                        rel="noopener noreferrer"
                        href={
                          getTargetToken(toChainConfig, token)?.blockExplorer
                        }
                      >
                        {printAddress(getTargetToken(toChainConfig, token))}
                      </a>{" "}
                      on {toChainConfig.name}
                    </label>
                  </div>
                )}
              </div>
            )}

            {!!fees && !!amount && (
              <>
                <div className="divider"></div>
                <div className="flex flex-col gap-1">
                  <div className="flex justify-between">
                    <label className="label-text-alt">Fees:</label>
                    <label className="label-text-alt">
                      {formatEther(fees).toString()}{" "}
                      {fromChainConfig.nativeTokenSymbol}
                    </label>
                  </div>

                  <div className="flex justify-between">
                    <label className="label-text-alt">
                      Recipient Receives:
                    </label>
                    <label className="label-text-alt">
                      {amount} {token.name}
                    </label>
                  </div>

                  <div className="flex justify-between">
                    <label className="label-text-alt">Total:</label>
                    <label className="label-text-alt">
                      {amount} {token.name} + {formatEther(fees).toString()}{" "}
                      {fromChainConfig.nativeTokenSymbol}
                    </label>
                  </div>
                </div>
              </>
            )}
            <div className="card-actions mt-auto pt-4">
              {!hasEnoughAllowance && hasEnoughBalance ? (
                <button
                  className="btn w-5/6 mx-10 btn-outline"
                  disabled={showLoadingButton}
                  onClick={async () => {
                    if (approve) {
                      const tx = await approve();
                      if (siteConfig.logTxnHashes) {
                        console.log(tx.hash);
                      }
                      setLatestTxn(["approve", tx.hash]);
                    } else if (approveZero) {
                      const tx = await approveZero();
                      if (siteConfig.logTxnHashes) {
                        console.log("Approve zero - " + tx.hash);
                      }
                      setLatestTxn(["approvalclearance", tx.hash]);
                    }
                  }}
                >
                  {showLoadingButton ? (
                    <>
                      <span className="loading loading-spinner"></span>
                      Loading
                    </>
                  ) : requiresApprovalClearance ? (
                    "Clear existing approval"
                  ) : (
                    "Approve"
                  )}
                </button>
              ) : (
                <button
                  className="btn w-5/6 mx-10 btn-primary text-primary-content"
                  disabled={!canBridge || showLoadingButton}
                  onClick={async () => {
                    let tx: { hash: `0x${string}` };
                    if (fromChainConfig.isZilliqa && bridgeFromZilliqa) {
                      tx = await bridgeFromZilliqa();
                    } else if (bridge) {
                      tx = await bridge();
                    } else {
                      return;
                    }
                    if (siteConfig.logTxnHashes) {
                      console.log(tx.hash);
                    }
                    setLatestTxn(["bridge", tx.hash]);
                  }}
                >
                  {showLoadingButton ? (
                    <>
                      <span className="loading loading-spinner"></span>
                      Loading
                    </>
                  ) : (
                    "Bridge"
                  )}
                </button>
              )}
            </div>
            {paused && (
              <div role="alert" className="alert alert-warning mt-3">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  className="stroke-current shrink-0 h-6 w-6"
                  fill="none"
                  viewBox="0 0 24 24"
                >
                  <path
                    strokeLinecap="round"
                    strokeLinejoin="round"
                    strokeWidth="2"
                    d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"
                  />
                </svg>
                <span>Warning: bridge is currently under maintenance.</span>
              </div>
            )}
          </div>
        </div>
      </div>
    </>
  );
}

export default App;

export const tokenManagerAbi = [
  {
    type: "function",
    name: "UPGRADE_INTERFACE_VERSION",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "string",
        internalType: "string",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "accept",
    inputs: [
      {
        name: "metadata",
        type: "tuple",
        internalType: "struct CallMetadata",
        components: [
          {
            name: "sourceChainId",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "sender",
            type: "address",
            internalType: "address",
          },
        ],
      },
      {
        name: "_args",
        type: "bytes",
        internalType: "bytes",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "acceptOwnership",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "getFees",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getGateway",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRemoteTokenWithScale",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "",
        type: "tuple",
        internalType: "struct ITokenManagerStructs.RemoteToken",
        components: [
          {
            name: "token",
            type: "address",
            internalType: "address",
          },
          {
            name: "tokenManager",
            type: "address",
            internalType: "address",
          },
          {
            name: "chainId",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
      {
        name: "",
        type: "int8",
        internalType: "int8",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getRemoteTokens",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "",
        type: "tuple",
        internalType: "struct ITokenManagerStructs.RemoteToken",
        components: [
          {
            name: "token",
            type: "address",
            internalType: "address",
          },
          {
            name: "tokenManager",
            type: "address",
            internalType: "address",
          },
          {
            name: "chainId",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "owner",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "pause",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "paused",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "pendingOwner",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "proxiableUUID",
    inputs: [],
    outputs: [
      {
        name: "",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "registerToken",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteToken",
        type: "tuple",
        internalType: "struct ITokenManagerStructs.RemoteToken",
        components: [
          {
            name: "token",
            type: "address",
            internalType: "address",
          },
          {
            name: "tokenManager",
            type: "address",
            internalType: "address",
          },
          {
            name: "chainId",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "registerTokenWithScale",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteToken",
        type: "tuple",
        internalType: "struct ITokenManagerStructs.RemoteToken",
        components: [
          {
            name: "token",
            type: "address",
            internalType: "address",
          },
          {
            name: "tokenManager",
            type: "address",
            internalType: "address",
          },
          {
            name: "chainId",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
      {
        name: "scale",
        type: "int8",
        internalType: "int8",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "removeToken",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "renounceOwnership",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setFees",
    inputs: [
      {
        name: "newFees",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setGateway",
    inputs: [
      {
        name: "_gateway",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "transfer",
    inputs: [
      {
        name: "token",
        type: "address",
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "remoteRecipient",
        type: "address",
        internalType: "address",
      },
      {
        name: "amount",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "transferOwnership",
    inputs: [
      {
        name: "newOwner",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "unpause",
    inputs: [],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "upgradeToAndCall",
    inputs: [
      {
        name: "newImplementation",
        type: "address",
        internalType: "address",
      },
      {
        name: "data",
        type: "bytes",
        internalType: "bytes",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "withdrawFees",
    inputs: [
      {
        name: "to",
        type: "address",
        internalType: "address payable",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "event",
    name: "FeesUpdated",
    inputs: [
      {
        name: "feesBefore",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "feesAfter",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "FeesWithdrawn",
    inputs: [
      {
        name: "amount",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Initialized",
    inputs: [
      {
        name: "version",
        type: "uint64",
        indexed: false,
        internalType: "uint64",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "OwnershipTransferStarted",
    inputs: [
      {
        name: "previousOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "OwnershipTransferred",
    inputs: [
      {
        name: "previousOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "newOwner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Paused",
    inputs: [
      {
        name: "account",
        type: "address",
        indexed: false,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "TokenRegistered",
    inputs: [
      {
        name: "token",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "remoteToken",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "remoteTokenManager",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "TokenRegisteredWithScale",
    inputs: [
      {
        name: "token",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "remoteToken",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "remoteTokenManager",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
      {
        name: "scale",
        type: "int8",
        indexed: false,
        internalType: "int8",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "TokenRemoved",
    inputs: [
      {
        name: "token",
        type: "address",
        indexed: false,
        internalType: "address",
      },
      {
        name: "remoteChainId",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Unpaused",
    inputs: [
      {
        name: "account",
        type: "address",
        indexed: false,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Upgraded",
    inputs: [
      {
        name: "implementation",
        type: "address",
        indexed: true,
        internalType: "address",
      },
    ],
    anonymous: false,
  },
  {
    type: "error",
    name: "AddressEmptyCode",
    inputs: [
      {
        name: "target",
        type: "address",
        internalType: "address",
      },
    ],
  },
  {
    type: "error",
    name: "ERC1967InvalidImplementation",
    inputs: [
      {
        name: "implementation",
        type: "address",
        internalType: "address",
      },
    ],
  },
  {
    type: "error",
    name: "ERC1967NonPayable",
    inputs: [],
  },
  {
    type: "error",
    name: "EnforcedPause",
    inputs: [],
  },
  {
    type: "error",
    name: "ExpectedPause",
    inputs: [],
  },
  {
    type: "error",
    name: "FailedInnerCall",
    inputs: [],
  },
  {
    type: "error",
    name: "InsufficientFees",
    inputs: [
      {
        name: "received",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "expected",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
  {
    type: "error",
    name: "InvalidInitialization",
    inputs: [],
  },
  {
    type: "error",
    name: "InvalidSourceChainId",
    inputs: [],
  },
  {
    type: "error",
    name: "InvalidTokenAmount",
    inputs: [
      {
        name: "sent",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "adjusted",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "reconstructed",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
  {
    type: "error",
    name: "InvalidTokenManager",
    inputs: [],
  },
  {
    type: "error",
    name: "InvalidTokenRouting",
    inputs: [],
  },
  {
    type: "error",
    name: "NotGateway",
    inputs: [],
  },
  {
    type: "error",
    name: "NotInitializing",
    inputs: [],
  },
  {
    type: "error",
    name: "OwnableInvalidOwner",
    inputs: [
      {
        name: "owner",
        type: "address",
        internalType: "address",
      },
    ],
  },
  {
    type: "error",
    name: "OwnableUnauthorizedAccount",
    inputs: [
      {
        name: "account",
        type: "address",
        internalType: "address",
      },
    ],
  },
  {
    type: "error",
    name: "UUPSUnauthorizedCallContext",
    inputs: [],
  },
  {
    type: "error",
    name: "UUPSUnsupportedProxiableUUID",
    inputs: [
      {
        name: "slot",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
  },
] as const;

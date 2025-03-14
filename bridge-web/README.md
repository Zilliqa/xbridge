<!-- trunk-ignore-all(markdownlint/MD029) -->

# Bridge Web

## How to run

```sh
npm install
npm run dev
```

## Running locally

```sh
mitmweb --mode reverse:https://data-seed-prebsc-1-s1.binance.org:8545/ \
  --no-web-open-browser --listen-port 5556 --web-port 5557
export VITE_BSC_TESTNET_API=http://localhost:5556
export VITE_BSC_TESTNET_KEY=
```

This is designed so that if you have a quiknode endpoint, you can set
`VITE_BSC_TESTNET_KEY` to your key.

## Environment variables required

```sh
VITE_BSC_MAINNET_API
VITE_BSC_MAINNET_KEY

VITE_POL_MAINNET_API
VITE_POL_MAINNET_KEY

VITE_ARB_MAINNET_API
VITE_ARB_MAINNET_KEY

VITE_ETH_MAINNET_API
VITE_ETH_MAINNET_KEY
```

## How to modify the encoded configuration

The steps to modify secrets are:

1. Set the variable
2. Decode the secret file

- staging

```sh
openssl aes-256-cbc -pbkdf2 -k "${ENV_FILES_DECRYPTER_NONPRD}" -in "./infra/environment/staging/.env.enc" -out "./infra/environment/staging/.env" -d
```

- production

```sh
openssl aes-256-cbc -pbkdf2 -k "${ENV_FILES_DECRYPTER_PRD}" -in "./infra/environment/production/.env.enc" -out "./infra/environment/production/.env" -d
```

3. Modify the decoded env file

```sh
openssl aes-256-cbc -pbkdf2 -k "${ENV_FILES_DECRYPTER_NONPRD}" -in "./infra/environment/staging/.env" -out "./infra/environment/staging/.env.enc"
```

- production

```sh
openssl aes-256-cbc -pbkdf2 -k "${ENV_FILES_DECRYPTER_PRD}" -in "./infra/environment/production/.env" -out "./infra/environment/production/.env.enc"
```

4. Encode the file
5. Submit the encoded file to the repo

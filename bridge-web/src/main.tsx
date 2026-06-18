import "@rainbow-me/rainbowkit/styles.css";
import React from "react";
import ReactDOM from "react-dom/client";
import App from "./App.tsx";

import "react-toastify/dist/ReactToastify.css";
import "./index.css";

import { RainbowKitProvider, darkTheme } from "@rainbow-me/rainbowkit";
import { WagmiProvider } from "wagmi";
import { wagmiConfig } from "./config/wallet.ts";
import { ToastContainer, Bounce } from "react-toastify";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";

const queryClient = new QueryClient();

ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <WagmiProvider config={wagmiConfig}>
      <QueryClientProvider client={queryClient}>
        <RainbowKitProvider
          theme={darkTheme({
            accentColor: "#4DBBBA",
            accentColorForeground: "white",
          })}
          showRecentTransactions
        >
          <App />
          <ToastContainer
            position="bottom-right"
            autoClose={30000}
            hideProgressBar={false}
            newestOnTop={false}
            closeOnClick={false}
            rtl={false}
            pauseOnFocusLoss
            draggable
            pauseOnHover
            theme="dark"
            transition={Bounce}
          />
        </RainbowKitProvider>
      </QueryClientProvider>
    </WagmiProvider>
  </React.StrictMode>
);


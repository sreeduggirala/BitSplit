import React, { useState } from "react";
import { ConnectButton } from "@rainbow-me/rainbowkit";
import bitcoinLogo from "../assets/bitcoin.png";
import Image from "next/image";

const NavBar = () => {
  const [isOpen, setIsOpen] = useState(false);

  const toggleNavbar = () => {
    setIsOpen(!isOpen);
  };

  return (
    <header className="z-50 w-full bg-blue-900 text-sm py-2 ">
      <nav className=" flex items-center justify-between mx-8">
        <div >
          <a
            className="inline-flex items-center gap-x-2 text-xl font-semibold"
            href="/"
          >
            <Image src={bitcoinLogo} width={70} height={70} alt={"logo"} />
            <h1 className=" text-5xl font-bold text-yellow-300">BitWise</h1>
          </a>
        </div>

        <div className="block md:hidden">
          <button
            onClick={toggleNavbar}
            className="flex items-center px-3 py-2 border-4 rounded-xl text-yellow-300 border-yellow-300 hover:text-white hover:border-white"
          >
            <svg
              className="fill-current h-6 w-6"
              viewBox="0 0 20 20"
              xmlns="http://www.w3.org/2000/svg"
            >
              <title>Menu</title>
              <path
                fillRule="evenodd"
                d="M3 5h14a1 1 0 110 2H3a1 1 0 010-2zm0 5h14a1 1 0 110 2H3a1 1 0 010-2zm0 5h14a1 1 0 110 2H3a1 1 0 010-2z"
              />
            </svg>
          </button>
        </div>

        <div className="hidden md:flex md:flex-row  md:ps-5">
            <ConnectButton chainStatus="icon" />
        </div>
      </nav>
      <div
          className={`${
            isOpen ? "block" : "hidden"
          } md:hidden my-4 flex justify-center `}
        >
            <ConnectButton chainStatus="icon" />
        </div>

    </header>
  );
};

export default NavBar;

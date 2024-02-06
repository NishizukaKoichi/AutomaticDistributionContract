// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicEtherFund {
    // Structure for virtual wallets
    struct VirtualWallet {
        uint creationTime; // Creation time of the wallet
        uint balance; // Balance of the wallet
    }

    // Mapping to manage virtual wallets
    mapping(address => VirtualWallet) public virtualWallets;
    // Array of all virtual wallet addresses
    address[] public virtualWalletAddresses;

    // Funds that have not been distributed
    uint public undistributedFunds = 0;

    // Event declarations
    event FundsDistributed(uint amount, uint walletCount);
    event FundsWithdrawn(address indexed to, uint amount);

    // Function to create a virtual wallet
    function createVirtualWallet() public {
        require(virtualWallets[msg.sender].creationTime == 0, "Wallet already exists.");
        virtualWallets[msg.sender] = VirtualWallet(block.timestamp, 0);
        virtualWalletAddresses.push(msg.sender);
    }

    // Function to receive and distribute funds
    function receiveAndDistributeFunds() public payable {
        require(msg.value > 0, "No funds sent.");
        uint walletCount = virtualWalletAddresses.length;
        require(walletCount > 0, "No virtual wallets available.");

        // Funds available for distribution (newly received funds + undistributed funds)
        uint distributableFunds = msg.value + undistributedFunds;
        uint amountPerWallet = distributableFunds / walletCount;
        uint remainder = distributableFunds % walletCount;

        // Distributing funds to each virtual wallet
        for (uint i = 0; i < walletCount; i++) {
            virtualWallets[virtualWalletAddresses[i]].balance += amountPerWallet;
        }

        // Updating undistributed funds
        undistributedFunds = remainder;

        emit FundsDistributed(msg.value, walletCount);
    }

    // Function for a user to withdraw funds to their personal wallet
    function withdrawFunds(uint _amount, address payable _to) public {
        require(virtualWallets[msg.sender].balance >= _amount, "Insufficient balance.");
        virtualWallets[msg.sender].balance -= _amount;
        _to.transfer(_amount);
        emit FundsWithdrawn(_to, _amount);
    }
}

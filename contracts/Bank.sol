// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "./INativeBank.sol";

contract Bank is INativeBank {
    mapping(address account => uint balance) private balances;
    address owner;

    modifier onlyOwner(address account) {
        if (account != owner) {
            revert onlyOwnerFiled(account);
        }

        owner = account;
        _;
    }

    modifier zeroSenderAddress() {
        if (msg.sender == address(0)) {
            revert zeroAddressError(msg.sender);
        }
        _;
    }

    constructor(address account) {
        if (account == address(0)) {
            revert zeroAddressError(msg.sender);
        }
        owner = account;
    }

    function _deposit(
        address account,
        uint256 amount
    ) private zeroSenderAddress {
        if (msg.value == 0) {
            revert DepositingZeroAmount(account);
        }
        balances[account] += amount;
        emit Deposit(account, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function deposit() external payable zeroSenderAddress {
        _deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external zeroSenderAddress {
        if (amount == 0) {
            revert WithdrawalAmountZero(msg.sender);
        }

        uint senderBalance = balances[msg.sender];

        if (amount > senderBalance) {
            revert WithdrawalAmountExceedsBalance(
                msg.sender,
                amount,
                senderBalance
            );
        }

        balances[msg.sender] = senderBalance - amount;

        (bool success, ) = address(msg.sender).call{value: amount}("");

        if (!success) {
            revert WithdrawTransactionFailed(msg.sender, amount);
        }

        emit Withdrawal(msg.sender, amount);
    }

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }

    fallback() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdrawOwner() external payable onlyOwner(msg.sender) {
        uint ownerBalance = address(this).balance;

        (bool success, ) = address(msg.sender).call{value: ownerBalance}("");

        if (!success) {
            revert WithdrawTransactionFailed(msg.sender, ownerBalance);
        }
    }
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "./INativeBank.sol";

contract Bank is INativeBank {
    mapping(address account => uint balance) private balances;

    modifier zeroSenderAddress() {
        require(msg.sender != address(0), "zero sender address!!!");
        _;
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function deposit() external payable zeroSenderAddress {
        if (msg.value == 0) {
            revert DepositingZeroAmount(msg.sender);
        }
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
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
}

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "./INativeBank.sol";

contract Bank is INativeBank {
    mapping(address account => uint balance) private balances;
    address owner;

    modifier onlyOwner() {
        if (owner != msg.sender) {
            revert onlyOwnerFiled(msg.sender);
        }
        _;
    }

    constructor(address account) {
        if (account == address(0)) {
            revert zeroAddressError(msg.sender);
        }
        owner = account;
    }

    function _deposit(address account, uint256 amount) private {
        if (amount == 0) {
            revert DepositingZeroAmount(account);
        }
        balances[account] += amount;
        emit Deposit(account, amount);
    }

    function balanceOf(address account) external view returns (uint256) {
        return balances[account];
    }

    function deposit() external payable {
        _deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external {
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

    /**
     *
     * @dev владелец контракта может снять любую сумму без ограничений.
     */
    function withdrawOwner(uint256 amount) external onlyOwner {
        uint ownerBalance = address(this).balance;

        if (ownerBalance < amount) {
            revert WithdrawalAmountExceedsBalance(
                msg.sender,
                amount,
                ownerBalance
            );
        }

        (bool success, ) = address(owner).call{value: amount}("");

        if (!success) {
            revert WithdrawTransactionFailed(owner, amount);
        }
    }
}

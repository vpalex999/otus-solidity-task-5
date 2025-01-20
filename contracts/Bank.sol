// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import './INativeBank.sol';

contract Bank is INativeBank {
    mapping (address => uint) private  balances;

    function balanceOf(address account) external view returns(uint256){
        return balances[account];
    }

    function deposit() external payable {
        require(msg.value > 0, "an attemp to depozit a zero amount.");
        balances[msg.sender] += msg.value;
    }

    // function withdraw(uint256 amount) external payable  {
    //     balances[msg.sender] = balances[msg.sender] - amount;
    //     address payable _to = msg.sender

    // }
}
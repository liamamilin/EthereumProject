// 这个项目介绍了智能合约是如何管理资金的

// SPDX-License-Identifier: MIT
pragma solidity >0.8.16;

contract SendWithdrawMoney {
    uint public balanceReceived; // 用于记录合约收到的以太币数量

    // 存款函数，接收以太币
    function deposit() public payable {
        // 将接收到的以太币数量累加到合约的余额中
        balanceReceived += msg.value;
    }

    // 查看合约当前余额的函数
    function getContractBalance() public view returns(uint) {
        return address(this).balance; // 返回合约的当前余额
    }

    // 提取全部余额到调用者的函数
    function withdrawAll() public {
        // 将调用者的地址转换为可支付地址
        address payable to = payable(msg.sender);
        // 将合约的全部余额转账给调用者
        to.transfer(getContractBalance());
    }

    // 将全部余额提取到指定地址的函数
    function withdrawToAddress(address payable to) public {
        // 将合约的全部余额转账给指定的地址
        to.transfer(getContractBalance());
    }
}

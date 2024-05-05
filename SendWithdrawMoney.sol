// 这个项目介绍了智能合约是如何管理资金的

/*
这段 Solidity 代码是一个简单的智能合约，名为 `SendWithdrawMoney`，它提供了一些基本的功能来管理以太币资金。以下是这个智能合约的功能：

1. **存款功能 (`deposit`):**
   - 通过调用 `deposit` 函数并发送以太币，可以将以太币存入合约中。
   - 合约会记录存入的以太币数量。

2. **查询合约余额功能 (`getContractBalance`):**
   - 通过调用 `getContractBalance` 函数，可以查询合约当前的以太币余额。
   - 这个函数是一个视图函数，不会修改合约状态，只是返回当前余额。

3. **提取全部余额功能 (`withdrawAll`):**
   - 通过调用 `withdrawAll` 函数，合约的所有余额将被转账给调用者。
   - 合约会将余额转账给调用者，并将合约余额清零。

4. **提取余额到指定地址功能 (`withdrawToAddress`):**
   - 通过调用 `withdrawToAddress` 函数并传入目标地址，合约的所有余额将被转账给指定的地址。
   - 合约会将余额转账给指定地址，并将合约余额清零。

这个智能合约允许用户存款以太币，并提供了两种方式来提取存款：一种是提取全部余额到调用者的地址，另一种是提取全部余额到指定的地址。
*/

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

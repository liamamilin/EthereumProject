// 智能钱包

/*
这个 Solidity 智能合约名为 `SampleWallet`，它提供了一些功能来管理以太币和交易的授权。以下是这个智能合约的功能：

1. **合约拥有者和守护者：**
   - 合约包含一个拥有者（owner）变量，该变量标识了合约的拥有者。
   - 合约还记录了哪些地址是合约的守护者（guardian）。
   - 守护者可以被用于确认设定新的合约拥有者的提议。

2. **转账额度和交易授权：**
   - 合约中有一个 `allowance` 映射，记录了每个地址的转账额度。
   - 合约中有一个 `isAllowedToSend` 映射，记录了哪些地址被允许发送交易。
   - 合约提供了设置地址转账额度的功能 `setAllowance`，只有合约拥有者可以调用，调用者可以设置特定地址的转账额度并标记为允许发送交易。
   - 合约提供了拒绝某个地址发送交易的功能 `denySending`，只有合约拥有者可以调用，调用者可以将特定地址标记为不允许发送交易。

3. **转账功能：**
   - 合约提供了 `transfer` 函数，用于发起转账交易。
   - 调用 `transfer` 函数时，检查转账金额是否超过合约的余额，以及调用者是否被允许发送交易以及转账额度是否足够。
   - 如果调用者不是合约拥有者，则需要检查调用者是否被允许发送交易，并且转账额度是否足够，如果足够，则减少调用者的转账额度。
   - 最后，调用外部合约的 `payable` 函数进行转账，并检查转账是否成功。

4. **提议新的合约拥有者功能：**
   - 合约提供了 `proposeNewOwner` 函数，用于提议设定新的合约拥有者。
   - 只有守护者可以调用 `proposeNewOwner` 函数。
   - 提议设定新的合约拥有者时，需要多个守护者确认，达到确认次数后，新的合约拥有者将会被设定。

5. **接收以太币的fallback函数：**
   - 合约包含一个 `receive` 函数，用于接收以太币。
   - 这个函数是一个特殊的回退函数，当合约接收到以太币时会自动触发执行。

这个智能合约可以用于创建一个简单的钱包，管理转账额度和交易授权，并且支持多个守护者确认设定新的合约拥有者。
*/
// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

contract SampleWallet {
    // 合约拥有者
    address payable owner;
    
    // 记录每个地址的转账额度
    mapping(address => uint) public allowance;
    // 记录哪些地址被允许发送交易
    mapping(address => bool) public isAllowedToSend;

    // 记录谁是合约的守护者
    mapping(address => bool) public guardian;
    // 下一个拥有者
    address payable nextOwner;
    // 守护者重置次数
    uint guardiansResetCount;
    // 守护者重置所需的确认次数
    uint public constant confirmationsFromGuardiansForReset = 3;

    // 构造函数，设置合约的初始拥有者为部署合约的账户
    constructor() {
        owner = payable(msg.sender);
    }

    // 提议设定新的合约拥有者
    function proposeNewOwner(address payable newOwner) public {
        // 需要调用者是守护者
        require(guardian[msg.sender], "You are no guardian, aborting");
        // 如果新的拥有者和当前拥有者不同，重置守护者确认次数
        if(nextOwner != newOwner) {
            nextOwner = newOwner;
            guardiansResetCount = 0;
        }

        // 增加守护者重置次数
        guardiansResetCount++;

        // 如果守护者确认次数达到要求，更新合约拥有者
        if(guardiansResetCount >= confirmationsFromGuardiansForReset) {
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    // 设置地址的转账额度
    function setAllowance(address _from, uint _amount) public {
        // 需要调用者是合约拥有者
        require(msg.sender == owner, "You are not the owner, aborting!");
        // 设置地址的转账额度并标记为允许发送交易
        allowance[_from] = _amount;
        isAllowedToSend[_from] = true;
    }

    // 拒绝某个地址发送交易
    function denySending(address _from) public {
        // 需要调用者是合约拥有者
        require(msg.sender == owner, "You are not the owner, aborting!");
        // 标记地址为不允许发送交易
        isAllowedToSend[_from] = false;
    }

    // 发起转账交易
    function transfer(address payable _to, uint _amount, bytes memory payload) public returns (bytes memory) {
        // 检查转账金额不能大于合约的余额
        require(_amount <= address(this).balance, "Can't send more than the contract owns, aborting.");
        // 如果调用者不是合约拥有者，检查是否被允许发送交易以及转账额度是否足够
        if(msg.sender != owner) {
            require(isAllowedToSend[msg.sender], "You are not allowed to send any transactions, aborting");
            require(allowance[msg.sender] >= _amount, "You are trying to send more than you are allowed to, aborting");
            allowance[msg.sender] -= _amount;
        }

        // 调用外部合约的payable函数进行转账
        (bool success, bytes memory returnData) = _to.call{value: _amount}(payload);
        // 检查转账是否成功
        require(success, "Transaction failed, aborting");
        return returnData;
    }

    // 接收以太币的fallback函数
    receive() external payable {}
}

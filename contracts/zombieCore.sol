pragma solidity ^0.5.12;

import "./zombieMarket.sol";
import "./zombieFeeding.sol";
import "./zombieAttack.sol";
//僵尸核心
contract ZombieCore is ZombieMarket,ZombieFeeding,ZombieAttack {
    //代币名称
    string public constant name = "MyCryptoZombie";
    //代币别名
    string public constant symbol = "MCZ";
    //空函数
    function() external payable {
    }
    //提款函数
    function withdraw() external onlyOwner {
        //合约拥有者   向当前合约地址转账
        owner.transfer(address(this).balance);
    }
    //查询余额
    function checkBalance() external view onlyOwner returns(uint) {
        //当前合约的余额
        return address(this).balance;
    }

}
pragma solidity ^0.5.12;

import "./zombieFactory.sol";
//僵尸助手
contract ZombieHelper is ZombieFactory {
  //升级的费用
  uint public levelUpFee = 0.001 ether;
  //确定某个等级        //等级          僵尸ID
  modifier aboveLevel(uint _level, uint _zombieId) {
    //当前僵尸的id的等级   >=   传进来的等级
    require(zombies[_zombieId].level >= _level,'Level is not sufficient');
    _;
  }
  //只能持有者
  modifier onlyOwnerOf(uint _zombieId) {
    //当前合约调用者 == 拥有者地址[id]   否则报错
    require(msg.sender == zombieToOwner[_zombieId],'Zombie is not yours');
    _;
  }
  //设置升级费
  function setLevelUpFee(uint _fee) external onlyOwner {
    //升级的费用 = 传进来的
    levelUpFee = _fee;
  }
  //升级等级
  function levelUp(uint _zombieId) external payable onlyOwnerOf(_zombieId){
    //当前调用者的钱 ==  0.001 ether 给多了笑纳了否则报错
    require(msg.value == levelUpFee,'No enough money');
    //当前的僵尸Id 等级+1
    zombies[_zombieId].level++;
  }
  //改名函数
  function changeName(uint _zombieId, string calldata _newName) external  aboveLevel(2, _zombieId) onlyOwnerOf(_zombieId) {
    // 当前僵尸的id的名字 = 传进来名字
    zombies[_zombieId].name = _newName;
  }
  //获取发送者的所有僵尸
  function getZombiesByOwner(address  _owner) external view returns(uint[] memory) {
    //创建结果数组，长度为拥有者的僵尸数量    僵尸数量[地址]
    uint[] memory result = new uint[](ownerZombieCount[_owner]);
    //计数
    uint counter = 0;
    //循环遍历所有僵尸    构造体的长度 
    for (uint i = 0; i < zombies.length; i++) {
      //如果僵尸是发送者的，加入结果数组
      //僵尸数量中的地址 == 当前传进来的地址
      if (zombieToOwner[i] == _owner) {
        //数组中的i = 僵尸id
        result[counter] = i;
        //计数++
        counter++;
      }
    }
    //返回当前地址的僵尸id
    return result;
  }
  //触发冷却
  function _triggerCooldown(Zombie storage _zombie) internal {
    //僵尸的升级次数 =    当前时间戳 + 冷却1天  - 当前时间戳 + 冷却1天 % 1天
    _zombie.readyTime = uint32(now + cooldownTime) - uint32((now + cooldownTime) % 1 days);
  }
   //验证冷却函数
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    //返回升级次数 <= 当前时间戳
    return (_zombie.readyTime <= now);
  }
  //合体函数
  function multiply(uint _zombieId, uint _targetDna) internal onlyOwnerOf(_zombieId) {
    //                当前的id        构造体[id]
    Zombie storage myZombie = zombies[_zombieId];

    require(_isReady(myZombie),'Zombie is not ready');
    _targetDna = _targetDna % dnaModulus;
    //newDna  = （当前僵尸的ID  + 基因单位）  /2
    uint newDna = (myZombie.dna + _targetDna) / 2;
    //新建僵尸的dna - 新建僵尸的dna % 10 + 9
    newDna = newDna - newDna % 10 + 9;
    //触发创建僵尸
    _createZombie("NoName", newDna);
    //触发冷却
    _triggerCooldown(myZombie);
  }


}
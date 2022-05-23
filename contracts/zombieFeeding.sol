pragma solidity ^0.5.12;


import "./zombieHelper.sol";
//僵尸喂食
contract ZombieFeeding is ZombieHelper {

  function feed(uint _zombieId) public onlyOwnerOf(_zombieId){
    // 创建我的僵尸构造体
    Zombie storage myZombie = zombies[_zombieId];
    //验证冷却时间
    require(_isReady(myZombie));
    //僵尸喂食次数加1
    zombieFeedTimes[_zombieId] = zombieFeedTimes[_zombieId].add(1);
    //触发冷却
    _triggerCooldown(myZombie);
    //如果喂食次数是10
    if(zombieFeedTimes[_zombieId] % 10 == 0){
        //新dna 为原僵尸的dna未尾1位数为8
        uint newDna = myZombie.dna - myZombie.dna % 10 + 8;
        //创建新僵尸名为僵尸的儿子
        _createZombie("zombie's son", newDna);
    }
  }
}
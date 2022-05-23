pragma solidity ^0.5.12;

import "./zombieHelper.sol";
//僵尸攻击
contract ZombieAttack is ZombieHelper{
    //随机数种子 = 0
    uint randNonce = 0;
    //胜率为 70
    uint public attackVictoryProbability = 70;
    //随机数函数
    function randMod(uint _modulus) internal returns(uint){
        //随机数种子+1
        randNonce++;
        //根据随机数种子和位数创建随机数
        return uint(keccak256(abi.encodePacked(now,msg.sender,randNonce))) % _modulus;
    }
    //设置胜率
    function setAttackVictoryProbability(uint _attackVictoryProbability)public onlyOwner{
        attackVictoryProbability = _attackVictoryProbability;
    }
    //攻击
    function attack(uint _zombieId,uint _targetId)external onlyOwnerOf(_zombieId) returns(uint){
        require(msg.sender != zombieToOwner[_targetId],'The target zombie is yours!');
        //创建我的僵尸结构体
        Zombie storage myZombie = zombies[_zombieId];
        require(_isReady(myZombie),'Your zombie is not ready!');
        //创建敌人僵尸的结构体
        Zombie storage enemyZombie = zombies[_targetId];
       //如果100以内的随机数
        uint rand = randMod(100);
        //如果随机数 >= 胜率
        if(rand>=attackVictoryProbability){
            //我的等级次数 +1
            myZombie.winCount++;
            //我的的胜利+1
            myZombie.level++;
            //敌人失败 +1
            enemyZombie.lossCount++;
            //我的僵尸dna和敌人的dna合成新僵尸
            multiply(_zombieId,enemyZombie.dna);
            //返回当前我的僵尸id
            return _zombieId;
        }else{
            //我的失败 +1
            myZombie.lossCount++;
            //敌人等级次数 +1
            enemyZombie.winCount++;
            //触发冷却
            _triggerCooldown(myZombie);
            //返回 敌人僵尸的id
            return _targetId;
        }
    }
    
}
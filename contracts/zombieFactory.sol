pragma solidity ^0.5.12;

import "./ownable.sol";
import "./safemath.sol";
//僵尸工厂
contract ZombieFactory is Ownable {
  //防止益处
  using SafeMath for uint256;
  //事件 新僵尸生成
  event NewZombie(uint zombieId, string name, uint dna);
  //基因位数
  uint dnaDigits = 16;
  //基因单位
  uint dnaModulus = 10 ** dnaDigits;
  //冷却时间 1天
  uint public cooldownTime = 1 days;
  //僵尸价格 0.01 ETH
  uint public zombiePrice = 0.01 ether;
  //僵尸总数
  uint public zombieCount = 0;
  //僵尸结构体
  struct Zombie {
    string name; //名字
    uint dna;//基因
    uint16 winCount; //等级
    uint16 lossCount;//失败次数
    uint32 level;//胜利次数
    uint32 readyTime;//升级次数
  }
  //构造体
  Zombie[] public zombies;
  //僵尸id  => 拥有者
  mapping (uint => address) public zombieToOwner;
  //拥有者 => 僵尸数量
  mapping (address => uint) ownerZombieCount;
  //僵尸Id  =>喂食次数
  mapping (uint => uint) public zombieFeedTimes;
  //创建僵尸
  function _createZombie(string memory _name, uint _dna) internal {
    //验证发送者僵尸数为0
    uint id = zombies.push(Zombie(_name, _dna, 0, 0, 1, 0)) - 1;
    //拥有者的id = 当前调用者地址
    zombieToOwner[id] = msg.sender;
    //拥有者的僵尸数量 = 拥有者的僵尸数量 +1
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
     //僵尸总数 = 僵尸总数 +1
    zombieCount = zombieCount.add(1);
    //触发事件 新僵尸生成
    emit NewZombie(id, _name, _dna);
  }
  //随机数基因
  function _generateRandomDna(string memory _str) private view returns (uint) {
    //           ⽣成伪随机数  计算参数的紧密打包编码  now返回时间戳   % 基因单位
    return uint(keccak256(abi.encodePacked(_str,now))) % dnaModulus;
  }
  //创建僵尸函数
  function createZombie(string memory _name) public{
    //判断僵尸数量是否 = 0
    require(ownerZombieCount[msg.sender] == 0);
    // 返回随机数基因
    uint randDna = _generateRandomDna(_name);
    //    随机数基因 - 返回的随机数基因 % 10
    randDna = randDna - randDna % 10;
    //触发创建僵尸函数
    _createZombie(_name, randDna);
  }
  //购买僵尸函数
  function buyZombie(string memory _name) public payable{
    //拥有僵尸 > 0
    require(ownerZombieCount[msg.sender] > 0);
    //当前调用者的钱 是否大于 僵尸价格 0.01 ETH
    require(msg.value >= zombiePrice);
     // 返回随机数基因
    uint randDna = _generateRandomDna(_name);
    //随机数基因 - 返回的随机数基因 % 10 + 1
    randDna = randDna - randDna % 10 + 1;
    //触发  创建僵尸
    _createZombie(_name, randDna);
  }
  //设置僵尸价格
  function setZombiePrice(uint _price) external onlyOwner {
    //僵尸价格 = 传进来的数
    zombiePrice = _price;
  }

}
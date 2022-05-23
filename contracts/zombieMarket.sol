pragma solidity ^0.5.12;

import "./zombieOwnership.sol";
//僵尸市场
contract ZombieMarket is ZombieOwnership {
    //僵尸出售结构体
    struct zombieSales{
        //出价者
        address payable seller;
        //价格
        uint price;
    }
    //僵尸id => 僵尸出售结构体
    mapping(uint=>zombieSales) public zombieShop;
    //商店僵尸
    uint shopZombieCount;
    //税 = 1 finney
    uint public tax = 1 finney;
    //最低出价 1 finney
    uint public minPrice = 1 finney;
    //僵尸出售                          僵尸id          价钱
    event SaleZombie(uint indexed zombieId,address indexed seller);
    //僵尸购买                            僵尸id   当前购买者的地址            价钱
    event BuyShopZombie(uint indexed zombieId,address indexed buyer,address indexed seller);
    //出售我的僵尸                              出售的价钱
    function saleMyZombie(uint _zombieId,uint _price)public onlyOwnerOf(_zombieId){
        //出售的价钱  >=  2 finney
        require(_price >= minPrice + tax,'Your price must > minPrice+tax');
        //僵尸出售结构体[id] = 僵尸出售结构体中的[当前调用者地址][价钱]
        zombieShop[_zombieId] = zombieSales(msg.sender,_price);
        //商店僵尸计数  +1
        shopZombieCount = shopZombieCount.add(1);
        //触发僵尸出售
        emit SaleZombie(_zombieId,msg.sender);
    }
    //购买僵尸
    function buyShopZombie(uint _zombieId)public payable{
        //当前调用者的钱 > 购买僵尸的出价
        require(msg.value >= zombieShop[_zombieId].price,'No enough money');
        //交易内置函数
        _transfer(zombieShop[_zombieId].seller,msg.sender, _zombieId);
        //收取税                
        zombieShop[_zombieId].seller.transfer(msg.value - tax);
        //删除僵尸id出售
        delete zombieShop[_zombieId];
        //商店僵尸计数   - 1
        shopZombieCount = shopZombieCount.sub(1);
        //触发购买事件            
        emit BuyShopZombie(_zombieId,msg.sender,zombieShop[_zombieId].seller);
    }
    //收到商店僵尸
    function getShopZombies() external view returns(uint[] memory) {
        //商店僵尸计数
        uint[] memory result = new uint[](shopZombieCount);
        //计数
        uint counter = 0;
        for (uint i = 0; i < zombies.length; i++) {
            //僵尸出售结构体[i].价钱 != 0
            if (zombieShop[i].price != 0) {
                //商店僵尸计数 = i
                result[counter] = i;
                //计数
                counter++;
            }
        }
        //返回商店僵尸计数
        return result;
    }
     //设置税金
    function setTax(uint _value)public onlyOwner{
        tax = _value;
    }
    //设置最低售价
    function setMinPrice(uint _value)public onlyOwner{
        minPrice = _value;
    }
}
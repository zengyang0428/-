pragma solidity ^0.5.12;

import "./zombieHelper.sol";
import "./erc721.sol";
//僵尸所有权
contract ZombieOwnership is ZombieHelper, ERC721 {
  //批准映射僵尸id  =>拥有者
  mapping (uint => address) zombieApprovals;
  //余额函数
  function balanceOf(address _owner) public view returns (uint256 _balance) {
    //查询僵尸的地址 对应的数量
    return ownerZombieCount[_owner];
  }
  //查询所有者
  function ownerOf(uint256 _tokenId) public view returns (address _owner) {
    //查询僵尸的id 对应的地址
    return zombieToOwner[_tokenId];
  }
  //交易内置函数
  function _transfer(address _from, address _to, uint256 _tokenId) internal {
    //接收者僵尸数量+1
    ownerZombieCount[_to] = ownerZombieCount[_to].add(1);
     //接收者僵尸数量-1
    ownerZombieCount[_from] = ownerZombieCount[_from].sub(1);
    //修改僵尸所有者的映射位接收者
    zombieToOwner[_tokenId] = _to;
    //触发交易事件
    emit Transfer(_from, _to, _tokenId);
  }
  //交易函数
  function transfer(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    //当前调用者向地址向传入的地址转僵尸的id
    _transfer(msg.sender, _to, _tokenId);
  }
  //批准函数
  function approve(address _to, uint256 _tokenId) public onlyOwnerOf(_tokenId) {
    //拥有者id = 传进来的地址   设置批准映射为接收者
    zombieApprovals[_tokenId] = _to;
    //触发批准事件  
    emit Approval(msg.sender, _to, _tokenId);
  }
  //接受函数
  function takeOwnership(uint256 _tokenId) public {
    //验证批准映射的接收者为消息的发送者
    require(zombieApprovals[_tokenId] == msg.sender);
    //根据id查询到僵尸的所有者
    address owner = ownerOf(_tokenId);
    //调用交易内置函数
    _transfer(owner, msg.sender, _tokenId);
  }
}
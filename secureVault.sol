// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 *  @title Secure Vault
 * @author AmirMahdi Salehyar
 * x.com/0xAudity
 * 
 */
contract SecureVault {

    mapping (address => uint256) private _balances;

    uint256 private _totalUserBalance;

    address public immutable owner;

    uint256 private _unlocked = 1;
    modifier nonReentrant() {
        require(_unlocked == 1, "ReentrancyGuard: reentrant call");
        _unlocked = 0;
        _;
        _unlocked = 1;
    }

    event Deposit(address indexed user, uint256 amount);

    event Withdraw(address indexed user, uint256 amount);

    event ownerWithdraw(uint256 amount);

    constructor() {
        owner = msg.sender;
    }
    function balanceOf(address user) external view  returns (uint256){
        return _balances[user];
 }

    function totalUserBalance() external view returns (uint256){
        return _totalUserBalance;
    }


    function deposit() public payable {

        require(msg.value>0,'It has to be more than zero' );
        _balances[msg.sender]+=msg.value;
        _totalUserBalance+=msg.value;
        emit Deposit(msg.sender ,msg.value);

    }
    receive() external payable {
        deposit();
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(amount>0,'It has to be more than zero' );
        uint256 bal = _balances[msg.sender];
        require(amount <= bal,'It can not be more than what you deposited' );
        _balances[msg.sender]=bal - amount; 
        _totalUserBalance-=amount;
        (bool ok, )=msg.sender.call{value: amount}('');
        require(ok,'transfer failed');
        emit Withdraw(msg.sender, amount);
    }

    function ownerWithdrawExcess() external nonReentrant{
        require(msg.sender==owner,'not owner');
        uint256 contractBal = address(this).balance;
        uint256 liability = _totalUserBalance;
        require(contractBal > liability, "SecureVault: no excess ETH");

        uint256 amount = contractBal - liability;

        (bool ok, ) = owner.call{value: amount}("");
        require(ok, "SecureVault: ETH transfer failed");

        emit ownerWithdraw(amount);
    } 


}

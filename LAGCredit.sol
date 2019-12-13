pragma solidity ^0.4.16;

contract LAGCredit {

    string name = "LAGC";  // 积分名称  LIBRAIRIE AVANT-GARDE CREDIT
    string symbol = "LAG"; // 积分简称
    uint256 totalSupply; // 发行量

    address public bookStore;

    // 地址对应余额
    mapping (address => uint256) public balances; 
    
    // Owner of account approves the transfer of an amount to another account
    mapping(address => mapping (address => uint256)) allowed;

    // 用来通知客户端积分交易发生
    event transferEvent(address from, address to, uint256 value);

    // 查询账户余额
    function balanceOf(address _owner) constant returns (uint256) {
        return balances[_owner];
    }

    // 查询积分发放总额
    function getTotalSupply() constant returns (uint256) {
        return totalSupply;
    }

    // 构造函数，由积分创建者执行：书店
    constructor(uint256 initialSupply, string creditName, string creditSymbol) public {
        bookStore = msg.sender;
        totalSupply = initialSupply; 
        balances[msg.sender] = totalSupply; 
        name = creditName;
        symbol = creditSymbol;
    }

    // 积分的发送函数，内部函数
    function _transfer(address _from, address _to, uint _value) internal {

        require(_to != 0x0); 
        require(balances[_from] >= _value); 
        require(balances[_to] + _value > balances[_to]); //_value不能为负值

        uint previousBalances = balances[_from] + balances[_to]; 

        balances[_from] -= _value; 
        balances[_to] += _value;

        transferEvent(_from, _to, _value);   // 记录转账并通知客户端发生积分交易
        assert(balances[_from] + balances[_to] == previousBalances);  
    }
    
    // 消費獲得积分的函数
    function _expenses(address _customer, uint _amount, uint _rate, bool _first) public {

        require(
            msg.sender == bookStore,
            "Only bookStore can give points to customer."
        );
        require(_customer != 0x0); 
        if(_first)
        {
            require(balances[bookStore] >= _amount / _rate + 100); 
        }
        else
        {
            require(balances[bookStore] >= _amount / _rate); 
        }
        require(_amount > 0);
        require(_rate > 0);

        uint previousBalances = balances[bookStore] + balances[_customer]; 

        if(_first)
        {
            balances[bookStore] -= _amount / _rate + 100; 
            balances[_customer] += _amount / _rate + 100; 
            transferEvent(bookStore, _customer, _amount / _rate + 100);   // 记录并通知客户端发生积分交易
        }
        else
        {
            balances[bookStore] -= _amount / _rate; 
            balances[_customer] += _amount / _rate; 
            transferEvent(bookStore, _customer, _amount / _rate);   // 记录并通知客户端发生积分交易
        }
        

        
        assert(balances[bookStore] + balances[_customer] == previousBalances);  
    }

    // 积分的兌換函数
    function _exchange(address _customer, uint _amount, uint _rate) public returns (uint leftAmount_){

        require(
            msg.sender == bookStore,
            "Only bookStore can exchange points from customer."
        );
        require(_customer != 0x0); 
        require(balances[_customer] > 0); 
        require(_amount > 0);
        require(_rate > 0);

        uint maxExchange = _amount / _rate;
        uint previousBalances = balances[bookStore] + balances[_customer]; 

        if(balances[_customer]>=maxExchange)
        {
            balances[_customer] -= maxExchange;
            balances[bookStore] += maxExchange;
            transferEvent(_customer, bookStore, maxExchange);   // 记录转账并通知客户端发生积分交易
            assert(balances[bookStore] + balances[_customer] == previousBalances); 
            return 0;
        }
        else
        {
            uint preBalance = balances[_customer];
            balances[_customer] = 0;
            balances[bookStore] += preBalance;
            transferEvent(_customer, bookStore, preBalance);   // 记录转账并通知客户端发生积分交易
            assert(balances[bookStore] + balances[_customer] == previousBalances); 
            uint leftAmount = _amount-preBalance*_rate;
            return leftAmount;
        }

        
    }


    // 客户端调用的积分发送函数
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value); 
    }

    
    
}
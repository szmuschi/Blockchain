// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SampleToken {

    uint256 private _totalSupply;

    address saleContract;
    address owner;

    event Transfer(address indexed _from,
                   address indexed _to,
                   uint256 _value);

    event Approval(address indexed _owner,
                   address indexed _spender,
                   uint256 _value);

    mapping (address => uint256) private _balanceOf;
    mapping (address => mapping(address => uint256)) private _allowance;

    constructor (uint256 _initialSupply) {
        owner = msg.sender;
        _balanceOf[msg.sender] = _initialSupply;
        _totalSupply = _initialSupply;
        emit Transfer(address(0), msg.sender, _totalSupply);
    }

    function name() public pure returns (string memory) {
        return string("TOK");
    }

    function symbol() public pure returns (string memory) {
        return string("Sample Token");
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return _balanceOf[_owner];
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowance[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(_balanceOf[msg.sender] >= _value);
        _balanceOf[msg.sender] -= _value;
        _balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        _allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= _balanceOf[_from]);
        require(_value <= _allowance[_from][msg.sender]);

        _balanceOf[_from] -= _value;
        _balanceOf[_to] += _value;
        _allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function save_saleContractAddress(address sale) public {
        require(msg.sender == owner);
        saleContract = sale;
    } 

    function mint(address account) public {
        require(msg.sender == saleContract);
        _totalSupply += 1;
        _balanceOf[account] += 1;
        _allowance[account][msg.sender] += 1;
    }
}

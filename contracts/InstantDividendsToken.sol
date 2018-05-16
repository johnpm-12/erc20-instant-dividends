pragma solidity ^0.4.23;

// fixed supply token with built in dividend and "fee" functions that instantly change everyone's balances
// this is instead of requiring addresses to request owed dividends with a transaction, like most dividends tokens do
// if large dividends are constantly paid out, eventually something will under/overflow and the dividends will break
// this is not realistically a problem unless the supply is initialized close to 2^256 or 0 and dividends are a huge percent of supply
// "fees" will push it back in the opposite direction
// but for a typical supply and dividends paid out/fees deducted regularly, this would probably take many many years to break

import "./Managed.sol";
import "./SafeMath.sol";

contract InstantDividendsToken is Managed {

    using SafeMath for uint256;
    using SafeMath for int256;

    string public name;
    string public symbol;
    uint8 public decimals;

    uint256 private baseSupply;
    mapping (address => uint256) private baseBalanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // dispersing dividends effectively destroys tokens from the dividends bearer and adds the same amount to supply offset
    // fees do the opposite
    // total supply does not change
    // all balances still add up to the same total supply after this (+- minor rounding, which does not aggregate over multiple dispersements, so it doesn't matter)
    int256 private supplyOffset;

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    event Dividends(address indexed _from, uint256 _value);
    event Fee(address indexed _to, uint256 _value);

    constructor(string _name, string _symbol, uint8 _decimals, uint256 _totalSupply) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        baseBalanceOf[msg.sender] = _totalSupply;
        baseSupply = _totalSupply;
    }

    function totalSupply() public view returns (uint256) {
        return fromBase(baseSupply);
    }

    function balanceOf(address _owner) public view returns (uint256) {
        return fromBase(baseBalanceOf[_owner]);
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        uint256 baseValue = toBase(_value);
        baseBalanceOf[msg.sender] = baseBalanceOf[msg.sender].minus(baseValue);
        baseBalanceOf[_to] = baseBalanceOf[_to].plus(baseValue);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        uint256 baseValue = toBase(_value);
        allowance[_from][msg.sender] = allowance[_from][msg.sender].minus(baseValue);
        baseBalanceOf[_from] = baseBalanceOf[_from].minus(baseValue);
        baseBalanceOf[_to] = baseBalanceOf[_to].plus(baseValue);
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function toBase(uint256 _value) private view returns (uint256) {
        return _value.times(baseSupply) / baseSupply.toInt256().plus(supplyOffset).toUint256();
    }

    function fromBase(uint256 _baseValue) private view returns (uint256) {
        return _baseValue.times(baseSupply.toInt256().plus(supplyOffset).toUint256()) / baseSupply;
    }

    function newDividends(uint256 _value) public managerOnly {
        uint256 baseValue = toBase(_value);
        baseBalanceOf[msg.sender] = baseBalanceOf[msg.sender].minus(baseValue);
        baseSupply = baseSupply.minus(baseValue);
        supplyOffset = supplyOffset.plus(baseValue.toInt256());
        emit Dividends(msg.sender, _value);
    }

    // TODO: fix this. it keeps the total supply static but pulls less than the requested fee from all holders
    function newFee(uint256 _value) public managerOnly {
        uint256 baseValue = toBase(_value);
        baseBalanceOf[msg.sender] = baseBalanceOf[msg.sender].plus(baseValue);
        baseSupply = baseSupply.plus(baseValue);
        supplyOffset = supplyOffset.minus(baseValue.toInt256());
        emit Fee(msg.sender, _value);
    }

}

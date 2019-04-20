pragma solidity ^0.4.16;
library SafeMath {
    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a / b;
        return c;
    }

    function sub(uint256 a, uint256 b) internal constant returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Token {
    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    // function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    // function approve(address _spender, uint256 _value) returns (bool success);
    // function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    // event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract Ownable {
    address public owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    function Ownable() {
        owner = msg.sender;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

}

contract Worker is Ownable {
    using SafeMath for uint;

    event EtherTransfer(address _to, uint _amount);
    event TokenTransfer(address _to, uint _amount);
    event NoFounds();

    function Worker() payable {
        require(msg.value > 0);
    }

    function forwardTokens(address tokenContract, address[] _to, uint[] _amount)
    onlyOwner external {
        Token tokenHolder = Token(tokenContract);
        if (_to.length == _amount.length) {
          for (uint i = 0; i < _to.length; i++) {
            if (tokenHolder.balanceOf(this) >= _amount[i]) {
                if (tokenHolder.transfer(_to[i],_amount[i])) {
                    TokenTransfer(_to[i],_amount[i]);
                } else {
                    NoFounds();
                }
            }
          }
        }
    }

    function forwardEthers(address[] _to, uint[] _amount) onlyOwner external {
        if (_to.length == _amount.length) {
            for (uint i = 0; i < _to.length; i++) {
                if (this.balance >= _amount[i]) {
                    _to[i].transfer(_amount[i]);
                    EtherTransfer(_to[i], _amount[i]);
                } else {
                    NoFounds();
                }
            }
        }
    }
}

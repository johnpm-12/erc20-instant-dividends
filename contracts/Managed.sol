pragma solidity ^0.4.23;

// simple managed contract

contract Managed {

    address public manager;
    address public newManager;

    constructor() public {
        manager = msg.sender;
    }

    modifier managerOnly() {
        require(msg.sender == manager, "Managed managerOnly");
        _;
    }

    function transferManager(address _newManager) public managerOnly {
        newManager = _newManager;
    }

    function acceptManager() public {
        require(msg.sender == newManager, "Managed acceptManager");
        manager = newManager;
    }

}

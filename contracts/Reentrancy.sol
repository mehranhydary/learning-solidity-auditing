// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.10;

// Reentrancy is when you have two contracts, A and B,
// Say B calls A and then A is executing, reentrancy is B calling A
// again while A is completing a transaction (e.g. withdrawing before
// balance gets set to 0; see example below)

// Vulnerable EtherStore smart contract
contract EtherStore {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    // Technique 1:
    // To protect from reentrancy, add a variable and a modifier
    // and use this modifier in the
    bool internal locked;
    modifier noReentrant() {
        require(!locked, "No reentrancy");
        locked = true;
        _;
        locked = false;
    }

    // Technique two should be protecting state variables (e.g. move line 36 to be before line 33)

    function withdraw(uint256 _amount) public noReentrant {
        require(balances[msg.sender] >= _amount);
        (bool sent, ) = msg.sender.call{value: _amount}("");
        require(sent, "Failed to send Ether");

        balances[msg.sender] -= _amount;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    EtherStore public etherStore;

    constructor(address _etherStoreAddress) public {
        etherStore = EtherStore(_etherStoreAddress);
    }

    fallback() external payable {
        if (address(etherStore).balance >= 1 ether) {
            etherStore.withdraw(1 ether);
        }
    }

    function attack() external payable {
        require(msg.value >= 1 ether);
        etherStore.deposit{value: 1 ether}();
        etherStore.withdraw(1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

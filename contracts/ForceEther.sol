// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.10;

contract Foo {
    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

// Foo is able to receive ether by using selfdestruct
// selfdestruct deletes contract from the blockchain

contract Bar {
    function kill(address payable _addr) public payable {
        selfdestruct(_addr);
    }
}

// Sophisticated example:

contract EtherGame {
    uint256 public targetAmount = 7 ether;
    address public winner;
    // Cant rely on address(this).balance... so use another state variable
    uint256 public balance;

    function deposit() public payable {
        require(msg.value == 1 ether, "You can only send 1 ether");
        // uint balance = address(this).balance; // bad
        balance += msg.value;
        require(balance <= targetAmount, "Game is over!");

        if (balance == targetAmount) {
            winner = msg.sender;
        }
    }

    function claimReward() public {
        require(msg.sender == winner, "Not winner");
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "Failed to send ether");
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract Attack {
    function attack(address payable _target) public payable {
        selfdestruct(_target);
    }
}

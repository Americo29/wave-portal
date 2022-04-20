//SPDX-License-Identifier: UNLICENSED

/**
This is the version of the Solidity compiler we want our contract to use.
Be sure that the compiler version is the same in hardhat.config.js
 */
pragma solidity ^0.8.0;

/**
Some magic given to us by Hardhat to do some console logs in our contract.
 */
import "hardhat/console.sol";

/**
smart contracts sort of look like a class in other languages
 */
contract WavePortal {
    uint256 totalWaves;

    /*
     * We will be using this below to help generate a random number
     */
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    /*
     * I created a struct here named Wave.
     * A struct is basically a custom datatype where we can customize what we want to hold inside it.
     */
    struct Wave {
        address waver; // the address of the user who waved.
        string message; // the message the user sent.
        uint256 timestamp; // the timestamp when the user waved.
    }

    /*
     * I declare a variable waves that lets me store an array of structs.
     * This is what lets me hold all the waves anyone ever sends to me!
     */
    Wave[] waves;

    /*
     * This is an address => uint mapping, meaning I can associate an address with a number!
     * In this case, I'll be storing the address with the last time the user waved at us.
     */
    mapping(address => uint256) public lastWaveAt;

    constructor() payable {
        console.log("We have been constructed!");
        /*
         * Set the initial seed
         */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    /**
    totalWaves variable that automatically is initialized to 0. 
    But, this variable is special because it's called a "state variable" 
    and it's cool because it's stored permanently in contract storage.

    our functions become available to be called on the blockchain because we used that special public keyword on our function.
     */
    /**
     We also use some magic here with msg.sender. This is the wallet address of the person who called the function. 
     This is awesome! It's like built-in authentication. 
     We know exactly who called the function because in order to even call a smart contract function, 
     you need to be connected with a valid wallet!
      */
    /*
     * You'll notice I changed the wave function a little here as well and
     * now it requires a string called _message. This is the message our user
     * sends us from the frontend!
     */
    function wave(string memory _message) public {
        /*
         * We need to make sure the current timestamp is at least 15-minutes bigger than the last timestamp we stored
         */
        require(
            lastWaveAt[msg.sender] + 30 seconds < block.timestamp,
            "Must wait 30 seconds befores waving again."
        );

        /*
         * Update the current timestamp we have for the user
         */
        lastWaveAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s waved w/ message %s", msg.sender, _message);

        /*
         * This is where I actually store the wave data in the array.
         */
        waves.push(Wave(msg.sender, _message, block.timestamp));

        /*
         * Generate a new seed for the next user that sends a wave
         */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated: %d", seed);

        /*
         * Give a 50% chance that the user wins the prize.
         */
        if (seed <= 50) {
            console.log("%s won!", msg.sender);

            /*
             * The same code we had before to send the prize.
             */
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "trying to withdraw more money than the contract has."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from contract.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        // Optional: Add this line if you want to see the contract print the value!
        // We'll also print it over in run.js as well.
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }
}

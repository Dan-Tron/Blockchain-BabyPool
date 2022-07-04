// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.9.0;

contract BabyPool {
    Player[] public players;

    struct Player {
        uint256 id;
        string your_name;
        uint256 weight_in_grams;
        uint256 height_in_cm;
        string hairColor;
        string eyeColor;
        uint256 date;
    }

    struct Player_Status {
        uint256 id;
        string your_name;
        uint256 weight_in_grams;
        uint256 height_in_cm;
        string hairColor;
        string eyeColor;
        uint256 date;
        bool guessed;
        address payable account;
        uint256 guessTime;
    }

    mapping(address => Player_Status) public playerStatus;
    uint256 public playerCount;

    constructor() public {
        playerCount = 0;
    }

    function Guess(
        string memory Your_name,
        uint256 Weight_in_grams,
        uint256 Height_in_cm,
        string memory Hair_color,
        string memory Eye_color,
        uint256 Date_of_birth
    ) public returns (bool success) {
        require(!playerStatus[msg.sender].guessed, "You already guessed.");

        //   players[playerCount] = Player(playerCount, _name, _weight, _height, _hairColor, _eyeColor, _date);
        Player memory newPlayer;
        newPlayer.your_name = Your_name;
        newPlayer.weight_in_grams = Weight_in_grams;
        newPlayer.height_in_cm = Height_in_cm;
        newPlayer.hairColor = Hair_color;
        newPlayer.eyeColor = Eye_color;
        newPlayer.date = Date_of_birth;
        players.push(newPlayer);

        playerStatus[msg.sender] = Player_Status(
            playerCount,
            Your_name,
            Weight_in_grams,
            Height_in_cm,
            Hair_color,
            Eye_color,
            Date_of_birth,
            true,
            payable(msg.sender),
            block.timestamp
        );

        playerCount++;
        return true;
    }
}

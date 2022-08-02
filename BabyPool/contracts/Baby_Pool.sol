// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <= 0.9.0;


import "@openzeppelin/contracts/utils/Strings.sol";

contract BabyPool {
    
    address private owner;  
    uint private GuessPrice;

    Player[] public players;
    Admin_Details[] private admin;

    struct Player {
        uint id;
        string your_name;
        int weight_in_grams;
        int height_in_cm;
        string hairColor;
        string eyeColor;
        string gender;
        int dateUTC;
        int score;
        address payable account;
        bool guessed;
        uint guessTime;

    }

    mapping (address => Player) private playerStatus;
    uint public playerCount;

    constructor() {
        playerCount = 0;
        owner = msg.sender;
        GuessPrice = 10000000000000000 wei;
    }

    //DateTime Converter Functions
    
    // Calculate year/month/day from the number of days since 1970/01/01 using
    // the date conversion algorithm 
    // from https://ropsten.etherscan.io/address/0x947cc35992e6723de50bf704828a01fd2d5d6641#code
    // and adding the offset 2440588 so that 1970/01/01 is day 0
    function _daysFromDate(int year, int month, int day) internal pure returns (int _days) {
        int OFFSET19700101 = 2440588;
        require(year >= 1970);
        int _year = int(year);
        int _month = int(month);
        int _day = int(day);

        int __days = _day
          - 32075
          + 1461 * (_year + 4800 + (_month - 14) / 12) / 4
          + 367 * (_month - 2 - (_month - 14) / 12 * 12) / 12
          - 3 * ((_year + 4900 + (_month - 14) / 12) / 100) / 4
          - OFFSET19700101;

        _days = int(__days);
    }

    //Year, Month, Day input
    function timestampFromDate(int year, int month, int day) internal pure returns (int timestamp) {
        int SECONDS_PER_DAY = 24 * 60 * 60;
        timestamp = _daysFromDate(year, month, day) * SECONDS_PER_DAY;
    }


    //Player Input Functions
    function Make_Your_Baby_Pool_Guess(string memory Your_Name, int Weight_in_grams, int Height_in_cm, string memory Hair_Color_brown_blonde_red, string memory Eye_Color_brown_blue_grey, string memory Gender_male_female, int Birth_Year_UTC, int Birth_Month_UTC, int Birth_Day_UTC) payable public returns (bool success) {
      require(!playerStatus[msg.sender].guessed, "You already guessed.");
      require(msg.sender != owner, "You are the owner, you cannot guess!");
      require(msg.value == GuessPrice, "Incorrect amount, check the Guess Price");
      int Date_of_birth = timestampFromDate(Birth_Year_UTC, Birth_Month_UTC, Birth_Day_UTC);

      //Player struct variables  
      Player memory newPlayer;
      newPlayer.id = playerCount;
      newPlayer.your_name = Your_Name;
      newPlayer.weight_in_grams = Weight_in_grams;
      newPlayer.height_in_cm = Height_in_cm;
      newPlayer.hairColor = Hair_Color_brown_blonde_red;
      newPlayer.eyeColor = Eye_Color_brown_blue_grey;
      newPlayer.gender = Gender_male_female;
      newPlayer.dateUTC = Date_of_birth;
      newPlayer.account = payable(msg.sender);
      newPlayer.guessed = true;
      newPlayer.guessTime = block.timestamp;
      players.push(newPlayer);
      
      int Score;
      playerStatus[msg.sender] = Player(playerCount, Your_Name, Weight_in_grams, Height_in_cm, Hair_Color_brown_blonde_red, Eye_Color_brown_blue_grey, Gender_male_female, Date_of_birth, Score, payable(msg.sender), true, block.timestamp);
      
      playerCount++;
      return true;
    }

      function viewGuessPrice() external view returns(string memory){
      return string(abi.encodePacked("Price to enter is: ", Strings.toString(GuessPrice), " Wei (divide by 1,000,000,000,000,000,000 to get Eth price)"));
    }

    //Admin Functions

      function onlyAdmin_Set_Guess_Price(uint _valueInWei) public {
        require (msg.sender == owner, "You are not the owner.");
        GuessPrice = (_valueInWei);
    }
    
    //Admin adds actual birth details function
    struct Admin_Details {
        uint id;
        int weight_in_grams;
        int height_in_cm;
        string hairColor;
        string eyeColor;
        string gender;
        int dateUnix;

    }

    function onlyAdmin_Actual_Details(int Weight_in_grams, int Height_in_cm, string memory Hair_Color_brown_blonde_red, string memory Eye_Color_brown_blue_grey, string memory Gender_male_female, int Birth_Year_UTC, int Birth_Month_UTC, int Birth_Day_UTC) public returns (bool success) {
      require(msg.sender == owner, "You are not the Admin!");
      int Date_of_birth = timestampFromDate(Birth_Year_UTC, Birth_Month_UTC, Birth_Day_UTC);

      //Player struct variables  
      Admin_Details memory adminPlayer;
      adminPlayer.weight_in_grams = Weight_in_grams;
      adminPlayer.height_in_cm = Height_in_cm;
      adminPlayer.hairColor = Hair_Color_brown_blonde_red;
      adminPlayer.eyeColor = Eye_Color_brown_blue_grey;
      adminPlayer.gender = Gender_male_female;
      adminPlayer.dateUnix = Date_of_birth;
      admin.push(adminPlayer);

      return true;
    }
    //Calculate most accurate guess function (lowest score wins)
    
    // Weight: 10 points per 100 grams off
    // Height: 20 points per 1 cm off
    // Hair Color: 100 points if off
    // Eye Color: 100 points if off
    // Gender: 200 points if off
    // Date: 20 points per day off
    
    
    event Winner (
      string winner_name,
      int winner_score,
      uint256 winner_amount
    );

    function onlyAdmin_Calculate_Winner() public {
      require(msg.sender == owner, "You are not the Admin!");
      int winner_score = 2**256 / 2 - 1;
      string memory winner_name;
      address payable winner_address = payable(msg.sender);
      uint256 winner_amount;
      for (uint256 i=0; i<players.length; i++)
      {
        int player_score = Calculate_Score(players[i].weight_in_grams, players[i].height_in_cm, players[i].hairColor, players[i].eyeColor, players[i].gender, players[i].dateUTC);
        players[i].score = player_score;        
        string memory player_name = players[i].your_name;
        if(players[i].score < winner_score) {
          winner_score=players[i].score;
          winner_name=player_name;
          winner_address=players[i].account;
          winner_amount=address(this).balance;
        }       
      }
     if (winner_address != 0x0000000000000000000000000000000000000000 && winner_address != owner) {
     emit Winner(winner_name, winner_score, winner_amount);
     winner_address.transfer(address(this).balance);
     }
     else if (winner_address == 0x0000000000000000000000000000000000000000) {require(winner_address!=0x0000000000000000000000000000000000000000, "Winner address is 0x0000000000000000000000000000000000000000, which is invalid");}
     else {require(winner_address!=owner, "Winner is Admin, which is invalid");}
    }

    function onlyAdmin_Delete_Players() public returns(bool success) {
      require(msg.sender == owner, "You are not the Admin!");
      delete playerStatus[players[players.length-1].account];
      for (uint256 i=0; i<players.length; i++)
      {
        delete playerStatus[players[i].account];
        delete players[i];
        players.pop();       
      }
      players.pop();

      playerCount=0;

      return true;
    }

    function abs(int x) private pure returns (int) {
    return x >= 0 ? x : -x;
    }

    function _toLower(string memory str) internal pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);
        for (uint i = 0; i < bStr.length; i++) {
            // Uppercase character...
            if ((uint8(bStr[i]) >= 65) && (uint8(bStr[i]) <= 90)) {
                // So we add 32 to make it lowercase
                bLower[i] = bytes1(uint8(bStr[i]) + 32);
            } else {
                bLower[i] = bStr[i];
            }
        }
        return string(bLower);
    }

    function Calculate_Score(int Weight_in_grams, int Height_in_cm, string memory Hair_Color_brown_blonde_red, string memory Eye_Color_brown_blue_grey, string memory Gender_male_female, int Date_of_birth) private view returns (int) {
      int score_weight = abs(Weight_in_grams - admin[admin.length-1].weight_in_grams)/10*1;
      int score_height = abs(Height_in_cm - admin[admin.length-1].height_in_cm)*20;
      int score_hair_color = keccak256(abi.encodePacked(_toLower(Hair_Color_brown_blonde_red))) != keccak256(abi.encodePacked(_toLower(admin[admin.length-1].hairColor))) ? int(100) : int(0);
      int score_eye_color = keccak256(abi.encodePacked(_toLower(Eye_Color_brown_blue_grey))) != keccak256(abi.encodePacked(_toLower(admin[admin.length-1].eyeColor))) ? int(100) : int(0);
      int score_gender = keccak256(abi.encodePacked(_toLower(Gender_male_female))) != keccak256(abi.encodePacked(_toLower(admin[admin.length-1].gender))) ? int(200) : int(0);
      int score_date = abs(Date_of_birth - admin[admin.length-1].dateUnix)/86400*20;

      int score =  score_weight + score_height + score_hair_color + score_eye_color + score_gender + score_date;
      return score; 
    }

  

}


#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

FIND_USER(){
  FIND_USERNAME=$($PSQL "SELECT username, games_played, best_game FROM players WHERE username = '$1'")

  if [[ -z $FIND_USERNAME ]]
  then
    echo Welcome, $1! It looks like this is your first time here.
  else
    echo $FIND_USERNAME | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
    do
      echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
    done 
  fi
}

ADD_UPDATE_USER(){

  USER=$($PSQL "SELECT player_id, username, games_played, best_game FROM players WHERE username = '$1'")

  if [[ -z $USER ]]
  then
    ADD_NEW_USER=$($PSQL "INSERT INTO players(username,games_played,best_game) VALUES ('$1', 1, $2)")
  else
    echo $USER | while IFS="|" read PLAYER_ID USERNAME GAMES_PLAYED BEST_GAME
    do
      UPDATE_GAMES=$($PSQL "UPDATE players SET games_played + 1 WHERE player_id = $PLAYER_ID")
      if [[ $BEST_GAME -gt $2 ]]
      then
        UPDATE_BEST=$($PSQL "UPDATE players SET best_game = $BEST_GAME WHERE player_id = $PLAYER_ID")
      fi
    done
  fi

}

GUESS_NUMBER() {
  echo Enter your username:
  read USERNAME
  FIND_USER $USERNAME

  RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))
  NUMBER_OF_GUESSES=0

  echo "Guess the secret number between 1 and 1000:"

  while true
  do
    read GUESS

    if [[ ! $GUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
      continue
    fi

    ((NUMBER_OF_GUESSES++))

    if (( GUESS < RANDOM_NUMBER ))
    then
      echo "It's higher than that, guess again:"
    elif (( GUESS > RANDOM_NUMBER ))
    then
      echo "It's lower than that, guess again:"
    else
      ADD_UPDATE_USER $USERNAME $NUMBER_OF_GUESSES
      echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!" 
      break
    fi
  done
}

GUESS_NUMBER
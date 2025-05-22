#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align --tuples-only -c"

echo -e "Enter your username:"
read USERNAME

# Check if user exists
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")

# If user doesn't exist, insert and welcome
if [[ -z $USER_ID ]]; then
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  # Get stats
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT MIN(no_guesses) FROM games WHERE user_id=$USER_ID;")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Generate secret number
NUMBER=$(( RANDOM % 1000 + 1 ))
TRIES=0

echo "Guess the secret number between 1 and 1000:"

while true; do
  read NUMBER_GUESSED
  # MyVersion delete later
  # echo -e "$NUMBER"

  # Check if input is an integer
  if ! [[ $NUMBER_GUESSED =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((TRIES++))

  if [[ $NUMBER_GUESSED -lt $NUMBER ]]; then
    echo "It's higher than that, guess again:"
  elif [[ $NUMBER_GUESSED -gt $NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $NUMBER_GUESSED -eq $NUMBER ]]; then
    echo "You guessed it in $TRIES tries. The secret number was $NUMBER. Nice job!"
    break
  fi
done

# Insert game result
INSERT_GAME=$($PSQL "INSERT INTO games(user_id, no_guesses) VALUES($USER_ID, $TRIES);")

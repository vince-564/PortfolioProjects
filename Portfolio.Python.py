import random
from random import randint

def computer_limit(min_num, max_num):
    return randint(min_num, max_num)

def player_limit(min_num, max_num):
    user_input = int(input(f"Please choose a number between {min_num} and {max_num}: "))
    return user_input

low = 0
high = 10
attempt = 0
attempt_max = 5
message = "You have exceeded that max number of attempts! Please play again!"

print("Hello! Welcome to our number guessing game!")
print("You will have", attempt_max, "attempts to guess the correct number!")
computer_choice = computer_limit(low, high)
player_choice = player_limit(low, high)

while computer_choice != player_choice:
    if computer_choice > player_choice:
        attempt += 1
        attempts_left = attempt_max - attempt
        print(f"Incorrect! Too low. You have", attempts_left,"attempts left. ")
        player_choice = int(input(f"Please guess again! "))
        if int(attempts_left == 1):
            print(message)
            quit()
    elif computer_choice < player_choice:
        attempt += 1
        attempts_left = attempt_max - attempt
        print(f"Incorrect! Too high. You have", attempts_left,"attempts left. ")
        player_choice = int(input(f"Please guess again! "))
        if int(attempts_left == 1):
            print(message)
            quit()
print("Congratulations. You have guessed the correct answer!")

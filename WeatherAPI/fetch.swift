import time
import requests
import RPi.GPIO as GPIO
from bs4 import BeautifulSoup
import hashlib


api_key = 'K0TkPze2GFdijIUp5Fmv98YwdrAE2CPf'


location = '349625'

# Read initial temperature threshold from index.html file
with open('index.html', 'r') as html_file:
    soup = BeautifulSoup(html_file, 'html.parser')
    script_tag = soup.find('script').string
    exec(script_tag)

prev_hash = hashlib.md5(script_tag.encode()).hexdigest()
threshold = int(tempDisplay1)

# create the URL for the API request
url = f'http://dataservice.accuweather.com/currentconditions/v1/{location}?apikey={api_key}'

# set up GPIO pins for motor control
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(17, GPIO.OUT)
GPIO.setup(18, GPIO.OUT)
pwm = GPIO.PWM(17, 100)
pwm.start(0)

# motor direction variables
FORWARD = 1
BACKWARD = -1
motor_direction = FORWARD
direction_changes = 0
total_direction_changes = 0

# create a function to read the temperature from the API and turn the motor
def read_temp_and_turn_motor():
    global motor_direction
    global direction_changes
    global total_direction_changes

    # make the API request
    response = requests.get(url)
    # if the request was successful
    if response.status_code == 200:
        # get the temperature from the response
        weather_info = response.json()[0]
        temperature = weather_info['Temperature']['Imperial']['Value']
        # if the temperature is above the threshold, turn the motor forward
        if temperature > threshold:
            if motor_direction == BACKWARD:
                direction_changes += 1
                total_direction_changes += 1
                motor_direction = FORWARD
            if direction_changes <= 2 and total_direction_changes <= 4:
                pwm.ChangeDutyCycle(100)
                GPIO.output(18, GPIO.HIGH)
        # if the temperature is below the threshold, turn the motor backward
        elif temperature < threshold:
            if motor_direction == FORWARD:
                direction_changes += 1
                total_direction_changes += 1
                motor_direction = BACKWARD
            if direction_changes <= 2 and total_direction_changes <= 4:
                pwm.ChangeDutyCycle(100)
                GPIO.output(18, GPIO.LOW)
        # otherwise, turn the motor off
        else:
            pwm.ChangeDutyCycle(0)
            GPIO.output(18, GPIO.LOW)
    else:
        # if the request was not successful, print an error message
        print('Error:', response.status_code)

# continuously monitor the temperature threshold for changes
while True:
    with open('index.html', 'r') as html_file:
        soup = BeautifulSoup(html_file, 'html.parser')
        script_tag = soup.find('script').string
        curr_hash = hashlib.md5(script_tag.encode()).hexdigest()

        # check if the tempDisplay1 value has changed
        if curr_hash != prev_hash:
            prev_hash = curr_hash
            exec(script_tag)
            threshold = int(tempDisplay1)
            print('Temperature threshold updated:', threshold)
            # reset direction change counters
            direction_changes = 0
            total_direction_changes = 0

    # read the temperature and turn the motor
    read_temp_and_turn_motor()
    time.sleep(5)

import time
import requests
import RPi.GPIO as GPIO

# accuweather api key
api_key = 'K0TkPze2GFdijIUp5Fmv98YwdrAE2CPf'

# allen city code
location = '349625'

# create the URL for the API request
url = f'http://dataservice.accuweather.com/currentconditions/v1/{location}?apikey={api_key}'

# set up GPIO pins for motor control
GPIO.setmode(GPIO.BCM)
GPIO.setwarnings(False)
GPIO.setup(17, GPIO.OUT)
GPIO.setup(18, GPIO.OUT)
pwm = GPIO.PWM(17, 100)
pwm.start(0)

# create a function to read the temperature from the API and turn the motor
def read_temp_and_turn_motor():
    # make the API request
    response = requests.get(url)
    # if the request was successful
    if response.status_code == 200:
        # get the temperature from the response
        weather_info = response.json()[0]
        temperature = weather_info['Temperature']['Imperial']['Value']
        # if the temperature is greater than 105 degrees, turn the motor forward
var counter = 0
        if temperature > 105 && counter > 0:
            pwm.ChangeDutyCycle(100)
            GPIO.output(18, GPIO.HIGH)
counter -= 1
        # if the temperature is less than 65 degrees, turn the motor backward
        elif temperature < 65 && counter == 0:
            pwm.ChangeDutyCycle(100)
            GPIO.output(18, GPIO.LOW)
counter += 1
        # otherwise, turn the motor off
        else:
            pwm.ChangeDutyCycle(0)
            GPIO.output(18, GPIO.LOW)
    else:
        # if the request was not successful, print an error message
        print('Error:', response.status_code)

# repeat the function call every 5 seconds
while True:
    read_temp_and_turn_motor()
    time.sleep(5)

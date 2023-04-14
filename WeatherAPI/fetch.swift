import requests

# replace YOUR_API_KEY with your AccuWeather API key
api_key = 'YOUR_API_KEY'

# replace YOUR_LOCATION with the location you want to get weather information for
location = 'YOUR_LOCATION'

# create the URL for the API request
url = f'http://dataservice.accuweather.com/currentconditions/v1/{location}?apikey={api_key}'

# make the API request
response = requests.get(url)

# if the request was successful
if response.status_code == 200:
    # get the weather information from the response
    weather_info = response.json()
    # print the weather information
    print(weather_info)
else:
    # if the request was not successful, print an error message
    print('Error:', response.status_code)

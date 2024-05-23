from connect_wifi import connect_wifi
from time_fetch import get_current_time
from web_server import start_web_server

# Wi-Fi credentials
wifi_ssid = "yanaezani"
wifi_password = "yana1012"

# Connect to Wi-Fi
wifi = connect_wifi(wifi_ssid, wifi_password)

# Start the web server
start_web_server()

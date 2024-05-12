import network # type: ignore
import socket
import time
from machine import Pin # type: ignore

# Function to connect to WiFi
def connect_to_wifi(ssid, password):
    wlan = network.WLAN(network.STA_IF)  # Initialize WLAN (station mode)
    wlan.active(True)  # Activate the WLAN interface
    
    if not wlan.isconnected():  # Check if not already connected
        print("Connecting to WiFi...")
        wlan.connect(ssid, password)  # Connect to the WiFi network with provided SSID and password
        
        # Wait for connection
        while not wlan.isconnected():
            time.sleep(1)
    
    # Print connection details
    print("Connected to WiFi")
    print("Network config:", wlan.ifconfig())

# Define pin for water pump
pin_water_pump = Pin(8, Pin.OUT)

# Function to start water pump
def start_water_pump():
    pin_water_pump.on()
    print("Water pump started.")

# Function to stop water pump
def stop_water_pump():
    pin_water_pump.off()
    print("Water pump stopped.")

# WiFi credentials
wifi_ssid = "yanaezani"
wifi_password = "yana1012"

# Connect to WiFi
connect_to_wifi(wifi_ssid, wifi_password)

# HTML content for the control panel
html = """<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>
.buttonGreen { background-color: #4CAF50; border: 2px solid #000000; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; }
.buttonRed { background-color: #D11D53; border: 2px solid #000000; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; }
</style>
</head>
<body>
<center>
<h1>Control Panel</h1>
<br>
<form>
<button class="buttonGreen" name="action" value="start" type="submit">Start Water Pump</button>
<button class="buttonRed" name="action" value="stop" type="submit">Stop Water Pump</button>
</form>
</center>
</body>
</html>
"""

# Create socket
addr = socket.getaddrinfo('0.0.0.0', 5000)[0][-1]
s = socket.socket()
s.bind(addr)
s.listen(1)
print('Listening on', addr)

# Main loop
while True:
    try:
        cl, addr = s.accept()
        print('Client connected from', addr)
        request = cl.recv(1024)
        request_str = request.decode('utf-8')
        print("Request:")
        print(request_str)

        # Check if request contains action parameter
        if 'action=start' in request_str:
            start_water_pump()
        elif 'action=stop' in request_str:
            stop_water_pump()

        # Send HTML response
        cl.send('HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'.encode())
        cl.send(html.encode())

        cl.close()

    except Exception as e:
        print('Error:', e)

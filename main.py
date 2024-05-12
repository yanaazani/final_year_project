import network  # type: ignore
import urequests # type: ignore
import time
import socket
import ujson
from machine import Pin, ADC # type: ignore

# Connect to Wi-Fi
wifi_ssid = "yanaezani"
wifi_password = "yana1012"
wifi = network.WLAN(network.STA_IF)
wifi.active(True)
wifi.connect(wifi_ssid, wifi_password)

# Wait until connected to Wi-Fi
while not wifi.isconnected():
    pass

print("Connected to Wi-Fi")

# Function to get current date and time from an external server
def get_current_time():
    try:
        response = urequests.get("http://worldtimeapi.org/api/timezone/Asia/Kuala_Lumpur")
        data = response.json()
        current_time = data["datetime"]
        return current_time
    except Exception as e:
        print("Error getting current time:", e)
        return None

url = "http://172.20.10.3/xampp/save_data.php" # Server URL

# Initialize variables
reading = 0
percent = 0
date = ""

# how frequently to take readings
DELAY = 1.0
# set the analog read pin for the moisture sensor
sensor_signal = ADC(Pin(27))
# set up the buzzer
buzzer = Pin(18, Pin.OUT)
NOTE_C5 = 523
# set up the water pump pin
pin_water_pump = Pin(8, Pin.OUT)
# some variables for internal use
calibrate_count = 0
auto_calibrate = True
SENSOR_MAX = 430
SENSOR_MIN = 352

flow_frequency = 0
flow_rate = 0
last_call_time = 0
total_volume = 0

# Define constants for flow sensor
FLOW_CONVERSION_FACTOR = 7.5  # Liters per pulse

# Water billing rates (RM per cubic meter)
RATE_1 = 0.75
RATE_2 = 1.30
RATE_3 = 1.75
MIN_CHARGE = 7.50

pin = Pin(19, Pin.IN, Pin.PULL_UP)

def callback(pin):
    global flow_frequency, total_volume
    flow_frequency += 1
    total_volume += 1 / FLOW_CONVERSION_FACTOR  # Increment total volume by one pulse equivalent

pin.irq(trigger=Pin.IRQ_RISING, handler=callback)


#Funtion for automatic watering system
def auto_watering_system(): 
        global flow_frequency, last_call_time
        date = get_current_time() # Get current date and time

        # take a reading from the sensor and make it a little easier to read
        value = round(sensor_signal.read_u16() / 100)
        print("reading:", value)

        # crazy math to turn value into percentage
        percent = round(((value - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)) * 100)
        print("Percent:", percent, end=' ')

        if percent >= 70:
            color = (255, 0, 0)  # Red
            print("(DRY)")
            # Activate water pump if soil is dry
            pin_water_pump.on()
            time.sleep(5)  # Run the water pump for 5 seconds
            pin_water_pump.off()

        # change color based on percentage
        if percent >= 70:
            color = (255, 0, 0)  # Red
            print("(DRY)")
        elif percent >= 40:
            color = (0, 255, 0)  # Green
            print("(MOIST)")
        else:
            color = (0, 0, 255)  # Blue
            print("(WET)")

        if ((time.time() * 1000 - last_call_time) > 1000):  # If time interval is more than 1 second
            flow_rate = (flow_frequency * 60 / FLOW_CONVERSION_FACTOR) / 3600  # Flow rate in L/s
            flow_frequency = 0  # Reset Counter
            last_call_time = time.time() * 1000

        if flow_rate == 0:  # Check if flow rate is zero
            print("Flow rate is zero. No data will be sent to the database.")
        else:
            # Convert flow rate to cubic meters per second
            flow_rate_m3_per_s = flow_rate / 1000  # Convert from liters to cubic meters

            # Calculate total volume in cubic meters
            total_volume_m3 = total_volume / 1000  # Convert from liters to cubic meters

            # Calculate the water bill
            def calculate_water_bill(volume_m3):
                if volume_m3 <= 0.01:  # Volume less than or equal to 10 m³
                    return MIN_CHARGE
                elif volume_m3 <= 0.02:  # Volume between 0.01 m³ and 0.02 m³
                    return RATE_1 * volume_m3
                elif volume_m3 <= 0.035:  # Volume between 0.02 m³ and 0.035 m³
                    return RATE_1 * 0.02 + RATE_2 * (volume_m3 - 0.02)
                else:  # Volume greater than 0.035 m³
                    return RATE_1 * 0.02 + RATE_2 * 0.015 + RATE_3 * (volume_m3 - 0.035)

            bill_amount = calculate_water_bill(total_volume_m3)

            print("\n-------------------\n")
            print("Flow Rate = {:.2f} Litres/Second".format(flow_rate))
            print("Total Volume = {:.2f} Cubic Meters".format(total_volume_m3))
            print("Water Bill Amount = RM {:.2f}".format(bill_amount))
            print("\n-------------------\n")

      
        # Prepare data to send
            data = {
                'date': date,
                'reading': value,
                'percent': percent,
                'flow_rate': flow_rate,
                'volume': total_volume_m3,
                'amount': bill_amount
            }

     # Send HTTP POST request to server
        try:
            response = urequests.post(url, json=data)
            print(response.text)
            response.close()
        except Exception as e:
            print("Error sending data:", e)
        # wait for the required delay
        time.sleep(5)

        print("\n-------------------\n")


# HTML content for the control panel
html = """<!DOCTYPE html>
<html>
    <head>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            .buttonGreen { background-color: #4CAF50; border: 2px solid #000000; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; }
            .buttonRed { background-color: #D11D53; border: 2px solid #000000; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; }
            .buttonBlue { background-color: #4A90E2; border: 2px solid #000000; color: white; padding: 15px 32px; text-align: center; text-decoration: none; display: inline-block; font-size: 16px; margin: 4px 2px; cursor: pointer; }
        </style>
    </head>
    <body>
        <center>
            <h1>Control Panel</h1>
            <br>
            <form>
                <button class="buttonGreen" name="action" value="start" type="submit">Start Water Pump</button>
                <button class="buttonRed" name="action" value="stop" type="submit">Stop Water Pump</button>
                <button class="buttonBlue" name="action" value="auto" type="submit">Activate Auto-Watering System</button>
            </form>
        </center>
    </body>
</html>
"""

# Create socket
addr = socket.getaddrinfo('0.0.0.0', 8080)[0][-1]
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
            pin_water_pump.on()
        elif 'action=stop' in request_str:
            pin_water_pump.off()
        elif 'action=auto' in request_str:
            auto_watering_system()


    
    # Send HTML response
        cl.send('HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'.encode())
        cl.send(html.encode())

        cl.close()
    
    except Exception as e:
        print('Error:', e)
        
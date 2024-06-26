import network  # type: ignore
import urequests  # type: ignore
import time
import utime  # type: ignore
import socket
import ujson
from machine import Pin, ADC  # type: ignore

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

# Server URL
url = "http://172.20.10.3/xampp/save_data.php"

# Initialize variables
reading = 0
percent = 0
scheduled_time = None  # Variable to store the scheduled time
scheduled_duration = 5  # Default duration for water pump activation

# How frequently to take readings
DELAY = 1.0
# Set the analog read pin for the moisture sensor
sensor_signal = ADC(Pin(27))
# Set up the water pump pin
pin_water_pump = Pin(8, Pin.OUT)

# Moisture sensor calibration values
SENSOR_MAX = 430
SENSOR_MIN = 352

# Flow sensor variables
flow_frequency = 0
flow_rate = 0
total_milliliters = 0
FLOW_CONVERSION_FACTOR = 4.5  # Calibration factor (pulses per liter)

# Water billing rates (RM per cubic meter)
RATE_1 = 0.87  # 0 to 20 cubic meters
RATE_2 = 1.52  # 20 to 35 cubic meters
RATE_3 = 2.02  # Above 35 cubic meters

flow_sensor = Pin(19, Pin.IN, Pin.PULL_UP)

def flow_callback(pin):
    global flow_frequency
    flow_frequency += 1

flow_sensor.irq(trigger=Pin.IRQ_RISING, handler=flow_callback)

previous_millis = 0
interval = 1000

def calculate_water_bill(volume_m3):
    if volume_m3 <= 20:
        return RATE_1 * volume_m3
    elif volume_m3 <= 35:
        return RATE_1 * 20 + RATE_2 * (volume_m3 - 20)
    else:
        return RATE_1 * 20 + RATE_2 * 15 + RATE_3 * (volume_m3 - 35)

def auto_watering_system():
    global flow_frequency, previous_millis, total_milliliters
    date = get_current_time()  # Get current date and time

    # Take a reading from the sensor and make it easier to read
    value = round(sensor_signal.read_u16() / 100)
    print("Reading:", value)

    # Calculate the percentage
    percent = round(((value - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)) * 100)
    print("Percent:", percent, end=' ')

    if percent >= 70:
        print("(DRY)")
        # Activate water pump if soil is dry
        pin_water_pump.on()
        time.sleep(5)  # Run the water pump for 5 seconds
        pin_water_pump.off()

    # Check time interval for flow rate calculation
    current_millis = utime.ticks_ms()
    if (current_millis - previous_millis) > interval:
        pulse1Sec = flow_frequency
        flow_frequency = 0
        flow_rate = (1000.0 / (current_millis - previous_millis)) * pulse1Sec / FLOW_CONVERSION_FACTOR
        previous_millis = current_millis

        flow_milliliters_per_min = flow_rate * 1000
        total_milliliters += flow_milliliters_per_min * (interval / 60000)

        total_volume_m3 = total_milliliters / 1_000_000
        bill_amount = calculate_water_bill(total_volume_m3)

        print("\n-------------------\n")
        print("Flow Rate = {:.2f} Liters/Minute".format(flow_rate))
        print("Total Volume = {:.2f} Milliliters".format(total_milliliters))
        print("Total Volume = {:.6f} Cubic Meters".format(total_volume_m3))
        print("Water Bill Amount = RM {:.2f}".format(bill_amount))
        print("\n-------------------\n")

        data = {
            'date': date,
            'reading': value,
            'percent': percent,
            'flow_rate': flow_rate,
            'volume': total_volume_m3,
            'amount': bill_amount
        }

        try:
            response = urequests.post(url, json=data)
            print(response.text)
            response.close()
        except Exception as e:
            print("Error sending data:", e)

# Function to set the scheduled time and duration
def set_scheduled_time(hour, minute, period, duration):
    global scheduled_time, scheduled_duration
    if period == "PM" and hour != 12:
        hour += 12
    elif period == "AM" and hour == 12:
        hour = 0
    scheduled_time = (hour, minute)
    scheduled_duration = duration
    print(f"Scheduled time set to {hour:02}:{minute:02} for {duration} seconds")

def check_scheduled_time():
    global scheduled_time, scheduled_duration
    current_time = get_current_time()
    if current_time is None:
        return
    current_hour = int(current_time[11:13])
    current_minute = int(current_time[14:16])
    if scheduled_time and (current_hour, current_minute) == scheduled_time:
        print("Scheduled time reached. Activating water pump.")
        pin_water_pump.on()
        time.sleep(scheduled_duration)
        pin_water_pump.off()

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
            <h2>Manual Watering System</h2>
            <button class="buttonGreen" name="action" value="start" type="submit">Start Water Pump</button>
            <button class="buttonRed" name="action" value="stop" type="submit">Stop Water Pump</button>
            <h2>Auto Watering System</h2>
            <button class="buttonBlue" name="action" value="auto" type="submit">Activate Auto-Watering System</button>
            <button class="buttonRed" name="action" value="stop" type="submit">Deactivate Auto-Watering System</button>
            <h2>Schedule Watering System</h2>
            <label for="hour">Hour:</label>
            <input type="number" id="hour" name="hour" min="0" max="12">
            <label for="minute">Minute:</label>
            <input type="number" id="minute" name="minute" min="0" max="59">
            <select id="period" name="period">
                <option value="AM">AM</option>
                <option value="PM">PM</option>
            </select>
            <label for="duration">Duration (seconds):</label>
            <input type="number" id="duration" name="duration" min="1">
            <button class="buttonBlue" name="action" value="schedule" type="submit">Set Schedule</button>
            <p>Set the time and duration for how long you want the water pump to be activated.</p>
        </form>
    </center>
</body>
</html>
"""

# Create socket
addr = socket.getaddrinfo('0.0.0.0', 8000)[0][-1]
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
            while 'action=auto' in request_str:
                auto_watering_system()
        elif 'action=stop_auto' in request_str:
            print("Auto-watering system stopped.")
            # Exiting the loop will stop auto-watering system
            break
        elif 'action=schedule' in request_str:
            hour = int(request_str.split('hour=')[1].split('&')[0])
            minute = int(request_str.split('minute=')[1].split('&')[0])
            period = request_str.split('period=')[1].split('&')[0]
            duration = int(request_str.split('duration=')[1].split(' ')[0])
            set_scheduled_time(hour, minute, period, duration)


        schedule_response = urequests.get("http://172.20.10.3/xampp/fetch_data.php")
        schedule_data = schedule_response.json()
        schedule_response.close()
        
        if len(schedule_data) > 0:  # Check if there is any scheduled data
            schedule_item = schedule_data[0]
            # Extract start time and duration from the fetched data
            start_time = schedule_data["startTime"]
            duration_seconds = schedule_data["duration"]
        
            current_time = utime.localtime()
            current_timestamp = utime.mktime(current_time)
            
            start_hour, start_minute, start_second = map(int, start_time.split(':'))
            start_time_today = utime.mktime((current_time[0], current_time[1], current_time[2],
                                                start_hour, start_minute, start_second,
                                                current_time[6], current_time[7]))
            
            end_time_today = start_time_today + duration_seconds
            
            if start_time_today <= current_timestamp <= end_time_today:
                print("Scheduled watering time active")
                pin_water_pump.on()
                time.sleep(duration_seconds)  # Run the water pump for the scheduled duration
                pin_water_pump.off()
            else:
                print("Scheduled watering time not active")

        # Check for scheduled time activation
        check_scheduled_time()

        # Send HTML response
        cl.send('HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'.encode())
        cl.send(html.encode())

        cl.close()
    
    except Exception as e:
        print('Error:', e)

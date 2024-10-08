# 30/7/2024 - Code that are used in fyp1 presentation

import network  # type: ignore
import urequests  # type: ignore
import time
import utime  # type: ignore
import socket
from machine import Pin, ADC, RTC  # type: ignore

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

# Function to set the RTC to the current time
def set_system_time():
    current_time_str = get_current_time()
    if current_time_str:
        current_time_str = current_time_str[:19]  # Strip the milliseconds and timezone info
        year, month, day, hour, minute, second = map(int, current_time_str.replace("T", "-").replace(":", "-").split("-"))
        rtc = RTC()
        rtc.datetime((year, month, day, 0, hour, minute, second, 0))  # Set the RTC

# Set system time
set_system_time()

# Server URL
url = "http://172.20.10.3/xampp/save_data.php"

# Initialize variables
DELAY = 1.0
sensor_signal = ADC(Pin(27))
pin_water_pump = Pin(8, Pin.OUT)
SENSOR_MAX = 430
SENSOR_MIN = 352

flow_frequency = 0
flow_rate = 0
total_milliliters = 0
FLOW_CONVERSION_FACTOR = 4.5
RATE_1 = 0.87
RATE_2 = 1.52
RATE_3 = 2.02

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
    date = get_current_time()
    watering = False

    while True:
        value = round(sensor_signal.read_u16() / 100)
        percent = round(((value - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)) * 100)
        print(f"Reading: {value}, Percent: {percent} ({'DRY' if percent >= 70 else 'WET'})")

        if percent >= 70:
            if not watering:
                print("Soil is dry. Starting watering...")
                pin_water_pump.on()
                watering = True
        else:
            if watering:
                print("Soil is moist. Stopping watering...")
                pin_water_pump.off()
                watering = False
                break  # Exit the loop if the soil is moist

        current_millis = time.ticks_ms()  # type: ignore
        if (current_millis - previous_millis) > interval:
            pulse1Sec = flow_frequency
            flow_frequency = 0
            flow_rate = (1000.0 / (current_millis - previous_millis)) * pulse1Sec / FLOW_CONVERSION_FACTOR
            previous_millis = current_millis

            flow_milliliters_per_min = flow_rate * 1000
            total_milliliters += flow_milliliters_per_min * (interval / 60000)
            total_volume_m3 = total_milliliters / 1_000_000
            bill_amount = calculate_water_bill(total_volume_m3)

            print(f"\n-------------------\nFlow Rate = {flow_rate:.2f} Liters/Minute\nTotal Volume = {total_milliliters:.2f} Milliliters\nTotal Volume = {total_volume_m3:.6f} Cubic Meters\nWater Bill Amount = RM {bill_amount:.2f}\n-------------------\n")

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

        # Sleep briefly to avoid excessive looping
        time.sleep(1)

def process_schedule_data(schedule_data):
    if schedule_data and len(schedule_data) > 0:
        for schedule_item in schedule_data:
            start_time = schedule_item.get("startTime")
            duration_seconds = int(schedule_item.get("duration", 0))
            is_on = int(schedule_item.get("isOn", 0))

            print(f"Processing schedule item: {schedule_item}")

            if start_time and is_on == 1:
                time_parts = start_time.split(':')
                if len(time_parts) == 3:
                    try:
                        start_hour, start_minute, start_second = map(int, time_parts)
                    except ValueError:
                        print("Invalid start time format")
                        continue

                    current_time = utime.localtime()
                    current_hour = current_time[3]
                    current_minute = current_time[4]
                    current_second = current_time[5]

                    print(f"Current time: {current_hour:02}:{current_minute:02}:{current_second:02}")
                    print(f"Scheduled time: {start_hour:02}:{start_minute:02}:{start_second:02}")

                    # Adjust the comparison to allow for potential delays
                    if current_hour == start_hour and current_minute == start_minute and current_second >= start_second:
                        print("Scheduled watering time active")
                        pin_water_pump.on()
                        time.sleep(duration_seconds)
                        pin_water_pump.off()
                else:
                    print("Invalid start time format")
            else:
                print("No valid start time or isOn is not 1")

schedule_active = False

def activate_schedule():
    global schedule_active
    schedule_active = True
    while schedule_active:
        # Fetch schedule data and process it continuously
        try:
            schedule_response = urequests.get("http://172.20.10.3/xampp/fetch_data.php")
            schedule_data = schedule_response.json()
            schedule_response.close()
            process_schedule_data(schedule_data)
        except Exception as e:
            print("Error fetching and processing schedule data:", e)

        # Sleep briefly to avoid excessive looping
        time.sleep(10)  # Check for new schedule every 10 seconds

def deactivate_schedule():
    global schedule_active
    schedule_active = False

addr = socket.getaddrinfo('0.0.0.0', 5026)[0][-1]
s = socket.socket()
s.bind(addr)
s.listen(1)
print('Listening on', addr)

while True:
    try:
        cl, addr = s.accept()
        print('Client connected from', addr)
        request = cl.recv(1024).decode('utf-8')
        print("Request:", request)
       
        if 'action=start' in request:
            pin_water_pump.on()
        elif 'action=stop' in request:
            pin_water_pump.off()
        elif 'action=auto' in request:
            auto_watering_system()
        elif 'action=auto-stop' in request:
            pass
        elif 'action=activate-schedule' in request:
            activate_schedule()  # Start schedule-based watering system
        elif 'action=deactivate-schedule' in request:
            pass  # Stop schedule-based watering system
        
        cl.send('HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'.encode())
        cl.close()
                
    except Exception as e:
        print('Error:', e)

# Based on this code, i have modify all the difference function in each scripts
# Test it out tomorrow if its works!
# Goodluck yana!
import network # type: ignore
import select
import time 
import utime # type: ignore
import socket
import urequests  # type: ignore
from machine import Pin, ADC # type: ignore

# Wi-Fi credentials
ssid = "yanaezani"
password = "yana1012"
def connect_to_wifi(ssid, password, timeout=10):
    wifi = network.WLAN(network.STA_IF)
    wifi.active(True)
    wifi.connect(ssid, password)
    
    start_time = time.time()
    while not wifi.isconnected():
        if time.time() - start_time > timeout:
            print("Failed to connect to Wi-Fi")
            return False
        print("Trying to connect to Wi-Fi...")
        time.sleep(1)

    print("Connected to Wi-Fi:", wifi.ifconfig())
    return True

def get_current_time():
        try:
            response = urequests.get("http://worldtimeapi.org/api/timezone/Asia/Kuala_Lumpur")
            data = response.json()
            current_time = data["datetime"]
            return current_time
        except Exception as e:
            print("Error getting current time:", e)
            return None
        
pin_water_pump = Pin(8, Pin.OUT)
flow_sensor = Pin(19, Pin.IN, Pin.PULL_UP)
sensor_signal = ADC(Pin(27))
reading = 0
percent = 0
DELAY = 1.0
SENSOR_MAX = 500
SENSOR_MIN = 200
flow_frequency = 0
flow_rate = 0
total_milliliters = 0
FLOW_CONVERSION_FACTOR = 4.5  # Calibration factor (pulses per liter)
RATE_1 = 0.87  # 0 to 20 cubic meters
RATE_2 = 1.52  # 20 to 35 cubic meters
RATE_3 = 2.02  # Above 35 cubic meters
url = "http://172.20.10.3/xampp/save_data.php"
fetch_url = "http://172.20.10.3/xampp/fetch_data.php"

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
        date = get_current_time()  # Get current date and time
        value = round(sensor_signal.read_u16() / 100) # Take a reading from the sensor and make it easier to read
        print("Reading:", value)
        # Calculate the percentage
        percent = round(((value - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)) * 100)
        print("Percent:", percent, end=' ')
        if percent >= 70:
            print("(DRY)")
            pin_water_pump.on()
            time.sleep(5)
            pin_water_pump.off()

            data = {
                'date': date,
                'reading': value,
                'percent': percent,
            }

            try:
                response = urequests.post(url, json=data)
                print(response.text)
                response.close()
            except Exception as e:
                print("Error sending data:", e)

def connect_flow_sensor():
        global flow_frequency, previous_millis, total_milliliters
        date = get_current_time()  # Get current date and time
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

def fetch_watering_data():
    try:
        response = urequests.get(fetch_url)
        data = response.json()
        return data
    except Exception as e:
        print("Error fetching watering data:", e)
        return []
def schedule_watering(data):
    try:
        for schedule in data:
            start_time = schedule['startTime']
            duration = schedule['duration']
            is_on = schedule['isOn']
            deleted = schedule['deleted']
            plant_id = schedule['plantId']
            
            if is_on and not deleted:
                # Here, you can implement the logic to schedule the watering
                print(f"Scheduling watering for Plant ID: {plant_id} at {start_time} for {duration} minutes.")
                # Assuming you have a function to handle the watering
                handle_watering(start_time, duration)
    except Exception as e:
        print("Error in schedule_watering:", e)
def handle_watering(start_time, duration):
    # Implement the logic to handle the watering based on the start time and duration
    print(f"Starting watering at {start_time} for {duration} minutes.")
    pin_water_pump.on()
    time.sleep(duration * 60)  # Duration is in minutes
    pin_water_pump.off()

# Function to create a socket and listen on a specific port
def create_socket_and_listen(port):
    addr = socket.getaddrinfo('0.0.0.0', port)[0][-1]
    s = socket.socket()
    s.bind(addr)
    s.listen(1)
    print(f'Listening on port {port}')
    return s
# Create sockets for each function
manual_socket = create_socket_and_listen(5000)
auto_socket = create_socket_and_listen(6001)
flow_socket = create_socket_and_listen(7002)
schedule_socket = create_socket_and_listen(8003)


while True:
    
    wifi = network.WLAN(network.STA_IF)
    wifi.active(True)
    wifi.connect(ssid, password)
    readable, _, _ = select.select([manual_socket, auto_socket, flow_socket], [], [])

    fetch_watering_data()

    for s in readable:
        cl, addr = s.accept()
        print('Client connected from', addr)
        request = cl.recv(1024)
        request_str = request.decode('utf-8')
        print("Request:")
        print(request_str)

        if s == manual_socket:
            if 'action=start' in request_str:
                pin_water_pump.on()
            elif 'action=stop' in request_str:
                pin_water_pump.off()

        elif s == auto_socket:
            if 'action=auto' in request_str:
                while 'action=auto' in request_str:
                    auto_watering_system()
            elif 'action=stop_auto' in request_str:
                print("Auto-watering system stopped.")
                break
        
        elif s == schedule_socket:
            if 'action=schedule' in request_str:
                watering_data = fetch_watering_data()
                schedule_watering(watering_data)
            elif 'action=stop_schedule' in request_str:
                print("Scheduled watering stopped.")
                break

    time.sleep(0.1)

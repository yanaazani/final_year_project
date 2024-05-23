import time
import utime # type: ignore
from machine import Pin, ADC # type: ignore
import urequests # type: ignore
from time_fetch import get_current_time
from water_billing import calculate_water_bill

# Initialize variables
reading = 0
percent = 0
scheduled_time = None  # Variable to store the scheduled time

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

flow_sensor = Pin(19, Pin.IN, Pin.PULL_UP)

def flow_callback(pin):
    global flow_frequency
    flow_frequency += 1

flow_sensor.irq(trigger=Pin.IRQ_RISING, handler=flow_callback)

previous_millis = 0
interval = 1000

# Server URL
url = "http://172.20.10.3/xampp/save_data.php"
def auto_watering_system():
    global flow_frequency, previous_millis, total_milliliters
    date = get_current_time()  # Get current date and time

    # Take a reading from the sensor and make it easier to read
    value = round(sensor_signal.read_u16() / 100)
    print("Reading:", value)

    # Calculate the percentage
    percent = round(((value - SENSOR_MIN) / (SENSOR_MAX - SENSOR_MIN)) * 100)

    # **Added check to ensure percent does not exceed 100**
    if percent > 100:
        percent = 100
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

        print("\n-------------------\n")




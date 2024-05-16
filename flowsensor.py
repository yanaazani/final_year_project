from machine import Pin  # type: ignore
import utime  # type: ignore
import urequests  # type: ignore

flow_frequency = 0
flow_rate = 0
last_call_time = 0
total_milliliters = 0

# Define constants for flow sensor
FLOW_CONVERSION_FACTOR = 4.5  # Liters per pulse calibration factor

# Water billing rates (RM per cubic meter)
RATE_1 = 0.87  # 0 to 20 cubic meters
RATE_2 = 1.52  # 20 to 35 cubic meters
RATE_3 = 2.02  # Above 35 cubic meters

pin = Pin(19, Pin.IN, Pin.PULL_UP)

def callback(pin):
    global flow_frequency
    flow_frequency += 1

pin.irq(trigger=Pin.IRQ_RISING, handler=callback)

# Server URL
url = "http://172.20.10.3/xampp/save_data.php"

previous_millis = 0
interval = 1000

def calculate_water_bill(volume_m3):
    if volume_m3 <= 20:  # Volume less than or equal to 20 m³
        return RATE_1 * volume_m3
    elif volume_m3 <= 35:  # Volume between 20 m³ and 35 m³
        return RATE_1 * 20 + RATE_2 * (volume_m3 - 20)
    else:  # Volume greater than 35 m³
        return RATE_1 * 20 + RATE_2 * 15 + RATE_3 * (volume_m3 - 35)

while True:
    current_millis = utime.ticks_ms()
    if (current_millis - previous_millis) > interval:  # if time interval is more than 1 second
        pulse1Sec = flow_frequency
        flow_frequency = 0  # Reset Counter
        
        # Calculate the flow rate in liters per minute
        flow_rate = ((1000.0 / (current_millis - previous_millis)) * pulse1Sec) / FLOW_CONVERSION_FACTOR
        previous_millis = current_millis

        # Convert the flow rate to milliliters per minute
        flow_milliliters_per_min = flow_rate * 1000

        # Add the milliliters passed in this interval to the cumulative total
        total_milliliters += flow_milliliters_per_min * (interval / 60000)  # Convert minutes to milliseconds

        # Calculate total volume in cubic meters
        total_volume_m3 = total_milliliters / 1_000_000  # Convert from milliliters to cubic meters

        # Calculate the water bill
        bill_amount = calculate_water_bill(total_volume_m3)

        print("\n-------------------\n")
        print("Flow Rate = {:.2f} Liters/Minute".format(flow_rate))
        print("Total Volume = {:.2f} Milliliters".format(total_milliliters))
        print("Total Volume = {:.6f} Cubic Meters".format(total_volume_m3))
        print("Water Bill Amount = RM {:.2f}".format(bill_amount))
        print("\n-------------------\n")

        # Current date and time
        now = utime.localtime()
        date = "{:04d}-{:02d}-{:02d} {:02d}:{:02d}:{:02d}".format(now[0], now[1], now[2], now[3], now[4], now[5])

        # Prepare data to send to PHP script
        data = {
            'date': date,
            'flow_rate': flow_rate,
            'volume': total_volume_m3,
            'amount': bill_amount
        }

        # Send HTTP POST request to PHP script
        try:
            response = urequests.post(url, json=data)
            print(response.text)
            response.close()
        except Exception as e:
            print("Error sending data:", e)

from machine import Pin  # type: ignore
import utime  # type: ignore
import urequests  # type: ignore

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
    

# Server URL
url = "http://172.20.10.3/xampp/save_data.php"

while True:
    if ((utime.ticks_ms() - last_call_time) > 1000):  # if time interval is more than 1 second
        flow_rate = (flow_frequency * 60 / FLOW_CONVERSION_FACTOR) / 3600  # flow rate in L/s
        flow_frequency = 0  # Reset Counter
        last_call_time = utime.ticks_ms()

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

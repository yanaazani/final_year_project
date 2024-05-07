import network # type: ignore
import time
import machine # type: ignore
from machine import Pin, ADC # type: ignore

# how frequently to take readings
DELAY = 1.0
# set the analog read pin for the moisture sensor
sensor_signal = ADC(Pin(27))
# set up the buzzer
buzzer = Pin(18, Pin.OUT)
NOTE_C5 = 523
# set up the water pump pin
pin_water_pump = Pin(8, Pin.OUT)
# some variables for internal use0
calibrate_count = 0
auto_calibrate = True
SENSOR_MAX = 0
SENSOR_MIN = 9999

#Connect rapsberry to WLAN
ssid = 'yanaezani'
password = 'yana1012'

#build function to connect to WLAN
def connect():
    #Connect to WLAN
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, password)
    #Sending requesti each second until connection handshake performed
    while wlan.isconnected()== False:
        print('Waiting for connection...')
        time.sleep(1)
        
try:
    connect()
except KeyboardInterrupt:
    machine.reset()

print("=============")
print("calibrating sensor")
print("=============\n\n")

while True:
    if auto_calibrate:
        # take a reading from the sensor and make it a little easier to read
        value = round(sensor_signal.read_u16() / 100)
        print("reading:", value)

        if value > SENSOR_MAX:
            SENSOR_MAX = value

        if value < SENSOR_MIN:
            SENSOR_MIN = value

        calibrate_count += 1

        if calibrate_count > 100:
            print("\n-------------------")
            print("MIN:", SENSOR_MIN)
            print("MAX:", SENSOR_MAX)
            print("-------------------\n")
            time.sleep(5)

            auto_calibrate = False

        time.sleep(0.2)
    else:
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
            # simpleio.tone(buzzer, NOTE_C5, 0.5)
            # time.sleep(1)


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


        # wait for the required delay
        time.sleep(DELAY)

        print("\n-------------------\n")

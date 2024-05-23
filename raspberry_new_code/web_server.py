import socket
from auto_watering import auto_watering_system
from machine import Pin, ADC  # type: ignore

pin_water_pump = Pin(8, Pin.OUT)

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
            <button class="buttonRed" name="action" value="stop_auto" type="submit">Deactivate Auto-Watering System</button>
        </form>
    </center>
</body>
</html>
"""

def start_web_server():
    addr = socket.getaddrinfo('0.0.0.0', 8000)[0][-1]
    s = socket.socket()
    s.bind(addr)
    s.listen(1)
    print('Listening on', addr)

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

            # Send HTML response
            cl.send('HTTP/1.0 200 OK\r\nContent-Type: text/html\r\n\r\n'.encode())
            cl.send(html.encode())

            cl.close()
        
        except Exception as e:
            print('Error:', e)

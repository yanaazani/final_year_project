import network # type: ignore

def connect_wifi(ssid, password):
    wifi = network.WLAN(network.STA_IF)
    wifi.active(True)
    wifi.connect(ssid, password)
    
    while not wifi.isconnected():
        pass
    
    print("Connected to Wi-Fi")
    return wifi

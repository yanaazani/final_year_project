# Water billing rates (RM per cubic meter)
RATE_1 = 0.87  # 0 to 20 cubic meters
RATE_2 = 1.52  # 20 to 35 cubic meters
RATE_3 = 2.02  # Above 35 cubic meters

def calculate_water_bill(volume_m3):
    if volume_m3 <= 20:
        return RATE_1 * volume_m3
    elif volume_m3 <= 35:
        return RATE_1 * 20 + RATE_2 * (volume_m3 - 20)
    else:
        return RATE_1 * 20 + RATE_2 * 15 + RATE_3 * (volume_m3 - 35)

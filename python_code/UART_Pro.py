import serial
import matplotlib.pyplot as plt
from matplotlib.widgets import Slider
import numpy as np
from collections import deque

# UART settings
UART_PORT = '/dev/ttyUSB0'  # Change this to your UART port
BAUD_RATE = 115200

# GUI settings
FIG_SIZE = (10, 6)
SAMPLES_PER_UPDATE = 1022

# Initialize UART connection
uart = serial.Serial(UART_PORT, BAUD_RATE)

# Initialize plot
fig, ax = plt.subplots(figsize=FIG_SIZE)
plt.subplots_adjust(left=0.1, bottom=0.25)
ax.set_xlim(0, SAMPLES_PER_UPDATE)
ax.set_ylim(0, 1)
line, = ax.plot([], [])

# Initialize data buffer
data_buffer = deque(maxlen=SAMPLES_PER_UPDATE)

# Function to update plot
def update_plot(val):
    global data_buffer
    line.set_ydata(data_buffer)
    fig.canvas.draw_idle()

# Function to receive data from UART and update plot
def receive_data_and_plot():
    global data_buffer
    bytes_read = uart.read(SAMPLES_PER_UPDATE)
    binary_data = ''.join(format(byte, '08b') for byte in bytes_read)
    #data_buffer = deque(int(bit) for bit in binary_data, maxlen=SAMPLES_PER_UPDATE)
    data_buffer = deque(maxlen=SAMPLES_PER_UPDATE)
    data_buffer.extend(int(bit) for bit in binary_data)
    update_plot(0)

# Create a slider for moving the plot
ax_slider = plt.axes([0.1, 0.1, 0.65, 0.03])
slider = Slider(ax_slider, 'Time', 0, 1, valinit=0)

# Callback function for slider
def slider_callback(val):
    ax.set_xlim(val * SAMPLES_PER_UPDATE, val * SAMPLES_PER_UPDATE + SAMPLES_PER_UPDATE)
    fig.canvas.draw_idle()

slider.on_changed(slider_callback)

# Start receiving data and updating plot
receive_data_and_plot()

# Show the plot
plt.show()

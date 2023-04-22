import serial

class SerialServer:
    def __init__(self, port, baud_rate):
        self._port_device = port
        self._baud_rate = baud_rate
        self._port = serial.Serial(self._port_device, self._baud_rate)


    def read_byte(self):
        b1 = bytes()
        while len(b1) == 0:
            b1 = self._port.read()

        return b1[0]


    def send_byte(self, byte):
        b_out = bytes([byte])
        written = 0
        while written == 0:
            written = self._port.write(b_out)

if __name__ == "__main__":
    p = SerialServer("/dev/ttyUSB0", 115200)
    for i in range(2000):
        res = p.read_byte()
        print(i, res)
        p.send_byte(res+1)

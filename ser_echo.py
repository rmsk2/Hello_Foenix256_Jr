import serial

class SerialServer:
    def __init__(self, port, baud_rate):
        self._port_device = port
        self._baud_rate = baud_rate
        self._port = serial.Serial(self._port_device, self._baud_rate)


    def read_frame(self):
        b1 = bytes()
        while len(b1) == 0:
            b1 = self._port.read()
        
        num_bytes = b1[0]

        res = bytes()
        while len(res) != num_bytes:
            read_now = self._port.read(num_bytes - len(res))
            res = res + read_now 

        return res


    def write_frame(self, data):
        header = bytes([len(data)])
        packet = header + data

        while len(packet) != 0:
            bytes_written = self._port.write(packet)
            packet = packet[bytes_written:]


if __name__ == "__main__":
    p = SerialServer("/dev/ttyUSB0", 115200)
    for i in range(2000):
        res = p.read_frame()
        print(i, res)
        p.write_frame(res)


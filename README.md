A UART (Universal Asynchronous Receiver-Transmitter) transmitter is a hardware component or module that is responsible for transmitting serial data over a communication channel. It converts parallel data into a serial bitstream for transmission. Here's a general description of a UART transmitter:

The UART transmitter is a crucial component in serial communication systems, enabling data transfer between devices that may not have a shared clock signal. It is widely used in various applications, including microcontrollers, embedded systems, and computer peripherals.

The primary function of the UART transmitter is to convert parallel data (typically 8 bits or a byte) into a serial bitstream. This process involves breaking down the parallel data into individual bits and transmitting them one by one over the communication channel.

Before transmitting the data, the UART transmitter adds additional bits to the data frame, including start and stop bits. The start bit is used to signal the beginning of a new data frame, while the stop bit(s) indicate the end of the frame. These additional bits help the receiver synchronize and correctly interpret the transmitted data.

Some UART implementations may include handshaking signals, such as Ready to Send (RTS) and Clear to Send (CTS), to coordinate the flow of data between the transmitter and receiver, preventing data loss or overrun conditions.

Implementation: UART transmitters can be implemented in various ways, including dedicated hardware circuits, microcontroller peripherals, or software-based implementations using general-purpose input/output (GPIO) pins and timer/counter modules but in this repo you will find it implemented using verilog which can be used with FPGA.

The UART transmitter plays a crucial role in enabling serial communication between devices, allowing data to be transmitted reliably and efficiently over a single or differential communication channel. Its functionality, combined with the corresponding UART receiver, enables the exchange of data in applications ranging from microcontrollers to computer peripherals and industrial systems.

UART has many data formats so the data format that we use is the folllowing  :
![image](https://github.com/aboElhammd/UART/assets/124165601/eaf896ce-3cbe-4176-90d4-637c64c4b7e9)
![image](https://github.com/aboElhammd/UART/assets/124165601/9e549150-f968-4313-830c-519bfb25055e)

we can use both even or odd bit so the code is configured so that we can use both .

the UART TX main blocks :
1-FSM
2-MUX
3-serializer 
4-Parity generator 
![image](https://github.com/aboElhammd/UART/assets/124165601/cc8ef621-e624-44c0-9359-8ea381e6b9a6)
here is a picture of how the blocks is connected but some control signals has been added while verification to cover some corener cases 
the design is verififed using self checking testbench that covers most of the corner cases 

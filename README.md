# FPGA Audiovisualizer
ECE241 - Digital Systems - Final Project

Finite State Machine, cycles through gathering digital signal of audio, processing the signal 
a filter to determine amplitude of frequencies, and dsiplaying the eight different amplitudes. 
Using a VGA Controller display the amplitude of a select bandwith of frequencies (1-20Hz, 380-420Hz, 780-820Hz, 1180Hz-1220Hz, 1580-1620Hz, 1980-2020Hz, 2380-2420Hz, 2980-3020Hz) by implementing
an FIR filter using a shift register. The FIR filters coefficients where calculated using Matlab. 

Unfortunately, the chosen bandwiths were far too small leading to a skewed output since only a very small bandwidth of frequencies (40Hz) were being isolated. Therefore, unless the inputted sound was exactly a frequency in one of the bandwidths (like those found in the Tones folders) where used as inputs the Audiovisualizer did not match the expected output. 

In the future, the bandwidths need to be much larger to allow for better visualization. In addition, a more accurate filter could be implemented by using a higher frequency digital signal to allow for better filtering. 

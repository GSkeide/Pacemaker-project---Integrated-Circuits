# Pacemaker project – TFE4152 Design of integrated circuits

- `pacemaker/src/` – Verilog source (transistor-level gates, FSM, timer, testbench)
- Open `IC_project.aws` in Active-HDL to compile and simulate


Project not done.. Currently this is only the digital part:
<img width="1952" height="908" alt="image" src="https://github.com/user-attachments/assets/179de35b-2760-481a-a661-376d2535e41e" />


Eventually the entire system will look somewhat like this:
<img width="1944" height="480" alt="image" src="https://github.com/user-attachments/assets/84b96c1e-e094-49d8-a2da-b7bb83af4c85" />

We have a 512 Hz clock for our digital circuitry. 
The idea is to pace the heart with a P pulse if the heart is below 40 beats per minute.
For this we use a timer, which count 1.5 s. As 60/40 = 1.5 s.
If 1.5 seconds have passed, beats are below 40 bpms and we will pace the heart for 2 ms.

With a 512 Hz clock, this means 768 clock cycles before a pace is needed.
A 10 bit ripple counter timer is used for this. 
If we receive a heartbeat before the timer has finished counting, we reset the timer to 0.

768 in binary is 11 0000 0000
Thus, the T signal can be derived from the last 2 bits.


The timer is implemented like this (a ripple counter):
<img width="1678" height="466" alt="image" src="https://github.com/user-attachments/assets/b519889a-0e81-4d2b-8e83-accfbe3bdfec" />

At the lower level it uses flipflops like this:
<img width="826" height="616" alt="image" src="https://github.com/user-attachments/assets/68ad139b-1cd0-4654-9154-277dafa0b0cd" />


The FSM:
<img width="1044" height="506" alt="image" src="https://github.com/user-attachments/assets/5aa22d2b-c66c-418c-92d1-4db21f7371a8" />

Truth table:
<img width="914" height="602" alt="image" src="https://github.com/user-attachments/assets/ecf166fb-d5f3-417c-9652-dc587b1ea437" />

After boolean algebra:
<img width="1154" height="238" alt="image" src="https://github.com/user-attachments/assets/eed54111-40e1-46b4-b42d-5c44e33634c4" />

The initial sketch used normal gates like this:
<img width="1302" height="1134" alt="image" src="https://github.com/user-attachments/assets/8fce1929-4678-4686-8c71-2999d15540e9" />

However, we decided to redo it using static cmos, which is what's implemented in the verilog files:

<img width="1120" height="1426" alt="image" src="https://github.com/user-attachments/assets/c2a82596-5c35-4ddc-b403-a71f5ba86996" />




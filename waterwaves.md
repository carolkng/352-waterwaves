# 2019-02-13: Prelab and investigation of lab manual

## 4:02 PM: First inspection of content in lab manual

**Introduction:**

The purpose of the lab is to observe and measure the dispersive properties of water waves. Since the frequency in time of the water wave is not exactly proportional to its wavenumber, the phase velocity and the group velocity of the wave will be different, meaning that water waves are dispersive, with the following relationships: 

$$v_p = \omega / k,\, v_g = \d \omega / \d k$$

**Remaining questions:**

- How do we identify group velocity and phase velocity from the raw datapoints? (needs more background research)
- How can we relate this to an actual quantity? Does the analysis give way to some real-life quantities that have been measured often/precisely?
- From Landau and Lifshitz p.39: how does the velocity potential relate to the actual group/phase velocities?
- Step 1 in the procedure says that the group and phase velocities are supposed to be for depths of 1cm, 10cm, and 100cm. How are we supposed to do the 100cm depth if we don’t have a 100cm deep tank? (max depth seems to be about 15cm?)

**Procedure:**
Refer to page 115 of the ENPH 352 lab manual.
QRD1113 spec sheet used for “calibration” of the voltage output vs the actual depth (no Internet access currently, but update later with a link

Target is to use MATLAB to find the calibration factor, then link the voltage output to an actual depth. 

# 2019-02-26: Continuation of introduction

Can't attend lab today due to urgent flight

**Detailed procedure for next lab session**:

- Investigate the MATLAB script to take raw data for a session
- Set up the water depth to find the calibration factor for the sensors to make any corrections to the depth readings if necessary

# 2019-02-28: First time in the lab

## 12:53 PM: First contact with BareBonesDAQ.m script

Current output:

```
Error using daq.analoginput_mcc_1_29/start
MCC: D/A is not responding - Is base address correct?

Error in daqdevice/start (line 62)
start( daqgetfield(obj,'uddobject') );

Error in BareBonesDaq (line 62)
start(AI);
```

AI is the analoginput (presumably the sensors), and AO the analogoutput (presumably the sensor output voltage)

Running the BareBonesDAQ.m script yields nothing even for a simple run

## 13:01 PM: Fixed the DAQ somehow

Plugging and unplugging the USB cable did the trick. Also tried plugging and unplugging the power supply.

## 13:22: Adjusted procedure

**Procedure/changes from barebonesdaq.m**
- Push the sensors close to the bottom of the basin, then mark the zero location at the top of the brass tube holding the sensors using a pen
- Before putting the sensors back in the basin, put the paddle in the basin, excite the waves onces by pressing and holding down the button on the paddle, then gauge the height of the excited waves
- Adjust the sensors such that they are 2mm above the original water level 
Original rationale for setting the runtime to 6 seconds instead of the original 3 was because it should give us more time to press and excite the modes

However, adding a starting indicator should help us time the excitation properly without wasting extra data on times that are not necessary

Also have a sneaking suspicion that sensor 2 doesn't actually work, because the output value is constant despite the excited waterwaves at 2 cm depth. Troubleshoot by changing the position to that of sensor 1's and seeing if the value changes.

Original sensor 2 values: between 0.005 and 0.015 V, alternating
Changed sensor 2 vakues, when placed closer to sensor 1 location: between 0.02 and 0.12, with similar shape and transformed appropriately (shifted forward on time axis)

mini conclusion: sensor 2 is ok

## 13:57: Augment procedure

**Procedure changes**
- Place the two sensors at the positions indicated by the sharpie on the tank (approx 14.2 cm from the edge of the tank), with sensor 1 closer to the paddle, and sensor 2 on the other side of the tank. The sensors should be ~22.5cm apart
- For sequence of depth changes for the whole experiment, take values up to ~12cm with 1cm increments, 3 times each for redundancy (allowing for extra data analysis time at home)
- Set the data acquisition interval to 10 seconds for the rest of the experiment
- Wait about 10 seconds for the waves to "cool down" before taking another set of data

## 14:40: Completed data acquisition

Complete data acquisition for the following depths (all +/- 1mm) 
- 2cm, 3.7cm, 5cm, 6.5cm, 8cm, 9cm, 10cm, 11.2cm, 12.5cm, 

# 2019-03-05: Extra data acquisition

Using the method above, completed data acquisition for the depth (+/- 1mm) 
- 1 cm

# 2019-03-05: Data analysis




%Basic DAQ aquisition for 4 inputs
%James Simard (2011), Chris Waltham (2015-17)
%This program records the data from 4 channels of an mcc daq. 
%It is also capable of triggering a function generator before taking data
%if one is being used.

close all
%initialize the analog input object
AI=analoginput('mcc');
%initialize analog out for triggering function generator
AO=analogoutput('mcc');

%specify which channels on the DAQ will be used
%chan1=addchannel(AI,0); % not used in this expt
%chan2=addchannel(AI,1); % not used in this expt
chan1=addchannel(AI,2); % use for sensor 1
chan2=addchannel(AI,3); % use for sensor 2
outChannel = addchannel(AO,0); % analog out channel
% set(chan1,'InputRange',[-ADrange,ADrange]);
% set(chan1,'SensorRange',[-ADrange,ADrange]);
% set(chan1,'UnitsRange',[-ADrange,ADrange]);
%     
% set(chan2,'InputRange',[-ADrange,ADrange]);
% set(chan2,'SensorRange',[-ADrange,ADrange]);
% set(chan2,'UnitsRange',[-ADrange,ADrange]);

%Set AD range and linear scaling, making all 3 the same will return volts
%Formula is value = (A/D value)*(units range)/(sensor range)
%Input range sets the DAQs AD range, supports +/- 1,2.5,5 and 10V
ADrange = 2.5;

runTime = 10; %seconds

%Number of samples to be collected by each channel. Max number is 
%65536/(# of channels active).
sampleNumber = 65536/4; %use powers or 2 for the FFT

%The max data rate is 50000/(# of channels active), this statement
%prevents this number from being exceeded
tempRate = sampleNumber/runTime;
if(tempRate > 50000/4)
    sampleRate = 50000/4;%if rate is too high, default to max
    sampleNumber = sampleRate*runTime;%recalc sampleNumber based on new rate
else
    sampleRate = tempRate;
end

%if the DAQ runs for runtime+timout seconds then it is considered an error
%and will automatically stop.
timeout = 3;

%Set the DAQ properties, triggerType Immediate will cause the DAQ to start 
%taking data the moment start(AI) is called.
set(AI,'TriggerType','Immediate');
set(AI,'SampleRate',sampleRate);
set(AI,'SamplesPerTrigger',sampleNumber);
set(AI,'Timeout',timeout);
set(AO, 'TriggerType','Manual');

disp('starting')
putsample(AO,4); %trigger function generator if one is being used
putsample(AO,0); %triggered by falling pulse
start(AI);
wait(AI,runTime+1);

%[data time] = getdata(AI); Returns 2 matrices, data contains 1 column for each channel, time simply
%returns a time stamp for the first channel scanned in a row.
%ie if channel 1,2,3,4 are all used then data will have 4 colunms and time will
%contain the time stamps for channel 1. To get the time for the other
%channels just take into account the sample rate and add accordingly.
[data,time] = getdata(AI);
%ex: plot(time(:),data(:,1)); would plot channel 1's data against time.
figure
plot(time(:),data(:,1),'b');
xlabel('t (s)')
ylabel('signal (V)')
legend('signal 1')
figure
plot(time(:),data(:,2),'r');
xlabel('t (s)')
ylabel('signal (V)')
legend('signal 2')

figure
ft = abs(fft(data));
plot(ft)
xlim([3 250])
% plot(time(:),data(:,3),'g');
% xlabel('t (s)')
% ylabel('signal (V)')
% legend('signal 3')
% figure
% plot(time(:),data(:,4),'m');
% xlabel('t (s)')
% ylabel('signal (V)')
% legend('signal 4')

% remove the daq from memory
delete(AI) 
clear AI
delete(AO) 
clear AO

FileName=['12cm_5mm_',datestr(now, 'ddmmyyyy_HHMMSS'),'.mat'];
save(FileName,'time','data', 'ft');
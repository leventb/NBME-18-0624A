clear all;
close all;

nport = 3;
fstart = 0.1e9;
fstop = 2e9;
Npts = 1601;
Ntime = 1*60; %seconds
Tsample = 0; %seconds 

folder = '..//03_30_2013';
pickup_ant = 'loop4mm';
sensor = 'noise';

sigtol = 1.5;
noise = 0;
winN = 9;

fp0 = 9.9749e8;
dfdp = -1.3126e+06;

values = [10*ones(1,5) zeros(1,20) 20*ones(1,5) zeros(1,20) 30*ones(1,5) zeros(1,20) 40*ones(1,5) zeros(1,20) 50*ones(1,5) zeros(1,20)]';
% values = [0:100:500 zeros(1,50) 0:20:500 zeros(1,50)]';
presRange = 15*51.7149;
voltRange = 10;
voltages = values.*(voltRange/presRange); %V

suffix = '.csv';
Z0 = 50;
    
siglabel = 'signal in d/df(\angleS/S_R_E_F)';
specs = {'-', 'xr', ':k', 'xk'};

s = daq.createSession('ni');
s.Rate = 10;
s.addAnalogInputChannel('Dev1', [2 3], 'Voltage');
s.Channels(1).InputType = 'SingleEndedNonReferenced';
s.Channels(2).InputType = 'SingleEndedNonReferenced';
s.addAnalogOutputChannel('Dev1', 0, 'Voltage');

instrreset;
visa_addr='USB0::0x0957::0x0D09::MY46102701::0::INSTR';
obj1 = instrfind('Type', 'visa', 'RsrcName', visa_addr, 'Tag', '');
% create the VISA-GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('agilent', visa_addr);
else
    fclose(obj1);
    obj1 = obj1(1);
end
% max out buffer size for largest possible read of 1601 points
set(obj1,'InputBufferSize', 80050);
% connect to instrument object, obj1.
fopen(obj1);
% communicating with instrument object, obj1.
instrinfo = query(obj1, '*IDN?');
fprintf(1, 'Connected to: %s\n', instrinfo);
fwrite(obj1, ['SENS:FREQ:START ', num2str(fstart)]);
fwrite(obj1, ['SENS:FREQ:STOP ', num2str(fstop)]);
fwrite(obj1, ['SENS:SWE:POINTS ', num2str(Npts)]);
fwrite(obj1, ['CALC:PAR:DEF S', num2str(nport), num2str(nport)]);
fwrite(obj1, 'FORM:DATA ASC'); 
fwrite(obj1, 'SENS:FREQ:DATA?');
freq = fscanf(obj1); 
fwrite(obj1, 'INIT:CONT 1');

calibTerms = {'OPEN', 'SHORT', 'LOAD'};
reply = input('Calibrate VNA? y/n: ', 's');
while (~strcmp(reply,'n'))
    fwrite(obj1, 'INIT:CONT 0');
    fwrite(obj1, ['SENS:CORR:COLL:METH:SOLT1 ', num2str(nport)]);    
    for i = 1:length(calibTerms)
        input(['Press enter to sweep ',calibTerms{i},'\n'], 's');
        fwrite(obj1, ['SENS:CORR:COLL:', calibTerms{i}, ' ', num2str(nport)]);
        fwrite(obj1, '*OPC?');
        opc_comp=fscanf(obj1);
    end
    fwrite(obj1, 'SENS:CORR:COLL:SAVE');
    reply = input('Try again? y/n: ', 's');
end

fwrite(obj1, 'INIT:CONT 1');
fwrite(obj1, 'CALC:FORM GDEL');
fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');

% flush the buffer
clrdevice(obj1);
fall = transpose(str2num(freq));

scrsz = get(0,'ScreenSize');
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
Hwin = 0.4*scrsz(4);
Wwin = 0.25*scrsz(3);
sizeWIN = [2*Wwin 2*Hwin];
    
filenameREF = [folder, '//', pickup_ant, '_', sensor, '_REF', suffix];
filenameCALIB = [folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix];

figure('Position',[posWINrb sizeWIN]);
fprintf(1, 'Press any key to initialize test\n');
w = waitforbuttonpress;
fwrite(obj1, 'INIT:CONT 0');
reply = [];
while (~strcmp(reply,'n'))
    fprintf(1, 'Sweeping reference\n');
	fwrite(obj1, 'INIT:IMM; *OPC?; *WAI');
    opc_comp=fscanf(obj1); 
    fwrite(obj1, 'CALC:DATA:FDAT?');
	St = reshape(str2num(fscanf(obj1)), 2, Npts);
    GDref = transpose(St(1, :));
    csvwrite(filenameREF, [fall GDref]);
    
    fprintf(1, 'Sweeping noise calibration\n');
	fwrite(obj1, 'INIT:IMM; *OPC?');
    opc_comp=fscanf(obj1); 
    fwrite(obj1, 'CALC:DATA:FDAT?');
    St = reshape(str2num(fscanf(obj1)), 2, Npts);
    GDcalib = transpose(St(1, :));
    csvwrite(filenameCALIB, [fall GDcalib]);
    
    GDcomp = GDref-GDcalib;
%     GDcomp = medfilt1(GDref-GDcalib, winN);
    [noise sigidx] = max(GDcomp);
    
    subplot(2,1,1)
    plot(fall./1e6, GDref, 'LineWidth',4); 
    xlabel('f [MHz]');
    ylabel('d/df(\angleS)');
    subplot(2,1,2);
    plot(fall./1e6, GDcomp, 'LineWidth',4); 
    xlabel('f [MHz]');
    ylabel('d/df(\angleS/S_R_E_F)');
    text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['noise: ', num2str(noise)]);
    
    reply = input('Try again? y/n: ', 's');
end

close all;

figure('Position',[posWINrb sizeWIN]);
h = cell(4,1);
h{1} = subplot(2,3,1:2);
h{2} = subplot(2,3,4:5);
h{3} = subplot(2,3,3);
h{4} = subplot(2,3,6);
subplot(h{1});
xlabel('time [s]');
ylabel('actual pressure [mmHg]');
hold on;
subplot(h{2});
xlabel('time [s]');
ylabel('f0 [MHz]');
hold on;
subplot(h{3});
xlabel('f [MHz]');
ylabel(siglabel);
subplot(h{4});
xlabel('f [MHz]');
ylabel(siglabel);

ts = [];
vs = [];
GDs = [];
f0s = [];
sigs = [];

fwrite(obj1, 'INIT:CONT 1');
fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');
fprintf(1, 'Press any key to start \n');
w = waitforbuttonpress;
fwrite(obj1, 'INIT:CONT 0');
fprintf(1, 'Starting ... \n');
tstart = clock;
ipres = 1;
Npres = length(values);
while (etime(clock, tstart) < Ntime)
    if (ipres <= Npres && voltages(ipres) < voltRange)
        s.outputSingleScan(voltages(ipres));
        ipres = ipres+1;
    end
    
    realVals = s.inputSingleScan()*presRange/voltRange;
	fwrite(obj1, 'INIT:IMM; *OPC?; *WAI');
    opc_comp=fscanf(obj1); 
    fwrite(obj1, 'CALC:DATA:FDAT?');
    St = reshape(str2num(fscanf(obj1)), 2, Npts);

    GDcur = GDref-transpose(St(1, :));
%     GDcur = medfilt1(GDref-transpose(St(1, :)), winN);
    [sig sigidx] = max(GDcur);
    
    if (sig > sigtol*noise)
        tcur = etime(clock, tstart);
        f0 = fall(sigidx);
        p0 = (f0-fp0)/dfdp;
        
        GDs = [GDs GDcur];
        ts = [ts; tcur;];
        vs = [vs; realVals;];
        f0s = [f0s; f0;];
        ps = [ps; p0;];
        sigs = [sigs; sig;];

        subplot(h{1});
        plot(ts, [vs ps], 'LineWidth',3);
        subplot(h{2});
        plot(ts, f0s./1e6, 'LineWidth',3);
        subplot(h{3});
        plot(fall./1e6, transpose(St(1, :)), 'LineWidth',4); 
        subplot(h{4});
    	plot(fall./1e6, GDcur, 'LineWidth',4); 
        text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['f0: ', num2str(fall(sigidx)/1e6), 'MHz', 10, 'signal: ', num2str(sig)]);

        drawnow expose;
    end
end

setPressure(s, 0);
noises = noise.*ones(size(ts));

csvwrite([folder, '//', pickup_ant, '_', sensor, '_GDrealtime', suffix], [-1 transpose(ts); fall GDs;]);
csvwrite([folder, '//', pickup_ant, '_', sensor, '_GDplots', suffix], [ts vs f0s sigs noises ps]);
% csvwrite([folder, '//', pickup_ant, '_', sensor, '_GDplots', suffix], [ts f0s sigs noises]);

% figure('Position',[posWINrb sizeWIN]);
% subplot(2,1,1);
% plot(ts, vs, 'LineWidth',4);
% xlabel('time [s]');
% ylabel('pressures [mmHg]');
% legend('setting', 'internal', 'external');
% subplot(2,1,2);
% plot(ts, [sigs noises], 'LineWidth',4);
% xlabel('time [s]');
% ylabel(siglabel);
% legend('signal', 'noise');

fwrite(obj1, 'INIT:CONT 1');

clrdevice(obj1);
fclose(obj1);
delete(obj1);
fprintf(1, 'Disconnected from: %s\n', instrinfo);
s.release();
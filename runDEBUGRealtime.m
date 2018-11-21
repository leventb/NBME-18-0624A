clear all;
close all;

nport = 3;
fstart = 0.5e9;
fstop = 2e9;
Npts = 1601;
% Npts = 201;
Ntime = 0.1*60; %seconds
Tsample = 0; %seconds 

folder = '..//07_05_2013';
pickup_ant = 'loop4mm';
sensor = 'realtest';

% sigtol = 1.5;
sigtol = 2;
noise = 0;
winN = 1;

% fp0 = 1.802e9;
% dfdp = -1.3e6;

fp0 = 1.802e9;
dfdp = -1.3e6;

suffix = '.csv';
Z0 = 50;
    
siglabel = 'GDD signal [ns]';
specs = {'-', 'xr', ':k', 'xk'};

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
fwrite(obj1, 'SENS:SWE:TYPE ANAL');
fwrite(obj1, 'SENS:SWE:DEL 0');
fwrite(obj1, 'SENS:SWE:TIME:AUTO 1');
fwrite(obj1, 'INIT:CONT 1');
fwrite(obj1, 'TRIG:SOUR INT');

calibTerms = {'OPEN', 'SHORT', 'LOAD'};
reply = input('Calibrate VNA? y/n: ', 's');
% fwrite(obj1, 'TRIG:SOUR BUS');
while (~strcmp(reply,'n'))
    fwrite(obj1, ['SENS:CORR:COLL:METH:SOLT1 ', num2str(nport)]);    
    for i = 1:length(calibTerms)
        input(['Press enter to sweep ',calibTerms{i},'\n'], 's');
        fwrite(obj1, ['SENS:CORR:COLL:', calibTerms{i}, ' ', num2str(nport)]);
        fwrite(obj1, '*WAI');
    end
    fwrite(obj1, 'SENS:CORR:COLL:SAVE');
    fwrite(obj1, '*WAI');
    reply = input('Try again? y/n: ', 's');
end

% fwrite(obj1, 'TRIG:SOUR INT');
fwrite(obj1, 'CALC:FORM GDEL');
fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');
fwrite(obj1, '*WAI');
        
% flush the buffer
clrdevice(obj1);
fall = transpose(str2num(freq));

scrsz = get(0,'ScreenSize');
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
Hwin = 0.4*scrsz(4);
Wwin = 0.25*scrsz(3);
sizeWINh = [2*Wwin 2*Hwin];
sizeWINv = [Wwin 2*Hwin];
    
filename = [folder, '//', pickup_ant, '_', sensor, '_REF', suffix];

fprintf(1, 'Choose new filename\n');
[reffile, refpath] = uiputfile(filename, 'Save REF File');
prefix = [refpath strrep(strrep(reffile, '.csv', ''), '_REF', '') '_'];

figure('Position',[posWINrb sizeWINv]);

reply = input('New reference? y/n: ', 's');
if (~strcmp(reply,'n'))
    fprintf(1, 'Press any key to sweep\n');
    w = waitforbuttonpress;
%     fwrite(obj1, 'TRIG:SOUR BUS');
    reply = [];
    while (~strcmp(reply,'n'))
        fprintf(1, 'Sweeping reference\n');
%         fwrite(obj1, 'TRIG:SING; *WAI');
        fwrite(obj1, 'CALC:DATA:FDAT?');
        St = reshape(str2num(fscanf(obj1)), 2, Npts);
        GDref = transpose(St(1, :));
        csvwrite([prefix, 'REF', suffix], [fall GDref]);

        fprintf(1, 'Sweeping noise calibration\n');
%         fwrite(obj1, 'TRIG:SING; *WAI');
        fwrite(obj1, 'CALC:DATA:FDAT?');
        St = reshape(str2num(fscanf(obj1)), 2, Npts);
        GDcalib = transpose(St(1, :));
        csvwrite([prefix, 'CALIB', suffix], [fall GDcalib]);

%         GDcomp = GDref-GDcalib;
        GDcomp = medfilt1(GDref-GDcalib, winN);
        [noise sigidx] = max(GDcomp);

        subplot(2,1,1)
        plot(fall./1e6, GDref.*1e9, 'LineWidth',4); 
        xlabel('f [MHz]');
        ylabel('GD [ns]');
        subplot(2,1,2);
        plot(fall./1e6, GDcomp.*1e9, 'LineWidth',4); 
        xlabel('f [MHz]');
        ylabel('GDD signal [ns]');
        text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['noise: ', num2str(noise.*1e9), 'ns']);

        reply = input('Try again? y/n: ', 's');
    end
else
    fprintf(1, 'Choose existing REF file\n');
    reply = [];
    while (~strcmp(reply,'n'))
        [oldfile, oldpath] = uigetfile([refpath '*.csv'], 'Open Existing File');
        oldprefix = [oldpath strrep(strrep(oldfile, '.csv', ''), '_REF', '') '_'];

        ref = csvread([oldprefix, 'REF', suffix]);
        fref = ref(:, 1);
        GDref = ref(:, 2);
        
        calib = csvread([oldprefix, 'CALIB', suffix]);
        fcalib = calib(:, 1);
        GDcalib = calib(:, 2);  
        
        if (max(abs(fall-fref)) > 1e-4*fall(end) || max(abs(fall-fcalib)) > 1e-4*fall(end))
            fprintf(1, 'Frequencies do not match');
            reply = [];
            continue;
        end
        
%     GDcomp = GDref-GDcalib;
        GDcomp = medfilt1(GDref-GDcalib, winN);
        [noise sigidx] = max(GDcomp);
        
        subplot(2,1,1)
        plot(fall./1e6, GDref.*1e9, 'LineWidth',4); 
        xlabel('f [MHz]');
        ylabel('GD [ns]');
        subplot(2,1,2);
        plot(fall./1e6, GDcomp.*1e9, 'LineWidth',4); 
        xlabel('f [MHz]');
        ylabel('GDD signal [ns]');
        text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['noise: ', num2str(noise.*1e9), 'ns']);
        
        reply = input('Try again? y/n: ', 's');
    end
    
    if (~strcmp(oldprefix, prefix))
        copyfile([oldprefix, 'REF', suffix], [prefix, 'REF', suffix]);
        copyfile([oldprefix, 'CALIB', suffix], [prefix, 'CALIB', suffix]);
    end
end

notdone = true;
irun = 1;
t0 = clock;
while (notdone)
%     fwrite(obj1, 'TRIG:SOUR INT');
    reply = input('Zero pressure? y/n: ', 's');
%     fwrite(obj1, 'TRIG:SOUR BUS');
    while (~strcmp(reply,'n'))
        fprintf(1, 'Sweeping zero pressure\n');

%         fwrite(obj1, 'TRIG:SING; *WAI');
        fwrite(obj1, 'CALC:DATA:FDAT?');
        St = reshape(str2num(fscanf(obj1)), 2, Npts);

        GDzero = transpose(St(1, :));
        csvwrite([prefix, 'ZERO', suffix], [fall GDzero]);

    %     GDcomp = GDref-GDzero;
        GDcomp = medfilt1(GDref-GDzero, winN);
        [sig sigidx] = max(GDcomp);

        if (sig > sigtol*noise)
            fp0 = fall(sigidx);

            subplot(2,1,1)
            plot(fall./1e6, GDref.*1e9, 'LineWidth',4); 
            xlabel('f [MHz]');
            ylabel('GD [ns]');
            subplot(2,1,2);
            plot(fall./1e6, GDcomp.*1e9, 'LineWidth',4); 
            xlabel('f [MHz]');
            ylabel('GDD signal [ns]');
            text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['f0: ', num2str(fp0/1e6), 'MHz', 10, 'signal: ', num2str(sig.*1e9, 3), 'ns']);
            hold on;
            plot(fp0./1e6, sig.*1e9, 'ok','MarkerSize',10);
            plot(xlim, [noise noise].*1e9, ':k', 'LineWidth',4);
            hold off;
        else
            fprintf(1, 'No signal!\n'); 
        end
        t0 = clock;

        reply = input('Try again? y/n: ', 's');
    end
    
    close all;

    figure('Position',[posWINrb sizeWINh]);
    h = cell(3,1);
    h{1} = subplot(2,3,1:2);
    h{2} = subplot(2,3,3);
    h{3} = subplot(2,3,4:5);
    subplot(h{1});
    xlabel('time [s]');
    ylabel('f0 [MHz]');
    hold on;
    subplot(h{3});
    xlabel('time [s]');
    ylabel('pressure [mmHg]');
    hold on;

    ts = [];
    GDs = [];
    
    t0s = [];
    f0s = [];
    sigs = [];
    ps = [];

    fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');
    fwrite(obj1, '*WAI');

%     fwrite(obj1, 'TRIG:SOUR INT');
    fprintf(1, 'Press any key to start \n');
    w = waitforbuttonpress;
%     fwrite(obj1, 'TRIG:SOUR BUS');
    fprintf(1, 'Starting ... \n');
    tstart = clock;
    while (etime(clock, tstart) < Ntime)
%         fwrite(obj1, 'TRIG:SING; *WAI');
        fwrite(obj1, 'CALC:DATA:FDAT?');
        St = reshape(str2num(fscanf(obj1)), 2, Npts);
        GDcur = transpose(St(1, :));
%         GDcomp = GDref-GDcur;
        GDcomp = medfilt1(GDref-GDcur, winN);
        [sig sigidx] = max(GDcomp);
%         tcur = etime(clock, tstart);
        tcur = etime(clock, t0);
        ts = [ts; tcur;];

        if (sig > sigtol*noise)
            f0 = fall(sigidx);
            f0s = [f0s; f0;];
            t0s = [t0s; tcur;];
            sigs = [sigs; sig;];

            subplot(h{1});
            plot(t0s, f0s./1e6, 'LineWidth',3);

            subplot(h{2});
            plot(fall./1e6, GDcomp.*1e9, 'LineWidth',4); 
            text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['f0: ', num2str(f0/1e6), 'MHz', 10, 'signal: ', num2str(sig.*1e9), 'ns']);
            xlabel('f [MHz]');
            ylabel(siglabel);
            hold on;
            plot(f0./1e6, sig.*1e9, 'ok','MarkerSize',10);
            plot(xlim, [noise noise].*1e9, ':k', 'LineWidth',4);
            hold off;
                    
            ps = [ps; (f0-fp0)/dfdp;];

            subplot(h{3});
            plot(t0s, ps, 'LineWidth',3);

            drawnow expose;
        end
        GDs = [GDs GDcur];
    end

    noises = noise.*ones(size(t0s));

    csvwrite([prefix 'GDrealtime' suffix], [-1 transpose(ts); fall GDs;]);
    csvwrite([prefix  'GDplots' suffix], [t0s f0s sigs noises ps]);
    
    notdone = ~strcmp(input('Another run? y/n: ', 's'),'n');

    if (notdone)
        irun = irun+1;
        oldprefix = prefix;

        [reffile, refpath] = uiputfile([oldprefix(1:end-1) num2str(irun) '_REF' suffix], 'Choose new filename');
        prefix = [refpath strrep(strrep(reffile, '.csv', ''), '_REF', '') '_'];

        if (~strcmp(oldprefix, prefix))
            copyfile([oldprefix, 'REF', suffix], [prefix, 'REF', suffix]);
            copyfile([oldprefix, 'CALIB', suffix], [prefix, 'CALIB', suffix]);
        end
    end
end

% fwrite(obj1, 'TRIG:SOUR INT');

clrdevice(obj1);
fclose(obj1);
delete(obj1);
fprintf(1, 'Disconnected from: %s\n', instrinfo);
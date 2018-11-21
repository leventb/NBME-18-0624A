clear all;
close all;

% nport is port number
nport = 3;
fstart = 0.5e9;
fstop = 2e9;
% fstart = 1.25e9;
% fstop = 2.75e9;
% fstart = 2.5e9;
% fstop = 4e9;
% fstart = 4e9;
% fstop = 7e9;
Npts = 1601;

% fint = [0 2].*1e9;
fint = [0 8.5].*1e9;
folder = '..//07_05_2013';
pickup_ant = 'loop4mm';
values = (1:3)';
% values = [1 2 3 4 5]';
parameter = 'Device Number';
unit = '#';
% parameter = 'sensor';
% unit = '';
% parameter = 'temperature';
% unit = 'C';
sensor = 't';

useAverage = true;
Nsamples = 10;
Tdelay = 0.1;

Nsens = 1;

useRef = true;
% sigType = 'Z';
% resType = 'spl0';
sigType = 'S';
resType= 'dph1'; 
% resType= 'pmh0'; 
plotType = 'n';

dBdiff = 3;
if (resType(1)== 'p')
    dBdiff = 6;
end

winN = 19;
resN = 1;

% sigtol = 1.5;
sigtol = 0;
Qtolmin = 2;
Qtolmax = 1e6;
noise = 0;
suffix = '.csv';
Z0 = 50;
tests = cellstr(strcat(num2str(values), unit));
Ntests = length(tests);

vlim = [min(values)  max(values)];
vlabel = [parameter, ' [', unit, ']'];
siglabel = ['signal in ', partTypeLabel(resType, sigType, plotType)];
specs = {'x', 'xr', ':k', 'xk'};
f0s = zeros(Ntests, 1);
sigs = zeros(Ntests, 1);
Qs = zeros(Ntests, 1);
bases = zeros(Ntests, 1);

startVNAConnection;
fwrite(obj1, 'INIT:CONT 1');
setupVNA;
fall = transpose(str2num(freq));

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
    fprintf('fint not in range');
    return
end

filenameREF = [folder, '//', pickup_ant, '_', sensor, '_REF', suffix];
filenameCALIB = [folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix];

setupPlot;

fprintf(1, 'Press any key to sweep REF\n');
w = waitforbuttonpress;
fwrite(obj1, 'INIT:CONT 0');
reply = [];
while (~strcmp(reply,'n'))
    timeSweep;
    Xref = processSweep(sweep, Npts, Nsamples, useAverage);
    saveSweep(filenameREF, tall, fall, Xref, useAverage);
    if (strcmp(sigType, 'Z'))
        Xref = Z0.*(1+Xref)./(1-Xref);
    end

    plotSweep (h(1:2), {'', ''}, fall, Xref, sigType, plotType, resType, [], [], [], winN);
    
    fprintf(1, 'Calibrating ...\n');
    timeSweep;    
    Xall = processSweep(sweep, Npts, Nsamples, useAverage);
    saveSweep(filenameCALIB, tall, fall, Xall, useAverage);

    Xcomp = applyRef(Xall, Xref, resType(1));
    [f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, dBdiff);
    plotSweep (h(3:4), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);

	reply = input('Try again? y/n: ', 's');
end
noise = sig;

fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');
fprintf(1, 'Press any key to start\n');
w = waitforbuttonpress;

for itest=1:Ntests
    fwrite(obj1, 'INIT:CONT 1');
    
    filename = [folder, '//', pickup_ant, '_', sensor, '_', num2str(values(itest)), unit, suffix];
    fprintf(1, ['Press any key to sweep ' tests{itest} '\n']);
    w = waitforbuttonpress;

    fwrite(obj1, 'INIT:CONT 0');
    reply = [];
    while (~(strcmp(reply,'n') || strcmp(reply,'q')))
        timeSweep;
        Xall = processSweep(sweep, Npts, Nsamples, useAverage);
        saveSweep(filename, tall, fall, Xall, useAverage);
        if (strcmp(sigType, 'Z'))
            Xall = Z0.*(1+Xall)./(1-Xall);
        end

        plotSweep (h(1:2), {'', ''}, fall, [Xall Xref], sigType, ' ', [' ' resType(2) '  '], [], [], [], winN);

        Xcomp = applyRef(Xall, Xref, resType(1));
        
        if (Nsens > 1)
            [f0 sig Q base] = calcMultiRes(fall(fidx), Xcomp(fidx), resType, resN, winN, dBdiff, Nsens, sigtol*noise);
        else
            [f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, dBdiff);
        end
        plotSweep (h(3:4), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);
                
        reply = input('Try again? y/n (q to end): ', 's');
    end
    
    f0s(itest) = f0;
    sigs(itest) = sig;
    Qs(itest) = Q;
    bases(itest) = base;
    
    if(strcmp(reply,'q'))
        break;
    end
end

[vs f0s sigs Qs bases noises] = cleanSigs(values, f0s, sigs, Qs, bases, noise, sigtol, Qtolmin, Qtolmax);

setupSeqPlot;
viewSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabel, 'g', specs);
csvwrite([folder, '//', pickup_ant, '_', sensor, '_', sigType, resType, '_PLOTS', suffix], [vs f0s sigs Qs bases noises]);

fwrite(obj1, 'INIT:CONT 1');
endVNAConnection;

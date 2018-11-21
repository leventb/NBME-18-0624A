clear all;
close all;

nport = 3;
fstart = 5e8;
fstop = 1e9;
Npts = 1601;
Ntime = 1*60; %seconds
Tsample = 0; %seconds 

fint = [5 10].*1e8;
% fint = [2 6].*1e9;
folder = '2017_06_20';
pickup_ant = '10mmLoop';
sensor = input('Sensor Name:');

sigType = 'S';
% resType= 'smh0'; 
resType= 'dpl1'; 
plotType = 'n';

Nsamples = 1;
Ncalib = 1;

winN = 0;
resN = 1;

sigtol = 1.5;
Qtolmin = 2;
Qtolmax = 1000;
noise = 0;

suffix = '.csv';
Z0 = 50;

siglabel = ['signal in ', partTypeLabel(resType, sigType, plotType)];
specs = {'-', 'xr', ':k', 'xk'};

startVNAConnection;
setupVNA;
fall = transpose(str2num(freq));

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
    fprintf('fint not in range');
    return
end

setupRealtimePlot;

Tdelay = 0;

filenameREF = [folder, '\', pickup_ant, '_', sensor, '_REF', suffix];
fprintf(1, 'Press any key to sweep REF\n');
w = waitforbuttonpress;
reply = [];
while (~strcmp(reply,'n'))
    timeSweep;    
    Xref = processSweep(sweep, Npts, Nsamples, true);
    saveSweep(filenameREF, tall, fall, Xref, true);

    plotSweep (h(1:2), {'', ''}, fall, Xref, sigType, plotType, resType, [], [], [], winN);
	reply = input('Try again? y/n: ', 's');
end

fprintf(1, 'Calibrating ...\n');
noise = 0;
for i=1:Ncalib
    filenameCALIB = [folder, '\', pickup_ant, '_', sensor, '_CALIB', num2str(i), suffix];

    timeSweep;    
    Xcur = processSweep(sweep, Npts, Nsamples, true);
    %saveSweep(filenameCALIB, tall, fall, Xref, true);

    Xcomp = applyRef(Xcur, Xref, resType(1));
  	[f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, 3);
    noise = max(sig, noise);
end
plotSweep (h(1:2), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);
    
ts = [];
Xs = [];
f0s = [];
sigs = [];
Qs = [];
bases = [];

fprintf(1, 'Press any key to start \n');
w = waitforbuttonpress;
fprintf(1, 'Starting ... \n');
tstart = clock;
while (etime(clock, tstart) < Ntime)
    timeSweep;
    Xcur = processSweep(sweep, Npts, Nsamples, true);

	Xcomp = applyRef(Xcur, Xref, resType(1));
  	[f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, 3);
	
    if (~isempty(f0))% && (Q > Qtolmin) && (Q < Qtolmax) && (sig > sigtol*noise))
        tcur = etime(clock, tstart);
        Xs = [Xs Xcur];
        ts = [ts; tcur;];
        f0s = [f0s; f0;];
        sigs = [sigs; sig;];
        Qs = [Qs; Q;];
        bases = [bases; base;];
        
        plotSweep (h(1:2), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);

        subplot(h{3});
        plot(ts, f0s./1e6, '-', 'MarkerSize',12,'LineWidth',3);
        hold on;
        drawnow expose;
    end
end

csvwrite([folder, '\', pickup_ant, '_', sensor, '_REALTIME', suffix], [-1 transpose(ts); fall Xs;]);

% [vs f0s sigs Qs bases noises] = cleanSigs(values, f0s, sigs, Qs, bases, noise, sigtol, Qtolmin, Qtolmax);
noises = noise.*ones(size(ts));
    
setupSeqPlot;
viewSeq(h, ts, f0s, sigs, Qs, bases, noises, [0 max(ts)], 'time [s]', siglabel, plotType, specs);
csvwrite([folder, '\', pickup_ant, '_', sensor, '_', sigType, resType, '_PLOTS', suffix], [ts f0s sigs Qs bases noises]);
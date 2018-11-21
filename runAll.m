clear all;
close all;

nport = 3;
fstart = 0.1e9;
fstop = 2e9;
Npts = 1601;
fint = [0.1 2].*1e9;

folder = '..//02_21_2013';
pickup_ant = 'loop4mm';
sensor = 'test';

useAverage = true;
Nsamples = 10;
Tdelay = 0;

useRef = false;
useS = true;
resTypeS= 'dml0'; 
plotTypeS = 'n';
useZ = true;
resTypeZ= 'sph0';
plotTypeZ = 'n';

suffix = '.csv';
Z0 = 50;

filename = [folder, '//', pickup_ant, '_', sensor, '_ALL', suffix];

Sref = [];
Zref = [];
if (useRef)
    ref = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
    tref = ref{1};
    fref = ref{2};
    Sref = ref{3};
    Zref = Z0.*(1+Sref)./(1-Sref);
    
    calib = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
    tcalib = calib{1};
    fcalib = calib{2};
    Scalib = calib{3};
    Zcalib = Z0.*(1+Scalib)./(1-Scalib);

    if (abs(sum(fcalib-fref)) > 1e-4)
        fprintf(1, 'Calibration and reference frequencies do not match');
        return;
    end
    
    fstart = fref(1);
    fstop = fref(end);
    Npts = length(fref);
end

startConnection;
setupTest;
fall = transpose(str2num(freq));

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
    fprintf('fint not in range');
    return
end

timeSweep;
Sall = processSweep(sweep, Npts, Nsamples, useAverage);
saveSweep(filename, tall, fall, Sall, useAverage);
Zall = Z0.*(1+Sall)./(1-Sall);

if (useS)
    Scomp = applyRef(Scalib, Sref, resTypeS(1), winN);
    [f0_S noise_S Q_S base_S] = calcRes(Scomp, fall, fidx, resTypeS, resN, 3);

    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Sall Sref], 'S', ' ', [' ' resTypeS(2) '  '], [], [], []);

    if (useRef)
        Scomp = applyRef(Sall, Sref, resTypeS(1), 0);
        [f0_S sig_S Q_S base_S] = calcRes(Scomp, fall, fidx, resTypeS, 0);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Scomp(fidx), 'S', plotTypeS, resTypeS, f0_S, sig_S, Q_S);
    end
end
if (useZ)
	Zcomp = applyRef(Zcalib, Zref, resTypeZ(1), winN);
    [f0_Z noise_Z Q_Z base_Z] = calcRes(Zcomp, fall, fidx, resTypeZ, resN, 3);

    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Zall Zref], 'Z', plotTypeZ, [' ' resTypeZ(2) '  '], [], [], []);
    
    if (useRef)
        Zcomp = applyRef(Zall, Zref, resTypeZ(1));
        [f0_Z sig_Z Q_Z base_Z] = calcRes(Zcomp, fall, fidx, resTypeZ, 0);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Zcomp(fidx), 'Z', plotTypeZ, resTypeZ, f0_Z, sig_Z, Q_Z);
    end
end

endConnection;
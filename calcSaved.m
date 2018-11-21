clear all;
% close all;

fint = [0 8.5].*1e9;
folder = '..//02_22_2013';
pickup_ant = 'loop4mm';
sensor = 'water_0d06MNaCl';
% test = '1mm';
% test = 'SBS4x4';
test = 'S50-100_ind2x_3x3';

useRef = true;
useS = true;
resTypeS = 'smh0';
% resTypeS = 'dph1';
plotTypeS = 'n';
useZ = true;
resTypeZ = 'oph0';
plotTypeZ = 'n';

resN = 1;
winN = 29;

suffix = '.csv';
Z0 = 50;

all = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_', test, suffix]);
tall = all{1};
fall = all{2};
Sall = all{3};
Zall = Z0.*(1+Sall)./(1-Sall);

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
    fprintf('fint not in range');
    return
end

Sref = [];
Zref = [];
if (useRef)
    ref = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_REF', suffix]);
    tref = ref{1};
    fref = ref{2};
    Sref = ref{3};
    Zref = Z0.*(1+Sref)./(1-Sref);

    calib = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
    tcalib = calib{1};
    fcalib = calib{2};
    Scalib = calib{3};
    Zcalib = Z0.*(1+Scalib)./(1-Scalib);

    if (abs(sum(fref-fall)) > 1e-4)
        fprintf(1, 'Data and reference frequencies do not match');
        return;
    end
    if (abs(sum(fcalib-fall)) > 1e-4)
        fprintf(1, 'Data and calibration frequencies do not match');
        return;
    end
end

if (useS)
    Scomp = applyRef(Scalib, Sref, resTypeS(1));
    [f0_S noise_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, 3);

    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Sall Sref], 'S', ' ', [' ' resTypeS(2) '  '], [], [], [], winN);

    if (useRef);
        Scomp = applyRef(Sall, Sref, resTypeS(1));
        [f0_S sig_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, 3);
%         plotSweep (h(3:4), {'', ''}, fall(fidx), Scomp(fidx, :), 'S',
%         plotTypeS, resTypeS, f0_S, sig_S, Q_S, winN);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Scomp(fidx, :), 'S', plotTypeS, resTypeS, [], [], [], winN);
    end
end
if (useZ)
	Zcomp = applyRef(Zcalib, Zref, resTypeZ(1));
    [f0_Z noise_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, 3);

    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Zall Zref], 'Z', plotTypeZ, [' ' resTypeZ(2) '  '], [], [], [], winN);
    
    if (useRef)
        Zcomp = applyRef(Zall, Zref, resTypeZ(1));
        [f0_Z sig_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, 3);
%         plotSweep (h(3:4), {'', ''}, fall(fidx), Zcomp(fidx, :), 'Z',
%         plotTypeZ, resTypeZ, f0_Z, sig_Z, Q_Z, winN);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Zcomp(fidx, :), 'Z', plotTypeZ, resTypeZ, [], [], [], winN);
    end
end

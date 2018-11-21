clear all;
% close all;

% fint = [2.5 3.5].*1e9;
fint = [0 8.5].*1e9;
% folder = '..//02_22_2013';
% folder = '..//02_23_2013';
% folder = '..//02_24_2013';
% folder = '..//03_17_2013';
folder = '..//03_31_2013';
% folder = '..//05_19_2013';
pickup_ant = 'loop4mm';
% values = (2:3:11)';
values = [5 6]';
% values = (8)';
parameter = 'separation';
unit = 'mm';
% parameter = 'sensor_v2';
% values = [1 2 3 4]';
% unit = '';
% values = [0, 5, 10, 15, 20, 25]';
% parameter = 'pressure';
% unit = 'psi';

% sensor = 'S50-100_ind2x_3x3_afterpig_sealed_tube';
% sensor = 'S50-100_ind2x_3x3_pig_on_sealed_tube';
% sensor = 'S50-100_ind2x_3x3_sealed_tube';
% sensor = 'SBS_ind2x_4x4_afterpig_sealed_tube';
% sensor = 'SBS_ind2x_4x4_pig_on_sealed_tube';
% sensor = 'S50-100_ind1d5x_series';
% sensor = 'S50-100_ind1d5x_3x3_sealed_tube';
% sensor = 'S50-100_ind2x_2x2_batch2_sealed_tube';
% sensor = 'Snone_ind1d25x_4x4_sealed_tube';
% sensor = 'S50-100_ind2d5x_3x3_sealed_tube';
% sensor = 'S50-100_ind2d5x_series';
% sensor = 'S50-100_ind2x_2x2_array';
% sensor = 'S50-100_ind2x_2x2_array';
% sensor = '2x2_array_single';
% sensor = 'S50-100_pu_ind2x_1d5x1d5_v2';
% sensor = 'S50-100_SBS_ind2x_4x4_s2';
% sensor = 'S50-100_SBS_ind2x_4x4_champ_v3';
sensor = 'S50-100_SBS_ind2x_4x4_champ_midwater';
% sensor = 'S50-100_SBS_ind2x_4x4_champ_water';
% sensor = 'test_array';
% sensor = 'ind2x_4x4_s2';

useRef = true; 
useS = true;
% resTypeS= 'dph1';
resTypeS= 'pmh0';
% resTypeS= 'smh0';
plotTypeS = 'n';
useZ = false;
% useZ = false;
% resTypeZ= 'oph0';
resTypeZ= 'srh0';
plotTypeZ = 'n';

Nsens = 1;

winN = 19;
resN = 1;

dBdiffS = 3;
dBdiffZ = 3;
if (resTypeS(1)== 'p')
    dBdiffS = 6;
end
if (resTypeZ(1)== 'p')
    dBdiffZ = 6;
end

sigfactorS = 1;
sigfactorZ = 1;
if (strcmp(resTypeS, 'dph1'))
	sigfactorS = 1e9;
end
if (strcmp(resTypeZ, 'dph1'))
	sigfactorZ = 1e9;
end

sigtol = 0;
Qtolmin = 0;
Qtolmax = 0;
suffix = '.csv';
PLOTsuffix = '_PLOTS.csv';
Z0 = 50;
tests = cellstr(strcat(num2str(values), unit));
Ntests = length(tests);
    
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
    
    if (abs(sum(fcalib-fref)) > 1e-4)
        fprintf(1, 'Calibration and reference frequencies do not match');
        return;
    end
end

Stests = [];
Ztests = [];
for i=1:Ntests
    all = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_', num2str(values(i)), unit, suffix]);
    tall = all{1};
    fall = all{2};
    Sall = all{3};
    Zall = Z0.*(1+Sall)./(1-Sall);

    if (abs(sum(fall-fref)) > 1e-4);
        fprintf(1, 'Data and reference frequencies do not match');
    end

    Stests = [Stests Sall];
    Ztests = [Ztests Zall];

    vlim = [min(values)  max(values)];
    vlabel = [parameter, ' [', unit, ']'];
    siglabelS = ['signal in ', partTypeLabel(resTypeS, 'S', plotTypeS)];
    siglabelZ = ['signal in ', partTypeLabel(resTypeZ, 'Z', plotTypeZ)];
    specs = {'x', 'xr', ':k', 'xk'};
end

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
	fprintf('fint not in range');
    return
end

if (useS)
    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Stests Sref], 'S', ' ', [' ' resTypeS(2) '  '], [], [], [], winN);

    if (useRef)
        Scomp = applyRef(Scalib, Sref, resTypeS(1));
        [f0_S noise_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS);

        Scomp = applyRef(Stests, Sref, resTypeS(1));
        if (Nsens > 1)
            [f0_S sig_S Q_S base_S] = calcMultiRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS, Nsens, sigtol*noise_S);
        else
            [f0_S sig_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS);
        end
        
        plotSweep (h(3:4), {'', ''}, fall(fidx), Scomp(fidx, :), 'S', plotTypeS, resTypeS, f0_S, sig_S, [], winN);
        [vs f0s sigs Qs bases noises] = cleanSigs(values, f0_S, sig_S, Q_S, base_S, noise_S, sigtol, Qtolmin, Qtolmax);

%         plotSweepPart(h{1}, '', fall(fidx), Scomp(fidx, :), 'S', plotTypeS, resTypeS, '', winN);
%         legend ('0psi', '5psi', '10psi', '15psi', '20psi', '25psi');
% %         ylim([0 8e-3]);

        setupSeqPlot;
        viewSeq(h, vs, f0s, sigs.*sigfactorS, Qs, bases, noises, vlim, vlabel, siglabelS, plotTypeS, specs);
        csvwrite([folder, '//', pickup_ant, '_', sensor, '_S', resTypeS, PLOTsuffix], [vs f0s sigs Qs bases noises]);
    end
end
if (useZ)
    setupPlot;
    plotSweep (h(1:2), {'', ''}, fall, [Ztests Zref], 'Z', ' ', [' ' resTypeZ(2) '  '], [], [], [], winN);
    
    if (useRef)
        Zcomp = applyRef(Zcalib, Zref, resTypeZ(1));
        [f0_Z noise_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ);

        Zcomp = applyRef(Ztests, Zref, resTypeZ(1));
        if (Nsens > 1)
            [f0_Z sig_Z Q_Z base_Z] = calcMultiRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ, Nsens, sigtol*noise_Z);
        else
            [f0_Z sig_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ);
        end
        
        plotSweep (h(3:4), {'', ''}, fall(fidx), Zcomp(fidx, :), 'Z', plotTypeZ, resTypeZ, f0_Z, sig_Z, [], winN)
        [vs f0s sigs Qs bases noises] = cleanSigs(values, f0_Z, sig_Z, Q_Z, base_Z, noise_Z, sigtol, Qtolmin, Qtolmax);
        
%         plotSweepPart(h{3}, '', fall(fidx), Zcomp(fidx, :), 'Z', plotTypeZ, resTypeZ, '', winN);
%         legend ('0psi', '5psi', '10psi', '15psi', '20psi', '25psi');
%         ylim([-2 12].*1e-3);
        
        setupSeqPlot;
        viewSeq(h, vs, f0s, sigs.*sigfactorZ, Qs, bases, noises, vlim, vlabel, siglabelZ, plotTypeZ, specs);
        csvwrite([folder, '//', pickup_ant, '_', sensor, '_Z', resTypeZ, PLOTsuffix], [vs f0s sigs Qs bases noises]);
    end
end
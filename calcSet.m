clear all;
close all;

fint = [0.1 2].*1e9;
% folder = '01_17_2013';
folder = '01_21_2013';
% folder = '01_27_2013';
% sensor = 'dummy_3x3_0d5pF_400um_air';
% sensor = 'S50_sand_3x3_air';
% sensor = 'S200_sand_6x6_air';
% sensor = 'S100_ind3x_3x3_air';
% sensor = 'S100_ind3x_2x2_sealed_air';
% sensor = 'S100_ind2x_1d5x1d5_air_v2';
prefix = 'loop4mm';
sensors = {'dummy_3x3_0d5pF_200um_air',...
    'dummy_4x4_0d5pF_200um_air',...
    'dummy_5x5_0d5pF_200um_air',...
    'S200_sand_3x3_air','S50_sand_3x3_air',...
    'S200_sand_6x6_air', 'S50_sand_6x6_air',...
    'S100_ind3x_4x4_air','S100_ind3x_3x3_air','S100_ind3x_2x2_air',...
    'S100_ind2x_2x2_air', 'S100_ind2x_1d5x1d5_air'};
value = '3mm';
tests = {'dummy (0.5pF) 3x3', 'dummy (0.5pF) 4x4', 'dummy (0.5pF) 5x5',...
    'S200 sand 3x3', 'S50 sand 3x3', 'S200 sand 6x6', 'S50 sand 6x6',...
	'S100 ind3x 4x4','S100 ind3x 3x3','S100 ind2x 2x2',...
    'S100 ind2x 2x2', 'S100 ind2x 1.5x1.5'};
Ntests = length(tests);

useRef = false;
% sigType = 'Z';
% resType = 'dph1';
sigType = 'S';
resType= 'smh0'; 
plotType = 'n';

winN = 50;
resN = 1;
sigtol = 0;
suffix = '.csv';
Z0 = 50;

specs = {   '-k', '--k', ':k', '-', '--', ':', '-.','-m', '--m', ':m','--r', ':r';
            '-k', '--k', ':k', '-', '--', ':', '-.','-m', '--m', ':m','--r', ':r';};
scrsz = get(0,'ScreenSize');
Nplotm = 1;
if (useRef)
    Nplotm = 2*Nplotm;
end
Hwin = 0.35*scrsz(4)*Nplotm;
Wwin = 0.75*scrsz(3);
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
sizeWIN = [Wwin Hwin];

h = cell(Nplotm,1);
figure('Position',[posWINrb sizeWIN]);
for i=1:Nplotm
    h{i} = subplot(Nplotm,1,i);
end

for i=1:Ntests
    all = recallSavedSweep([folder, '//', prefix, '_', sensors{i}, '_', value, suffix]);
    tall = all{1};
    fall = all{2};
    Xall = all{3};
    if (strcmp(sigType, 'Z'))
        Xall = Z0.*(1+Xall)./(1-Xall);
    end

    Xref = [];
    if (useRef)
        ref = recallSavedSweep([folder, '//', prefix, '_', sensor{i}, '_REF', suffix]);
        tref = ref{1};
        fref = ref{2};
        Xref = ref{3};

        calib = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
        tcalib = calib{1};
        fcalib = calib{2};
        Xcalib = calib{3};

        if (strcmp(sigType, 'Z'))
            Xref = Z0.*(1+Xref)./(1-Xref);
            Xcalib = Z0.*(1+Xcalib)./(1-Xcalib);
        end
        if (abs(sum(fall-fref)) > 1e-4);
            fprintf(1, 'Data and reference frequencies do not match');
        end
        if (abs(sum(fcalib-fall)) > 1e-4)
            fprintf(1, 'Data and calibration frequencies do not match');
            return;
        end
    end

	plotSweepPart(h{1}, specs{1, i}, fall, [Xall Xref], sigType, plotType, [' ' resType(2) '  '], [], [], [], winN)
            
    if (useRef)
        fidx = find((fall>fint(1))&(fall<fint(2)));
        if (isempty(fidx))
            fprintf('fint not in range');
            return
        end
        Xcomp = applyRef(Xcalib, Sref, resTypeS(1));
        [f0s noise Qs bases] = calcRes(fall(fidx), Xcomp(fidx, :), resType, resN, winN, dBdiff);

        Xcomp = applyRef(Xall, Xref, resType(1));

        if (Nsens > 1)
            [f0s sigs Qs bases] = calcMultiRes(fall(fidx), Xcomp(fidx, :), resType, resN, winN, dBdiff, Nsens, sigtol*noise);
        else
            [f0s sigs Qs bases] = calcRes(fall(fidx), Xcomp(fidx, :), resType, resN, winN, dBdiff);
        end
                
        plotSweepPart(h{2}, specs{2, i}, fall(fidx), Xcomp(fidx), sigType, plotType, [' ' resType(2) '  '], f0s, sigs, [], winN)
    end
end

legend(tests);


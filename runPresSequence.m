clear all;
close all;

nport = 3;
fstart = 0.5e9;
fstop = 2e9;
Npts = 1601;

fint = [0 8.5].*1e9;
folder = '..//07_05_2013';
pickup_ant = 'loop4mm';
sensor = 'oldsensor';
values = (0:10:100)'; % mmHg
% values = [0 10 20 30 40 50]'; % mmHg
parameter = 'pressure';
% unit = 'psi';
unit = 'mmHg';

Nsens = 1;

Ndir = 1;
autoSequence = true;
useAverage = true;
Nsamples = 10;
Tdelay = 0.1;
Twait = 10;

useRef = true;
% sigType = 'Z';
% resType = 'spl0';
sigType = 'S';
% dph1 used in saline and tissue (group delay method)
% resType= 'dph1'; 
% pmh0 used in air, and gives correct Q (power reflection method)
resType= 'pmh0'; 
plotType = 'n';

winN = 19;
resN = 1;

dBdiff = 3;
if (resType(1)== 'p')
    dBdiff = 6;
end
sigfactor = 1;
if (strcmp(resType, 'dph1'))
	sigfactor = 1e9;
end

sigtol = 1.5;
Qtolmin = 0;
Qtolmax = 0;
noise = 0;
suffix = '.csv';
Z0 = 50;
presRange = 15;
if (strcmp(unit, 'mmHg'))
    presRange = presRange*51.7149;
end
voltRange = 10;

if (Ndir > 1)
    values = [values; flipdim(values, 1);];
end
voltages = values.*(voltRange/presRange); %V

tests = cellstr(strcat(num2str(values), unit));
Ntests = length(tests);

siglabel = ['signal in ', partTypeLabel(resType, sigType, plotType)];
specs = {'x', 'xr', ':k', 'xk'};
vs = zeros(Ntests, 2);
f0s = zeros(Ntests, 1);
sigs = zeros(Ntests, 1);
Qs = zeros(Ntests, 1);
bases = zeros(Ntests, 1);

startVNAConnection;
fwrite(obj1, 'INIT:CONT 1');
setupVNA;
startNIConnection;
fall = transpose(str2num(freq));

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
    fprintf('fint not in range');
    return
end

filename = [folder, '//', pickup_ant, '_', sensor, '_REF', suffix];

fprintf(1, 'Choose new filename\n');
[reffile, refpath] = uiputfile(filename, 'Save REF File');
prefix = [refpath strrep(strrep(reffile, '.csv', ''), '_REF', '') '_'];

setupPlot;
    
reply = input('New reference? y/n: ', 's');
if (~strcmp(reply,'n'))        
    fprintf(1, 'Press any key to sweep REF\n');
    w = waitforbuttonpress;
    fwrite(obj1, 'INIT:CONT 0');
    reply = [];
    while (~strcmp(reply,'n'))
        timeSweep;
        Xref = processSweep(sweep, Npts, Nsamples, useAverage);
        saveSweep([prefix, 'REF', suffix], tall, fall, Xref, useAverage);
        if (strcmp(sigType, 'Z'))
            Xref = Z0.*(1+Xref)./(1-Xref);
        end

        plotSweep (h(1:2), {'', ''}, fall, Xref, sigType, plotType, resType, [], [], [], winN);

        fprintf(1, 'Calibrating ...\n');
        timeSweep;    
        Xall = processSweep(sweep, Npts, Nsamples, useAverage);
        saveSweep([prefix, 'CALIB', suffix], tall, fall, Xall, useAverage);
        if (strcmp(sigType, 'Z'))
            Xall = Z0.*(1+Xall)./(1-Xall);
        end
        
        Xcomp = applyRef(Xall, Xref, resType(1));
        [f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, dBdiff);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);

        reply = input('Try again? y/n: ', 's');
    end
else
    fprintf(1, 'Choose existing REF file\n');
    reply = [];
    while (~strcmp(reply,'n'))
        [oldfile, oldpath] = uigetfile([refpath '*.csv'], 'Open Existing File');
        oldprefix = [oldpath strrep(strrep(oldfile, '.csv', ''), '_REF', '') '_'];

        ref = recallSavedSweep([oldprefix, 'REF', suffix]);
        fref = ref{2};
        Xref = ref{3};
        if (strcmp(sigType, 'Z'))
            Xref = Z0.*(1+Xref)./(1-Xref);
        end
        
        calib = recallSavedSweep([oldprefix, 'CALIB', suffix]);
        fcalib = calib{2};
        Xall = calib{3};
        if (strcmp(sigType, 'Z'))
            Xall = Z0.*(1+Xall)./(1-Xall);
        end
        
        if (max(abs(fall-fref)) > 1e-4*fall(end) || max(abs(fall-fcalib)) > 1e-4*fall(end))
            fprintf(1, 'Frequencies do not match');
            reply = [];
            continue;
        end
        
        plotSweep (h(1:2), {'', ''}, fall, Xref, sigType, plotType, resType, [], [], [], winN);
        Xcomp = applyRef(Xall, Xref, resType(1));
        [f0 sig Q base] = calcRes(fall(fidx), Xcomp(fidx), resType, resN, winN, dBdiff);
        plotSweep (h(3:4), {'', ''}, fall(fidx), Xcomp(fidx), sigType, plotType, resType, f0, sig, Q, winN);
        
        reply = input('Try again? y/n: ', 's');
    end
    
    if (~strcmp(oldprefix, prefix))
        copyfile([oldprefix, 'REF', suffix], [prefix, 'REF', suffix]);
        copyfile([oldprefix, 'CALIB', suffix], [prefix, 'CALIB', suffix]);
    end
end
noise = sig;
    
fwrite(obj1, 'INIT:CONT 1');
fwrite(obj1, 'DISP:WIND:TRAC:Y:AUTO');
fprintf(1, 'Press any key to start sequence\n');
w = waitforbuttonpress;
fwrite(obj1, 'INIT:CONT 0');

idir = 1;
dir = '';
if (Ndir > 1)
    dir = 'up';
end
timeStep = Twait; % s
for itest=1:Ntests
    if (itest > Ntests/Ndir)
        idir = 2;
        dir = 'down';       
    end
    
    if (voltages(itest) > voltRange)
        break;
    end
    
    filename = [prefix, num2str(values(itest)), unit, suffix];
    fprintf(1, ['Setting to ' tests{itest} '\n']);

    setPressure(s, voltages(itest));
	pause(timeStep);

    reply = [];
    while (~(strcmp(reply,'n') || strcmp(reply,'q')))        
        timeSweep;
        realValues = getPressure(s)*presRange/voltRange;
                
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
               
        if (autoSequence)
            break;
        end
        
        fprintf(1,['Internal Pressure: ' num2str(realValues(1), 2), unit,'\n',...
            'External Pressure: ' num2str(realValues(2), 2), unit,'\n']);  
        reply = input('Try again? y/n (q to end): ', 's');
    end

    vs(itest, :) = realValues;
    f0s(itest, :) = f0;
    sigs(itest, :) = sig;
    Qs(itest, :) = Q;
    bases(itest, :) = base;
    
    if(strcmp(reply,'q'))
        break;
    end
end

setPressure(s, 0);

% [vs f0s sigs Qs bases noises] = cleanSigs(vs, f0s, sigs, Qs, bases, noise, sigtol, Qtolmin, Qtolmax);
noises = noise.*ones(size(vs));
    
vlim1 = [min(vs(:, 1))  max(vs(:, 1))];
vlabel1 = ['internal', parameter, ' [', unit, ']'];
setupSeqPlot;
viewSeq(h, vs(:, 1), f0s, sigs.*sigfactor, Qs, bases, noises, vlim1, vlabel1, siglabel, plotType, specs);
% vlim2 = [min(vs(:, 2))  max(vs(:, 2))];
% vlabel2 = ['external', parameter, ' [', unit, ']'];
% setupSeqPlot;
% viewSeq(h, vs(:, 2), f0s, sigs.*sigfactor, Qs, bases, noises, vlim2, vlabel2, siglabel, plotType, specs);

csvwrite([prefix, sigType, resType, '_PLOTS', suffix], [vs f0s sigs Qs bases noises]);
csvwrite([prefix, 'PRES', suffix], vs);

figure;
plot(values, vs, 'LineWidth',4);
xlabel(['set pressure [', unit, ']']);
ylabel(['measured pressures [', unit, ']']);
legend('internal', 'external');

fp0s = [];
dfdps = [];
figure;
plot(vs(:,1), f0s./1e6, '.','MarkerSize',15, 'LineWidth',3);
xlabel(vlabel1);
ylabel('f_0 [MHz]');
hold on;
for i=1:Nsens
	vfit = 0:1:100;
    N100mmHg = find(vs(:,1)<100, 1, 'last');
    [f0s_fit dfdp fp0] = lsfit(vs(1:N100mmHg, 1), f0s(1:N100mmHg, i), vfit, false, false);
    plot(vfit, f0s_fit./1e6, '--k', 'LineWidth', 1);

	fp0s = [fp0s fp0];
    dfdps = [dfdps dfdp];
    fprintf(1,['---\n', 'f0: ', num2str(f0s(1)/1e6, 4), ' MHz', '\n',...
        'Q:', num2str(Qs(1), 4), '\n',...
        'fp0: ', num2str(fp0/1e6, 4), ' MHz', '\n',...
        'df/dp: ', num2str(dfdp/1e6, 4), ' MHz/', unit,'\n', '---\n']);
end

fwrite(obj1, 'INIT:CONT 1');

endVNAConnection;
endNIConnection;
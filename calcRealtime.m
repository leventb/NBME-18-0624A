clear all;
% close all;

fint = [0 8.5].*1e9;
% folder = '..//05_10_2013';
% folder = '..//03_04_2013';
folder = '..//06_30_2013';
pickup_ant = 'loop1cm';
% sensor = 'mikepulseV22';
sensor = 'mikepulse501pts234';

winN = 3;
resN = 1;

sigfactor = 1e9;

sigtol = 1.5;
Qtolmin = 0;
Qtolmax = 0;
suffix = '.csv';
PLOTsuffix = '_PLOTS.csv';
Z0 = 50;
    
ref = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_REF', suffix]);
tref = ref{1};
fref = ref{2};
GDref = ref{3};

calib = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
tcalib = calib{1};
fcalib = calib{2};
GDcalib = calib{3};

if (abs(sum(fcalib-fref)) > 1e-4)
    fprintf(1, 'Calibration and reference frequencies do not match');
    return;
end

all = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_GDrealtime', suffix]);
tall = all{1};
fall = all{2};
GDall = all{3};
Nts = length(tall);

if (abs(sum(fall-fref)) > 1e-4);
    fprintf(1, 'Data and reference frequencies do not match');
end

vlim = [min(tall)  max(tall)];
vlabel = 'time [s]';
siglabel = ['GDD signal [ns]'];
specs = {'x', 'xr', ':k', 'xk'};

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
	fprintf('fint not in range');
    return
end

GDnoise = GDref-GDcalib;
GDnoise = medfilt1(GDnoise, winN);
[noise sigidx] = max(GDnoise);

scrsz = get(0,'ScreenSize');
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
Hwin = 0.4*scrsz(4);
Wwin = 0.25*scrsz(3);
sizeWINh = [2*Wwin 2*Hwin];
sizeWINv = [Wwin 2*Hwin];
figure('Position',[posWINrb sizeWINh]);
h = cell(2,1);
h{1} = subplot(2,3,1:2);
h{2} = subplot(2,3,3);
h{3} = subplot(2,3,4:5);
% h{3} = subplot(2,3,6);
subplot(h{1});
xlabel('time [s]');
ylabel('f0 [MHz]');
hold on;
subplot(h{3});
xlabel('time [s]');
ylabel('pressure change [mmHg]');
hold on;

% subplot(h{2})
% plot(fall./1e6, GDref.*1e9, 'LineWidth',4); 
% xlabel('f [MHz]');
% ylabel('GD [ns]');
% subplot(h{4});
% plot(fall./1e6, GDnoise.*1e9, 'LineWidth',4); 
% xlabel('f [MHz]');
% ylabel('GDD signal [ns]');text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['noise: ', num2str(noise.*1e9), 'ns']);


ts = [];
f0s = [];
sigs = [];

for i=4:Nts
    GDcomp = GDref-GDall(:, i);    
    GDcomp = medfilt1(GDcomp, winN);
    [sig sigidx] = max(GDcomp);

	if (sig > sigtol*noise)
        subplot(h{1});

        f0 = fall(sigidx);
        
        ts = [ts; tall(i);];      
        f0s = [f0s; f0;];
        sigs = [sigs; sig;];
    
%         fprintf(1, 'Press any key for next time\n');
%         w = waitforbuttonpress;
% 
%         subplot(h{1});
%         plot(ts, f0s./1e6, 'LineWidth',3);
%         subplot(h{2});
%         plot(fall./1e6, GDcomp.*1e9, 'LineWidth',4); 
%         text(mean(xlim)-range(xlim)*0.4, mean(ylim), ['f0: ', num2str(f0/1e6), 'MHz', 10, 'signal: ', num2str(sig.*1e9), 'ns']);
%         xlabel('f [MHz]');
%         ylabel(siglabel);
%         hold on;
%         plot(f0./1e6, sig.*1e9, 'ok','MarkerSize',10);
%         plot(xlim, [noise noise].*1e9, ':k', 'LineWidth',4);
%         hold off;        
	end
end

% dfdp = -0.7e6;
dfdp = -1.4e6;
fp0 = f0s(1);
ps = (f0s-fp0)./dfdp;

subplot(h{1});
plot(ts, f0s./1e6, 'LineWidth',3);
subplot(h{3});
plot(ts, ps, 'LineWidth',3);

noises = noise.*ones(size(ts));

csvwrite([folder, '//', pickup_ant, '_', sensor, '_GDplots', suffix], [ts f0s sigs noises ps]);
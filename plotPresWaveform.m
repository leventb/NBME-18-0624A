clear all;
close all;

folder = '..//03_04_2013';
pickup_ant = 'loop4mm';
tests = {'champion_incres'};
suffix = 'GDplots.csv';

scrsz = get(0,'ScreenSize');
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
Hwin = 0.4*scrsz(4);
Wwin = 0.5*scrsz(3);
sizeWIN = [Wwin Hwin];

fp0 = 1.0025e9;
% dfdp = -1.108e+06;
dfdp = -1.087e+06;
% fp0 = 9.9749e8;
% dfdp = -1.3126e+06;

figure('Position',[posWINlb sizeWIN]);
xlabel('time [s]');
ylabel('pressure [mmHg]');
hold;

specs = {'', 'k', 'r', ':k', 'g';};
Ntests = length(tests);
for i=1:Ntests
    filename = [folder, '//', pickup_ant, '_', tests{i}, '_', suffix];
    A = csvread(filename);
    ts = A(:, 1);
    vs = A(:, 2:3);
    f0s = A(:, 4);
    sigs = A(:, 5);
	noises = A(:, 6);

    f0 = mean(f0s);

    vs_av = mean(vs,2);
%     fp0 = f0s(1);
	ps = (f0s-fp0)./dfdp;
    plot(ts, [vs_av ps], 'LineWidth',3);
    plot(ts, [vs_av ps], 'LineWidth',3);
end
% legend ('internal', 'external', 'wireless sensor');
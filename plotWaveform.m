clear all;
close all;

folder = '..//03_17_2013';
pickup_ant = 'loop4mm';
tests = {'noise_long_4','dummy_long_v2'};
suffix = 'GDplots.csv';

scrsz = get(0,'ScreenSize');
posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
Hwin = 0.4*scrsz(4);
Wwin = 0.5*scrsz(3);
sizeWIN = [Wwin Hwin];

figure('Position',[posWINlb sizeWIN]);
xlabel('time [s]');
xlim([0 600]);
ylabel('\Deltaf_0 [%]');
hold;

specs = {'', 'k', 'r', ':k', 'g';};
Ntests = length(tests)
for i=1:Ntests
    filename = [folder, '//', pickup_ant, '_', tests{i}, '_', suffix];
    A = csvread(filename);
    ts = A(:, 1);
    f0s = A(:, 2);
    sigs = A(:, 3);
	noises = A(:, 4);
    f0 = mean(f0s);


    plot(ts, (f0s-f0)./f0*100, specs{i}, 'LineWidth',3);
end
legend ('sensor', 'fixed resonator');
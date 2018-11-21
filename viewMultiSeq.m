clear all;
% close all;

% folder = '..//02_22_2013';
folder = '..//03_17_2013';
pickup_ant = 'loop4mm';
% sigType = 'Z';
% resType = 'smh0';
sigType = 'S';
% resType = 'smh0';
resType = 'dph1';
% prefix = 'S50-100_ind2x_3x3';
% prefix = 'SBS_ind2x_4x4';
prefix = '';

suffix = [sigType, resType,'_PLOTS.csv'];
plotType = 'n';

% seqs = {'S50-100_ind2x_3x3_sealed_tube_v3',...
%     'S50-100_ind2x_2x2_batch2_sealed_tube',...
%     'S50-100_ind2x_1d5x1d5_sealed_tube', ...
%     'Snone_ind1d25x_4x4_sealed_tube'};
% seqs = {'afterpig_sealed_tube',...
%     'pig_on_sealed_tube'};
seqs = {'noise_long_2'};

siglabel = ['signal in ', partTypeLabel(resType, sigType, plotType)];

% labels = {'3x3 signal','3x3 noise', ...
%     '2x2 signal','2x2 noise'...
%     '1.5x1.5 signal','1.5x1.5 noise'};
% labels = {'50-100 3x3', ...
%     '50-100 2x2',...
%     '50-100 1.5x1.5',...
%     'plain 4x4'};
% labels = {'without tissue', ...
%     'with tissue'};
labels = {''};
Nseqs = length(seqs);

% parameter = 'separation';
% unit = 'mm';
% vlim = [0 10];

% parameter = 'pressure';
% unit = 'psi';
% vlim = [0 20];

parameter = 'time';
unit = 's';
vlim = [0 600];

vlabel = [parameter, ' [', unit, ']'];
setupSeqPlot;

specs = {   '', 'k', 'r', ':k', 'g';
            '-', '-k', '-r', '-m', '-g';
            ':', ':k', ':r', ':m', ':g';
            '+', '+k', '+r', '+m', '+g';};
% specs = {   'x', '+', 'xk', '+k', '*k', 'xr', '+r', ;
%             '-', '--', '-k', '--k', ':k', '-r', '--r';
%             'x', '+', 'xk', '+k', '*k', 'xr', '+r';};
% specs = {   'x', '+', 'xk', '+k', 'xr', '+r', ;
%             '-', '--', '-k', '--k', '-r', '--r';
%             'x', '+', 'xk', '+k', 'xr', '+r';};
f0_nom = [];
Q_nom = [];
pres_sens = [];
for i=1:Nseqs
    filename = [folder, '//', pickup_ant, '_', prefix, '_', seqs{i} , '_', suffix];
    A = csvread(filename);
    vs = A(:, 1);
    f0s = A(:, 2);
    sigs = A(:, 3);
	Qs = A(:, 4);
	bases = A(:, 5);
	noises = A(:, 6);
    
%     f0_nom = [f0_nom f0s(1)];
%     Q_nom = [Q_nom Qs(1)]; 
%     pres_sens = [pres_sens -mean(diff(f0s(1:2))./diff(vs(1:2)))];
    
%     viewSubSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabel, plotType, specs(:,i));
    viewSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabel, plotType, specs(:,i));
end

scrsz = get(0,'ScreenSize');

Nplotm = 1;
Nplotn = 2;

% if (~isempty(Qs))
	Nplotn = Nplotn + 1;
% end

% subplot(h{1});
% legend(labels);

% Hwin = 0.4*scrsz(4);
% Wwin = 0.25*scrsz(3);
% sizeWIN = [Wwin Hwin];
% figure('Position',[posWINlb sizeWIN]);
% size = [3, 2, 1.5];
% plot(size, f0_nom, 'x', 'MarkerSize',12, 'LineWidth',4);
% hold on;
% plot(size, f0_nom, ':', 'MarkerSize',12, 'LineWidth',4);
% xlabel('size [mm]');
% ylabel('f_0 [MHz]');
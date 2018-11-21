clear all;
close all;

nport = 3;
% fstart = 0.1e9;
% fstop = 2e9;
fstart = 2e9;
fstop = 6e9;
Npts = 1601;

folder = '..//02_21_2013';
pickup_ant = 'loop4mm';

useAverage = true;
Nsamples = 10;
Tdelay = 0;

suffix = '.csv';
filename = [folder, '//', pickup_ant, '_REF', suffix];

startConnection;
setupTest;
fall = transpose(str2num(freq));

timeSweep;
Sref = processSweep(sweep, Npts, Nsamples, useAverage);
saveSweep(filename, tall, fall, Sref, useAverage);

endConnection;
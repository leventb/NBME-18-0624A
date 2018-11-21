s = daq.createSession('ni');
% s.IsContinuous = true;
s.Rate = 10;

s.addAnalogInputChannel('Dev1', [2 3], 'Voltage');
s.Channels(1).InputType = 'SingleEndedNonReferenced';
s.Channels(2).InputType = 'SingleEndedNonReferenced';

s.addAnalogOutputChannel('Dev1', 0, 'Voltage');

% lh_in = s.addlistener('DataAvailable', @(src,event) fprintf(1,...
%     ['Internal Pressure: ' num2str(event.Data(1), 2), 'psi\n',...
%     'External Pressure: ' num2str(event.Data(2), 2), 'psi\n']));
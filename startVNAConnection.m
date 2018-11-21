instrreset;
%visa_addr='USB0::0x0957::0x1509::MY51100104::0::INSTR'; %Poon Lab VNA
%Address

visa_addr= 'USB0::0x0957::0x0D09::MY46418033::0::INSTR'; %Bao Lab VNA

obj1 = instrfind('Type', 'visa', 'RsrcName', visa_addr, 'Tag', '');

% create the VISA-GPIB object if it does not exist
% otherwise use the object that was found.
if isempty(obj1)
    obj1 = visa('agilent', visa_addr);
else
    fclose(obj1);
    obj1 = obj1(1);
end

% max out buffer size for largest possible read of 1601 points
set(obj1,'InputBufferSize', 80050);

% connect to instrument object, obj1.
fopen(obj1);

% communicating with instrument object, obj1.
instrinfo = query(obj1, '*IDN?');
fprintf(1, 'Connected to: %s\n', instrinfo);
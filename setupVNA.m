fwrite(obj1, ['SENS:FREQ:START ', num2str(fstart)]);
fwrite(obj1, ['SENS:FREQ:STOP ', num2str(fstop)]);
fwrite(obj1, ['SENS:SWE:POINTS ', num2str(Npts)]);
fwrite(obj1, ['CALC:PAR:DEF S', num2str(nport), num2str(nport)]);
fwrite(obj1, 'FORM:DATA ASC'); 
fwrite(obj1, 'SENS:FREQ:DATA?');
freq = fscanf(obj1); 

calibTerms = {'OPEN', 'SHORT', 'LOAD'};
reply = input('Calibrate VNA? y/n: ', 's');
while (~strcmp(reply,'n'))
%     fwrite(obj1, 'SENS:CORR:COLL:CKIT?');    
    fwrite(obj1, ['SENS:CORR:COLL:METH:SOLT1 ', num2str(nport)]);    
    for i = 1:length(calibTerms)
        input(['Press enter to sweep ',calibTerms{i},'\n'], 's');
        fwrite(obj1, ['SENS:CORR:COLL:', calibTerms{i}, ' ', num2str(nport)]);
        fwrite(obj1, '*OPC?');
        opc_comp=fscanf(obj1);
    end
    fwrite(obj1, 'SENS:CORR:COLL:SAVE');
    reply = input('Try again? y/n: ', 's');
end

% flush the buffer
clrdevice(obj1);
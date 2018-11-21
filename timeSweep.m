tall = zeros(1, Nsamples);
sweep = cell(Nsamples, 1);

t = timer('StartDelay', Tdelay, 'TimerFcn', @(x,y)disp(num2str(toc)));
tic;
for i=1:Nsamples
	fwrite(obj1, 'INIT:IMM; *OPC?');
    opc_comp=fscanf(obj1); 

    % ask for data
    fwrite(obj1, 'CALC:DATA:SDAT?'); 
    sweep{i} = fscanf(obj1);
    tall(i) = toc;
    
    start(t);
    wait(t);
end
delete(t);
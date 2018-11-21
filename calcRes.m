function [f0 signal Q baseline] = calcRes(fsubset, X, resType, resN, winN, dBdiff)
    Ndes = size(X,2);
    
    Q = zeros(Ndes, 1);
    f0 = zeros(Ndes, 1);
    signal = zeros(Ndes, 1);
    baseline = zeros(Ndes, 1);
    
    switch resType(2)
        case 'r'
            Xsubset = real(X);
        case 'i'
            Xsubset = imag(X);
        case 'm'
            Xsubset = abs(X);
        case 'p'
            Xsubset = unwrap(angle(X));
        otherwise
            return;
    end

    switch resType(3)
        case 'h' 
            mode = 'descend';
        case 'l'
            mode = 'ascend';
        otherwise
            return;
    end
    
%     Xsubset = filterX(Xsubset, winN);

    Nder = str2num(resType(4));
    for d=1:Nder
        Xsubset = diff(Xsubset)./(diff(fsubset)*ones(1, Ndes))./(2*pi);        
        fsubset = (fsubset(1:end-1)+fsubset(2:end))/2;
%         Xsubset = Xsubset./(fsubset*ones(1, Ndes))./(2*pi);            
    end

    Xsubset = filterX(Xsubset, winN);
    Nf = size(Xsubset,1);
            
    [Xsorted, fidx] = sort(Xsubset, 1, mode); 
    
	fidx = round(mean(fidx(1:resN, :), 1));
    idx = (0:Ndes-1)*Nf + fidx;

    f0 = fsubset(fidx);
    signal = transpose(Xsubset(idx));
    baseline = transpose(mean(Xsubset));
        
    if (dBdiff > 0)
    	Q = calcQ(fsubset, 20*log10(abs(Xsubset)), fidx, 20*log10(abs(signal))- dBdiff);
    end
end
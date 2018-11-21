function [f0 signal Q baseline] = calcMultiRes(fsubset, X, resType, resN, winN, dBdiff, Nres, sigThres)
    Ndes = size(X,2);
    
    Q = zeros(Ndes, Nres);
    f0 = zeros(Ndes, Nres);
    signal = zeros(Ndes, Nres);
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
    
    baseline = transpose(mean(Xsubset));
    
    for m=1:Ndes
        istart = 1;
        Xm = Xsubset(:, m);
        Xthres = (Xsubset(:, m) > sigThres);
%         Xthres = filter([1 1], 1, Xthres) > 0;
        dBX = 20*log10(abs(Xm));
                
        for n=1:Nres
            if (istart > Nf || sum(Xthres(istart:end)) == 0)
                f0(m, n:end) = 0;
                signal(m, n:end) = 0;
                Q(m, n:end) = 0;
                break;
            end
            
            istart = istart-1 + find(Xthres(istart:end), 1, 'first');
            iend = istart + find(~Xthres(istart+1:end), 1, 'first') - 1;
            
            Xmn = Xm(istart:iend); 

            [Xsorted, fidx] = sort(Xmn, 1, mode); 
            fidx = istart-1 + round(mean(fidx(1:resN, :), 1));

            f0(m, n) = fsubset(fidx);
            signal(m, n) = transpose(Xm(fidx));
            
            if (dBdiff > 0)
                X3dB = 20*log10(abs(signal(m, n)))- dBdiff;
                bwX = dBX < X3dB;
            
                fl_idx = find(bwX(1:fidx-1), 1, 'last');
                fh_idx = find(bwX(fidx+1:end), 1, 'first')+fidx;

                if (~isempty(fl_idx) && ~isempty(fh_idx))
                    fl = linInterp(fsubset(fl_idx),fsubset(fl_idx+1),dBX(fl_idx),dBX(fl_idx+1),X3dB);
                    fh = linInterp(fsubset(fh_idx),fsubset(fh_idx-1),dBX(fh_idx),dBX(fh_idx-1),X3dB);

                    BW = fh-fl;
                    Q(m, n) = f0(m, n)./BW;
                end
            end
            
            istart = iend+1;
        end
    end
end
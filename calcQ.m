function Q = calcQ(f, dBX, fidx, X3dB)
    Q = zeros(size(X3dB));
    for i = 1:length(X3dB)
        bwX = dBX(:, i) < X3dB(i);
            
        fl_idx = find(bwX(1:fidx(i)-1), 1, 'last');
        fh_idx = find(bwX(fidx(i)+1:end), 1, 'first')+fidx(i);
        
        if (~isempty(fl_idx) && ~isempty(fh_idx))
            fl = linInterp(f(fl_idx),f(fl_idx+1),dBX(fl_idx, i),dBX(fl_idx+1, i),X3dB(i));
            fh = linInterp(f(fh_idx),f(fh_idx-1),dBX(fh_idx, i),dBX(fh_idx-1, i),X3dB(i));

            BW = fh-fl;
            Q(i) = f(fidx(i))./BW;
        end
    end
end
function Xfilt = filterX (X, winN)
    if (winN > 0)
%         win = rectwin(winN);
%         win = triang(winN);
%         win = gausswin(winN);
        
%         Xfilt = filter(win/sum(win), 1, X);
        
%         Tf = 1.875e9;
%         
%         tauf = 1000e9;
%         a = Tf/tauf;
%         Xfilt = filter(a, [1 a-1], X);     
% 
%         tauf = 50e9;
%         a = Tf/tauf;
%         Xfilt = filter([1-a a-1], [1 a-1], X);  
        
        Xfilt = medfilt1(X, winN);
    else
        Xfilt = X;
    end
end
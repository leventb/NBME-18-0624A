function plotSweep (h, specs, fplot, Xplot, showType, plotType, resType, f0, sig, Q, winN)    
    switch resType(2)
        case 'm'
            plotSweepPart(h{1}, specs{1}, fplot, Xplot, showType, plotType, resType, f0, sig, Q, winN);
            plotSweepPart(h{2}, specs{2}, fplot, Xplot, showType, ' ', [resType(1), 'p  '], [], [], [], winN);
        case 'p'
            plotSweepPart(h{1}, specs{1}, fplot, Xplot, showType, ' ', [resType(1), 'm  '], [], [], [],winN);
            plotSweepPart(h{2}, specs{2}, fplot, Xplot, showType, plotType, resType, f0, sig, Q, winN);
        case 'r'
            plotSweepPart(h{1}, specs{1}, fplot, Xplot, showType, plotType, resType, f0, sig, Q, winN);
            plotSweepPart(h{2}, specs{2}, fplot, Xplot, showType, ' ', [resType(1), 'i  '], [], [], [],winN);
        case 'i'
            plotSweepPart(h{1}, specs{1}, fplot, Xplot, showType, plotType, [resType(1), 'r  '], [], [], [], winN);
            plotSweepPart(h{2}, specs{2}, fplot, Xplot, showType, ' ', resType, f0, sig, Q, winN);
        otherwise
            return;
    end
end
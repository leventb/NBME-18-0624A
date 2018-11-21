function plotSweepPart(h, spec, fplot, Xplot, showType, plotType, resType, f0, sig, Q, winN)
    subplot(h);
    
    yfactor = 1;
    
    if (strcmp(resType, 'dph1'))
        yfactor = 1e9;
    end

    switch resType(2)
        case 'r'
            yplot = real(Xplot);
        case 'i'
        	yplot = imag(Xplot);
        case 'm'
            yplot = abs(Xplot);
        case 'p'
            yplot = unwrap(angle(Xplot));
        otherwise
            return;
    end
    
    yplot = yplot.*yfactor;
    sig = sig.*yfactor;
    
%     yplot = filterX(yplot, winN);

    Nder = str2num(resType(4));
    for d=1:Nder
%         zplot = yplot./(fplot*ones(1, size(yplot,2))./(2*pi));
%         yplot = (zplot(1:end-1, :)+zplot(2:end, :))/2;

        yplot = diff(yplot)./(diff(fplot)*ones(1, size(yplot,2)))./(2*pi);
        fplot = (fplot(1:end-1)+fplot(2:end))/2 ;
        
%         yplot = yplot.*(zplot > ones(size(zplot,1), 1)*mean(zplot));
%         Xplot = cumtrapz(Xplot);
    end
    
	yplot = filterX(yplot, winN);
        
    if (strcmp(plotType, 'g'))
        plot(fplot./1e6, 20*log10(abs(yplot)), spec, 'LineWidth',4);
    else
        plot(fplot./1e6, yplot, spec,'LineWidth',4);
    end
    
    hold on;
    
%     colors = get(gcf,'DefaultAxesColorOrder');

    if (~isempty(f0))
        for i0=1:size(f0, 1)
            j0plot = (f0(i0, :) > 0);
            plot(f0(i0, j0plot)'./1e6, sig(i0, j0plot)', 'ok','MarkerSize',10);
        end
    end
    
    if (~isempty(Q))
        reslabel = ['f0: ', num2str(f0/1e6, 3), ' MHz', 10, 'signal: ', num2str(sig, 2), 10, 'Q: ', num2str(Q, 3), partTypeUnit(resType, showType, plotType)];
        text(mean(xlim)-range(xlim)*0.4, mean(ylim), reslabel);
    end
                
    xlabel('f [MHz]');
    ylabel(partTypeLabel(resType, showType, plotType));
    
    hold off;
end

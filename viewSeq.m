function viewSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabel, plotType, specs)

    if strcmp(plotType, 'g')
        sigs = 20*log10(abs(sigs));
        noises = 20*log10(abs(noises));
    end

    subplot(h{1});
    plot(vs, f0s./1e6, specs{1}, 'MarkerSize',12, 'LineWidth',4);
    xlabel(vlabel);
    xlim(vlim);
    ylabel('f0 [MHz]');
    hold on;
    subplot(h{2});

    plot(vs, sigs, specs{2}, 'MarkerSize',12, 'LineWidth',4);
    xlabel(vlabel);
    xlim(vlim);
    ylabel(siglabel);
    hold on;
%     plot(vs, bases, '--k', 'MarkerSize',12, 'LineWidth',4);
    plot(vs, noises, specs{3}, 'MarkerSize',12, 'LineWidth',4);
    legend('signal', 'noise');
    if (~isempty(Qs))
        subplot(h{3});
        plot(vs, Qs, specs{4}, 'MarkerSize',12, 'LineWidth',4);
        xlabel(vlabel);
        xlim(vlim);
        ylabel('Q');
        hold on;
    end
end

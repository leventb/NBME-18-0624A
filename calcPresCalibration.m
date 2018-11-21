clear all;
% close all;

fint = [0 8.5].*1e9;
% folder = '..//02_22_2013';
% folder = '..//03_04_2013';
% folder = '..//03_25_2013';
% folder = '..//04_07_2013';
% folder = '..//04_08_2013';
% folder = '..//05_08_2013';
% folder = '..//05_09_2013';
folder = '..//06_19_2013';
pickup_ant = 'loop4mm';
% values = (0:50:500)';
values = (0:10:100)';
% values = (0:10:50)';
% values = (0:5:100)';
% values = ([0 100])';
% values = (0:100)';
parameter = 'pressure';
unit = 'mmHg';
% unit = 'psi';
% sensor = 'champion_res5mmHg';
% sensor = 'champion_50mmHg_res1mmHg';
% sensor = 'Litho2_1d5x1d5_1d5-3ghz_finef_v2';
% sensor = 'SBS_ind2x_1d5x1d5_s3_v2';
% sensor = 'SBS_ind2x_1d5x1d5_s3_ultrafinef';
% sensor = 'SBS_ind_array_pres_finef';
% sensor = 'SBS_ind_array_s4_finef';
% sensor = 'SBS_cap_array_finef';
% sensor = 'SBS_cap_array_s4';
% sensor = 'S50-100_ind2x_3x3_afterpig_sealed_tube';
% sensor = 'S50-100_ind2x_3x3_pig_on_sealed_tube';
% sensor = 'S50-100_ind2x_3x3_sealed_tube';
% sensor = 'SBS_ind2x_4x4_afterpig_sealed_tube';
% sensor = 'SBS_ind2x_4x4_pig_on_sealed_tube';
% sensor = 'champion_res10mmHg';
% sensor = 'ind2x_3x3_s1_afterh2o_finef';
% sensor = 'ind2x_3x3_s1_h2o_finef';
% sensor = 'ind2x_3x3_s1_h2o';
% sensor = 'ind2x_3x3_s2_h2o';
% sensor = 'ind2x_4x4_s2';
% sensor = 'ind2x_3mm_s2';
sensor = 'ind3x_2d5mm_square_s2';

% Nsens = 4;
Nsens = 1;

viewPlots = true;
createGif = false;
useRef = true; 
useS = true;
% resTypeS= 'dph1';
resTypeS= 'pmh0';
% resTypeS= 'smh0';
plotTypeS = 'n';
% useZ = true;
useZ = false;
% resTypeZ= 'oph0';
resTypeZ= 'srh0';
plotTypeZ = 'n';

winN = 19;
resN = 1;

dBdiffS = 3;
dBdiffZ = 3;
if (resTypeS(1)== 'p')
    dBdiffS = 6;
end
if (resTypeZ(1)== 'p')
    dBdiffZ = 6;
end

sigfactorS = 1;
sigfactorZ = 1;
if (strcmp(resTypeS, 'dph1'))
	sigfactorS = 1e9;
end
if (strcmp(resTypeZ, 'dph1'))
	sigfactorZ = 1e9;
end

sigtol = 1.5;
% sigtol = 6.5;
% sigtol = 100;
Qtolmin = 0;
Qtolmax = 0;
suffix = '.csv';
PLOTsuffix = '_PLOTS.csv';
Z0 = 50;
tests = cellstr(strcat(num2str(values), unit));
Ntests = length(tests);

vs_meas = csvread([folder, '//', pickup_ant, '_', sensor, '_PRES', suffix]);

vs = vs_meas(:, 1)-vs_meas(1, 1);

if (useRef)
    ref = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_REF', suffix]);
    tref = ref{1};
    fref = ref{2};
    Sref = ref{3};
    Zref = Z0.*(1+Sref)./(1-Sref);

    calib = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_CALIB', suffix]);
    tcalib = calib{1};
    fcalib = calib{2};
    Scalib = calib{3};
    Zcalib = Z0.*(1+Scalib)./(1-Scalib);
    
    if (abs(sum(fcalib-fref)) > 1e-4)
        fprintf(1, 'Calibration and reference frequencies do not match');
        return;
    end
end

Stests = [];
Ztests = [];
for i=1:Ntests
    all = recallSavedSweep([folder, '//', pickup_ant, '_', sensor, '_', num2str(values(i)), unit, suffix]);
    tall = all{1};
    fall = all{2};
    Sall = all{3};
    Zall = Z0.*(1+Sall)./(1-Sall);

    if (abs(sum(fall-fref)) > 1e-4);
        fprintf(1, 'Data and reference frequencies do not match');
    end

    Stests = [Stests Sall];
    Ztests = [Ztests Zall];

    vlim = [min(values)  max(values)];
    vlabel = [parameter, ' [', unit, ']'];
    siglabelS = ['signal in ', partTypeLabel(resTypeS, 'S', plotTypeS)];
    siglabelZ = ['signal in ', partTypeLabel(resTypeZ, 'Z', plotTypeZ)];
    specs = {'x', 'xr', ':k', 'xk'};
end

fidx = find((fall>fint(1))&(fall<fint(2)));
if (isempty(fidx))
	fprintf('fint not in range');
    return
end

if (useS)
    if (viewPlots)
        setupPlot;
        plotSweep (h(1:2), {'', ''}, fall, [Stests Sref], 'S', ' ', [' ' resTypeS(2) '  '], [], [], [], winN);
    end

    if (useRef)
        Scomp = applyRef(Scalib, Sref, resTypeS(1));
        [f0_S noise_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS);

        Scomp = applyRef(Stests, Sref, resTypeS(1));
        if (Nsens > 1)
            [f0_S sig_S Q_S base_S] = calcMultiRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS, Nsens, sigtol*noise_S);
        else
            [f0_S sig_S Q_S base_S] = calcRes(fall(fidx), Scomp(fidx, :), resTypeS, resN, winN, dBdiffS);
        end

        if (viewPlots)
            plotSweep (h(3:4), {'', ''}, fall(fidx), Scomp(fidx, :), 'S', plotTypeS, resTypeS, f0_S, sig_S, [], winN);
        end
        
        [vs f0s sigs Qs bases noises] = cleanSigs(vs, f0_S, sig_S, Q_S, base_S, noise_S, sigtol, Qtolmin, Qtolmax);
        
        setupSeqPlot;
        viewSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabelS, plotTypeS, specs);
        csvwrite([folder, '//', pickup_ant, '_', sensor, '_S', resTypeS, PLOTsuffix], [vs f0s sigs Qs bases noises]);
    end
end
if (useZ)
	if (viewPlots)
        setupPlot;
        plotSweep (h(1:2), {'', ''}, fall, [Ztests Zref], 'Z', ' ', [' ' resTypeZ(2) '  '], [], [], [], winN);
    end
    
    if (useRef)
        Zcomp = applyRef(Zcalib, Zref, resTypeZ(1));
        [f0_Z noise_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ);

        Zcomp = applyRef(Ztests, Zref, resTypeZ(1));
        if (Nsens > 1)
            [f0_Z sig_Z Q_Z base_Z] = calcMultiRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ, Nsens, sigtol*noise_Z);
        else
            [f0_Z sig_Z Q_Z base_Z] = calcRes(fall(fidx), Zcomp(fidx, :), resTypeZ, resN, winN, dBdiffZ);
        end
         
        if (viewPlots)
            plotSweep (h(3:4), {'', ''}, fall(fidx), Zcomp(fidx, :), 'Z', plotTypeZ, resTypeZ, f0_Z, sig_Z, [], winN)
        end
        
        [vs f0s sigs Qs bases noises] = cleanSigs(vs, f0_Z, sig_Z, Q_Z, base_Z, noise_Z, sigtol, Qtolmin, Qtolmax);
        
        setupSeqPlot;
        viewSeq(h, vs, f0s, sigs, Qs, bases, noises, vlim, vlabel, siglabelZ, plotTypeZ, specs);
        csvwrite([folder, '//', pickup_ant, '_', sensor, '_Z', resTypeZ, PLOTsuffix], [vs f0s sigs Qs bases noises]);
    end
end

setupSeqPlot;
subplot(h{1});
% figure;
% plot(vs(:,1), f0s./1e6, '.','MarkerSize',15, 'LineWidth',3);
plot(vs(:,1), (f0s(1, :)-f0s)./1e6, '.','MarkerSize',15, 'LineWidth',3);
xlabel(vlabel);
% ylabel('f_0 [MHz]');
ylabel('\Deltaf_0 [MHz]');
hold on;

fp0s = [];
dfdps = [];
for i=1:Nsens
    vfit = 0:1:100;
% 	vfit = 0:1:25;
    N100mmHg = find(vs(:,1)<100, 1, 'last');
    [f0s_fit dfdp fp0] = lsfit(vs(1:N100mmHg, 1), f0s(1:N100mmHg, i), vfit, false, false);
%     plot(vfit, f0s_fit./1e6, '--k', 'LineWidth', 1);
    plot(vfit, (f0s(1, :)-f0s_fit)./1e6, '--k', 'LineWidth', 3);
    text(mean(xlim)-range(xlim)*0.4, mean(ylim)-range(ylim)*0.4, ['df/dP: ', num2str(dfdp/1e6, 4), ' MHz/', unit]);  

    fp0s = [fp0s fp0];
    dfdps = [dfdps dfdp];
    fprintf(1,['---\n', 'f0: ', num2str(f0s(1, i)/1e6, 4), ' MHz', '\n',...
        'Q:', num2str(Qs(1, i), 4), '\n',...
        'fp0: ', num2str(fp0/1e6, 4), ' MHz', '\n',...
        'df/dp: ', num2str(dfdp/1e6, 4), ' MHz/', unit,'\n', '---\n']);
end

% setupSeqPlot;
% subplot(h{1});
% plot(vs(:,1), f0s(:, i)./1e6, '.','MarkerSize',15, 'LineWidth',3);
% xlabel(vlabel);
% ylabel('f_0 [MHz]');
% hold on;
% plot(vfit, f0s_fit./1e6, '--k', 'LineWidth',3);
% text(mean(xlim)-range(xlim)*0.4, mean(ylim)-range(ylim)*0.4, ['f_0|_P_=_0: ', num2str(fp0/1e6, 4), ' MHz', 10,...
%     'df/dP: ', num2str(dfdp/1e6, 4), ' MHz/', unit] );  
% 
% subplot(h{2});
% plot(vs(:,1), 1./f0s(:, i).^2.*1e12, '.r','MarkerSize',15, 'LineWidth',3);
% xlabel(vlabel);
% ylabel('1/f_0^2 [1/MHz^2]');
% hold on;
% plot(vfit, 1./f0s_fit.^2.*1e12, '--k', 'LineWidth',3);

if (createGif)
    fp0s = [5.0395 5.9431 6.0634 6.5486].*1e9;
    dfdps = [-3.5647 -4.7630 -2.8765 -5.2182].*1e6;
    p0s = (f0s-ones(Ntests, 1)*fp0s)./(ones(Ntests, 1)*dfdps);

    df0s = abs(f0s-ones(Ntests, 1)*f0s(1,:))./1e6;

    pmin = 0;
    pmax = max(max(df0s));
    figure('Position',[15 60 450 450], 'Renderer','zbuffer');
    corder = get(gcf,'DefaultAxesColorOrder');
    filename = 'test.gif';
    for n = 1:Ntests
        hbar = bar3([df0s(n, 4) 0; 0 0]);
        set(hbar,'facecolor', corder(4,:))
        zlim([pmin pmax]);
        set(gca,'XDir', 'reverse',  'XGrid', 'off', 'YGrid', 'off');
    %     set(gca, 'XTick', [], 'YTick', []);
        pbaspect([1 1 1]);
        set(gca,'color','none');
        set(gcf,'color','w');
        zlabel('\Deltaf_0 [MHz]');
        hold on;
        hbar = bar3([0 df0s(n, 1); 0 0]);
        set(hbar,'facecolor', corder(1,:))
        hold on;
        hbar = bar3([0 0; df0s(n, 2) 0]);
        set(hbar,'facecolor', corder(2,:))
        hold on;
        hbar = bar3([0 0; 0 df0s(n, 3)]);
        set(hbar,'facecolor', corder(3,:))
        hold off;

    %     for hn=1:length(hbar)
    %         cdata=get(hbar(hn),'zdata');
    %         repmat(max(cdata,[],2),1,4);
    %         set(hbar(hn),'cdata',cdata,'facecolor','flat')
    %     end

        drawnow
        frame = getframe(gcf);
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if (n == 1)
            imwrite(imind,cm,filename,'gif', 'Loopcount',1, 'DelayTime', 0.1)
        else
            imwrite(imind,cm,filename, 'gif', 'WriteMode','append', 'DelayTime', 0.1);
        end
    end
end
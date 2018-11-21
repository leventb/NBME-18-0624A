scrsz = get(0,'ScreenSize');

Nplotm = 2;
Nplotn = 2;

Hwin = 0.4*scrsz(4)*Nplotm;
Wwin = 0.25*scrsz(3)*Nplotn;

posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
sizeWIN = [Wwin Hwin];

figure('Position',[posWINrb sizeWIN]);

Nplots = Nplotm*Nplotn;

h = cell(Nplots,1);
h{1} = subplot(Nplotm,Nplotn,1);
h{2} = subplot(Nplotm,Nplotn,2);
h{3} = subplot(Nplotm,Nplotn,3:4);
subplot(h{3});
xlabel('time [s]');
ylabel('f0 [MHz]');
hold on;
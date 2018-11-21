scrsz = get(0,'ScreenSize');

Nplotm = 1;
Nplotn = 2;

if (useRef)
    Nplotm = 2*Nplotm;
end

Hwin = 0.4*scrsz(4)*Nplotm;
Wwin = 0.25*scrsz(3)*Nplotn;

posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
sizeWIN = [Wwin Hwin];

figure('Position',[posWINrb sizeWIN]);

Nplots = Nplotm*Nplotn;

h = cell(Nplots,1);
for i=1:Nplots
    h{i} = subplot(Nplotm,Nplotn,i);
end
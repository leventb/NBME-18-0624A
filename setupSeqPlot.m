scrsz = get(0,'ScreenSize');

Nplotm = 1;
Nplotn = 2;

% if (~isempty(Qs))
	Nplotn = Nplotn + 1;
% end

Hwin = 0.4*scrsz(4)*Nplotm;
Wwin = 0.25*scrsz(3)*Nplotn;

posWINlb = [15 60];
posWINrb = [0.5*scrsz(3)-10 60];
sizeWIN = [Wwin Hwin];

figure('Position',[posWINlb sizeWIN]);
subplot(Nplotm,Nplotn,1);

Nplots = Nplotm*Nplotn;

h = cell(Nplots,1);
for i=1:Nplots
    h{i} = subplot(Nplotm,Nplotn,i);
%     hold on;
end
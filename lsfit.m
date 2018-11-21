function [signal_fit a  b] = lsfit(conc, signal, conc_fit, conc_log, signal_log)

if (conc_log)   x = log(conc);
else            x = conc;
end
if (signal_log) y = log(signal);
else            y = signal;
end

n = size(x, 1);
U_lin = [x ones(n, 1)];
V_lin = y;
w_lin = U_lin\V_lin;
% w_lin = inv(U_lin'*U_lin)*U_lin'*V_lin;
a = w_lin(1);
b = w_lin(2);

if (conc_log)   xfit = log(conc_fit);
else            xfit = conc_fit;
end
if (signal_log) signal_fit = exp(a*xfit+b);;
else            signal_fit = a*xfit+b;
end
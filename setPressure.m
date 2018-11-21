function setPressure(s, presVal)

% function lh_out = setPressure(s, presVal)

%     s.queueOutputData(presVal);
%     lh_out = s.addlistener('DataRequired', @(src,event) src.queueOutputData(presVal));
%     s.startBackground();

    s.outputSingleScan(presVal);
end
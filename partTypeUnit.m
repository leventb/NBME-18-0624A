function unit = partTypeUnit(resType, showType, plotType)

    unit = '';  
    if strcmp(plotType, 'g')
        unit = 'dB';
    elseif strcmp(resType(1), 's')   
        switch resType(2)
            case {'m', 'r', 'i'}
                if (strcmp(showType, 'Z'))
                    unit = '\Omega';
                end
            case 'p'
                unit = '\circ';
        end
    end

    switch resType(3) case {'i', 'd'}
            unit = [unit, '/Hz'];
    end
end

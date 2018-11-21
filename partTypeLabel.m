function label = partTypeLabel(resType, showType, plotType)
    if (strcmp(resType, 'pmh0'))
        label = 'PRD';
        return;
    elseif (strcmp(resType, 'dph1'))
        label = 'GDD [ns]';
        return;
    end
    
    switch resType(1)
        case 's'
            showType = ['(', showType, '-',showType,'_R_E_F)'];
        case 'd'
            showType = ['(', showType, '/',showType,'_R_E_F)'];
        case 'o'
            showType = ['(', showType, '_R_E_F/',showType, ')'];
        case 'n'
            showType = ['(-', showType, '/',showType,'_R_E_F)'];
        case 'u'
            showType = ['(1-', showType, '/',showType,'_R_E_F)'];
    end

    switch resType(2)
        case 'm'
            label = ['|', showType, '|'];
        case 'p'
            label = ['\angle',showType];
        case 'r'
            label = ['re ', showType];
        case 'i'
            label = ['im ',showType];
        otherwise
            label = '';
    end

    Nder = str2num(resType(4));
    if (Nder==1)
        label = ['d/df( ', label, ' )'];
    elseif (Nder>1)
        label = ['d^', resType(4), '/df^', resType(4), '( ', label, ' )'];
    end

	if strcmp(plotType, 'g')
            label = ['20log( ', label, ' ) [dB]'];
    else
            label = [label, ' [', partTypeUnit(resType, showType, plotType), ']'];
	end
end

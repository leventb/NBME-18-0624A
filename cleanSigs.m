function [vs f0s sigs Qs bases noises] = cleanSigs(vs, f0s, sigs, Qs, bases, noise, sigtol, Qtolmin, Qtolmax)

    ides = (1:size(sigs, 1))';
    ires = (1:size(sigs, 2))';
        
    if (Qtolmin > 0)
        ides = (ides & sum((Qs > Qtolmin), 2));
    end
    
    if (Qtolmax > 0)
        ides = (ides & sum((Qs < Qtolmax), 2));
    end
    
    if (sigtol > 0)
        ides = (ides & sum((sigs > sigtol*noise), 2));
    end
        
    vs = vs(ides, 1);
    f0s = f0s(ides, ires);
    sigs = sigs(ides, ires);
    if (~isempty(Qs))
        Qs = Qs(ides, ires);
    end
    bases = bases(ides, 1);
    
    noises = noise.*ones(size(vs));
end


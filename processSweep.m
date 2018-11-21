function Sall = processSweep(sweep, Npts, Nsamples, useAverage)

    Sall = zeros(Npts, Nsamples);

    for i=1:Nsamples
        St = reshape(str2num(sweep{i}), 2, Npts);
        Sall(:, i) = transpose(St(1, :)+1i.*St(2, :));
    end

    if (useAverage)
        Sall = mean(Sall, 2);
    end

end

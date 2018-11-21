function saveSweep(filename, tall, fall, Sall, useAverage)

    if (useAverage)
        csvwrite(filename, [fall Sall]);
    else
        csvwrite(filename, [-1 tall; fall Sall;]);
    end

end
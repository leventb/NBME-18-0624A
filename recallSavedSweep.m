function all = recallSavedSweep(filename)

    A = csvread(filename);

    if (A(1,1)==-1)
        tall = A(1, 2:end);
        fall = A(2:end, 1);
        Sall = A(2:end, 2:end);
    else
        tall = [];
        fall = A(:, 1);
        Sall = A(:, 2);
    end

    all = {tall, fall, Sall};

end
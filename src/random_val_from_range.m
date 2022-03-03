function val = random_val_from_range(range)
    if length(range)==1
        val =  range(1);
    else
        val =  range(1) + (range(2) - range(1)) * rand();
    end
end
function array = str2num_array(str)
    % transform '[0, 0 , 0 ]' in [0,0,0]
    % transform '0, 0 , 0' in [0,0,0]

    tmp=replace(str,'[','');
    tmp=replace(tmp,']','');
    array= str2num(tmp);
    
end
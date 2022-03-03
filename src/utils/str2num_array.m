function array = str2num_array(str)
    %STR2NUM_ARRAY extract the array out of a string 
    % transform '[0, 0 , 0 ]' in [0,0,0]
    % transform '0, 0 , 0' in [0,0,0]

    tmp=replace(str,'[','');
    tmp=replace(tmp,']','');
    array= str2num(tmp);
    
end
function s= num_array2str(array)
    %NUM_ARRAY2STR Return the array as a string as "[ array ]"
    
    s= '';
    n_row=size(array,1);
    for row = 1:n_row
        s= [s, num2str(array(row,:))];
        if row~=n_row
            s=[s '; '];
        end
    end
    s = [ '[' s ']'];
end
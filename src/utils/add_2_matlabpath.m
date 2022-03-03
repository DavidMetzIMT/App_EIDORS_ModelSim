function add_2_matlabpath(path_struct)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    p=struct2cell(path_struct);
    for i=1:size(p,1)
        addpath(p{i});
    end
end


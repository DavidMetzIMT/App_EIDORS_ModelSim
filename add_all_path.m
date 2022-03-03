function add_all_path(path)

    if nargin == 0
        path=pwd;
    end

    disp(['Add to "Matlab-PATH" all subfolder from: ' path]);
    addpath(genpath(path));
    
end

function eidors_path = Start_EIDORS(eidors_path)

if nargin == 0
    if ismac
        % Code to run on Mac platform
    elseif isunix
        % Code to run on Linux platform
        eidors_path = '/usr/local/EIDORS/eidors/startup.m';
    elseif ispc;
        % Code to run on Windows platform
        eidors_path = 'C:\EIDORS\eidors\startup.m';
    else
        disp('Platform not supported')
    end
end

if ~exist(eidors_path)
    eidors_path = uigetfile('.m', 'Select File "startup.m" to run EIDORS');
    if isequal(eidors_path,0)
        warndlg('User selected Cancel: EIDORS not started');
        eidors_path = 'EIDORS not started';
        return
    end
end
if ~exist('show_fem')
    disp(['Starting EIDORS from eidors_path: ' eidors_path]);
    run(eidors_path);
    eidors_cache('cache_size', 2*1024^3 ); % 2 GB cache
else
    disp(['EIDORS already started']);
end






end


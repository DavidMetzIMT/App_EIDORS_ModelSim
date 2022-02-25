
classdef Eidors_Toolbox < handle
    %EIDORS_TOOLBOX this class manage the EIDORS toolbox
    % to start, 

    properties
        path_file %
        eidors_path_default
        eidors_path_local
        
    end
    methods

        function output = start(obj, eidors_path_file)
            %START Start the toolbox by determning the path of the 

            % loading default paths from eidors_path_fil and test to start the toolbox

            % if not loaded ask user to give

            % save


        end

        function output = is_running(obj)
            %IS_RUNNING check if the toolbox has been loaded / started
            output=exist('show_fem');
        end

        function output = create_default_eidors_path_file(input)

            eidors_path_default= {'/usr/local/EIDORS/eidors/startup.m', 'C:\EIDORS\eidors\startup.m'};
            eidors_path_local= {'C:\EIDORS\eidors\startup.m'};

            save('eidors_path.mat','eidors_path_default','eidors_path_local' )
            
        end
    end

    methods (Access = private)

        function run_toolbox(obj,path)
            disp(['Starting EIDORS from eidors_path: ' path]);
            run(path);
        end
        
        function output = load(obj, path)

            paths=load(eidors_path_file)

            obj.eidors_path_default= paths.eidors_path_default;
            obj.eidors_path_local= paths.eidors_path_local;
            
        end

        function output = myFun(input)
            [file,path] = uigetfile('.m', 'Select file "startup.m" to run EIDORS toolbox');
            if isequal(file,0)
                warndlg('User selected Cancel: EIDORS not started');
                eidors_path = 'EIDORS not started';
                return
            end
            path= path_join(path,file)
        end
    end

end




function pass = start_eidors(eidors_path_file)

pass =0;
if ~exist(eidors_path_file)
    return;    
end

paths=load(eidors_path_file)

eidors_path_default= {'/usr/local/EIDORS/eidors/startup.m', 'C:\EIDORS\eidors\startup.m'}
eidors_path_local= {''}
% to Improve for ..... for portability!



paths= cat(1, eidors_path_local, eidors_path_default)

for i=1:length(paths)
    path= paths{i};
    if exist(path)

    end
end




load paths

for ...
if exist(path)


% if nargin == 0
%     if ismac
%         % Code to run on Mac platform
%     elseif isunix
%         % Code to run on Linux platform
%         eidors_path = '/usr/local/EIDORS/eidors/startup.m';
%     elseif ispc;
%         % Code to run on Windows platform
%         eidors_path = 'C:\EIDORS\eidors\startup.m';
%     else
%         disp('Platform not supported')
%     end
% end

if ~exist(eidors_path)
    [file,path] = uigetfile('.m', 'Select File "startup.m" to run EIDORS');
    if isequal(file,0)
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


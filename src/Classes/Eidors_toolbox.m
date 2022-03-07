classdef Eidors_toolbox < handle
    %EIDORS_TOOLBOX this class start the EIDORS toolbox
    % to start, 

    properties
        type= 'eidors_toolbox'
        local_path_file = ''; % mat-file containing the local_path
        local_path = ''; % local path of the "startup.m"-file to start EIDORS toolbox 
    end

    properties (Access = private)
        default_path = {'/usr/local/EIDORS/eidors/startup.m', 'C:\EIDORS\eidors\startup.m'}; % Default path for unix and pc
        defauft_local_path_file='eidors_toolbox_local_path.mat';
    end

    methods
        function obj = Eidors_toolbox(varargin)
            %EIDORS_TOOLBOX Constructor
            if nargin==1
                obj.local_path_file=varargin{1};
            end
            obj.search_local_path_file();
            obj.start(obj.local_path_file);
        end

        function output = start(obj, local_path_file)
            %START Start the toolbox
            % first try to strat from the passed local_path_file
            % if passed the path of the used "startup.m"-file to start EIDORS toolbox will be saved for further starts!  
            
            if obj.is_running()
                path= which('startup.m');
                [fPath, fName, fExt] = fileparts(path);
                obj.local_path= path;
                obj.save_local_path();
                return;
            end
            % loading default paths from local_path_file and run the toolbox
            startup_path= obj.get_startup_path();

            success= obj.run_toolbox(startup_path);

            if success
                obj.save_local_path();
            else
                disp('********************************************************')
                disp('***      EIDORS toolbox could not be started!        ***')
                disp('Please start it manually: >> run(".../eidors/startup.m")')
                disp('********************************************************')
            end
        end

        function output = is_running(obj)
            %IS_RUNNING check if the toolbox has been loaded / started
            
            global eidors_objects;            
            output=isfield(eidors_objects,'max_cache_size');%
            output = output && exist('show_fem');
            if output
                disp(['EIDORS Toolbox has been started']);
            end
        end

        function local_settings(obj)
            %LOCAL_SETTINGS Set some special settings of the eidors toolbox
            eidors_cache('cache_size', 2*1024^3 ); % 2 GB cache
        end
        
    end
    
    methods (Access = private)

        function found = search_local_path_file(obj)
            %SEARCH_LOCAL_PATH_FILE search the path of the defauft_local_path_file in matlabpath
            %  if found obj.local_path_file will be set!
    
            found = 0;
            path=which(obj.defauft_local_path_file); % Search in actual matlab path!
            if ~isempty(path)
                obj.local_path_file= path;
                % disp(['Eidors path file automatically found: ' path]);
                found= 1;
            else
                % disp(['Eidors path file not found']);
            end
        end
        
        function startup_path= get_startup_path(obj)
            %GET_STARTUP_PATH Return the path of the "startup.m"-file to start EIDORS toolbox
            %    - it try to get it automatically by testing the :
            %          "local_path" contained in the local_path_file (if found)
            %          or
            %          "default_path"
            %    - if none valid path coud be found the user will be asked to 
            %    select the "startup.m"-file manually
            % if a valid path has been found it will be saved in "obj.local_path"
            %

            % load "local_path" contained in the local_path_file (if found)
            startup_path =  obj.get_startup_path_auto();

            % if none valid path coud be found the user will be asked
            if isempty(startup_path)
                startup_path= obj.get_startup_path_man();
            end

            if ~isempty(startup_path) 
                obj.local_path= startup_path;
            end
        end

        function startup_path =  get_startup_path_auto(obj)
            %GET_STARTUP_PATH_AUTO Return automatically the path of the "startup.m"-file to start EIDORS toolbox
            %   it try to get it automatically by testing the :
            %          "local_path" contained in the local_path_file (if found)
            %          or
            %          "default_path"

            % load "local_path" contained in the local_path_file (if found)
            path= obj.local_path_file;
            if ~isempty(path) & isfile(path)
                file=load(path);
                obj.local_path= file.local_path;
            end
            % test "local_path" and "default_path"
            startup_path= obj.test_default_and_local_path();
            
        end

        function startup_path= get_startup_path_man(obj)
            %GET_STARTUP_PATH_MAN Ask user to select the "startup.m"-file to start EIDORS toolbox
            startup_path='';
            [file,path] = uigetfile('startup.m', 'Select the "startup.m"-file to run EIDORS toolbox');
            if isequal(file,0)
                warndlg('User aborted the start of EIDORS toolbox, please start it manually');
                return;
            end
            startup_path= path_join(path,file);

        end
        
        function valid_path = test_default_and_local_path(obj)
            %TEST_DEFAULT_AND_LOCAL_PATH Test the "local_path" and "default_path" to found a valid path
            % valid path means that the path exist!
            % valid_path is empty if not found

            valid_path='';
            paths= cat(2, {obj.local_path}, obj.default_path);

            for i=1:length(paths)
                path=  paths{i};
                if exist(path)
                    disp(['File "startup.m" found automatically: ' path]);
                    valid_path= path;
                    return;
                end
            end

            disp('File "startup.m" not found automatically!');
        end

        function success= run_toolbox(obj,path)
            %RUN_TOOLBOX Run the "startup.m"-file to start EIDORS toolbox
            % the path of the file have to be passed 
            
            if ~isempty(path) & exist(path) % test path is not empty and exist
                disp(['Running EIDORS toolbox from: ' path]);
                run(path);
            end

            success= obj.is_running(); % test if Eidors has been started

            if success
                obj.local_settings();
            end           
        end

        function output = save_local_path(obj)
            %SAVE_LOCAL_PATH Save the path of the "startup.m"-file to start EIDORS toolbox 

            local_path= obj.local_path;

            [folder, fName, fExt] = fileparts(obj.local_path_file);

            if strcmp(fExt,'')
                folder =obj.local_path_file;
            end
            
            if isempty(obj.local_path_file) | ~exist(obj.local_path_file)
                [folder] = uigetdir(pwd, 'Select folder to save EIDORS toolbox local path');
            end
            obj.local_path_file= path_join(folder,obj.defauft_local_path_file);
            save(obj.local_path_file,'local_path');
        end

    end
end


function obj, succes = load_save(loadSave,dataType,varargin)
% LOADSAVE Standard Load or Save function for multiple Datatyp
%
% IN
% LoadSave : str (not case sensitive)
%                 - 'load'
%                 - 'save' 
% dataType : str (not case sensitive)
%                 - 'chamber'
%                 - 'fmdl'
%                 - 'simulation'
%                 - 'eidors'
% varargin{1} : str (not case sensitive)
%                 - 'user' >> user define where the data are saved
%                 - 'completePathWithmat.-Filename' >> data are saved at given path
%                 - '' (empty str) >> only for save use default path and filename 
% 
% OUT
% obj = loaded obj, var or struct...
% succes = gives 0 if  loading or saving process have been cancelled, 1 if sucessful 


global EIDORS

succes=0;
if ~isempty(varargin)
    option = varargin{1}; % path is directly given as a string
    % path will be choosen by user
else
    option = '';
end

parameters = SetParameters4Process(option, dataType,loadSave);

switch lower(loadSave)
    case 'load' %% Load
        parameters = getFILENAME(parameters);
        load_(parameters);
    case 'save' %% Save
        parameters = setFILENAME(parameters);
        save_(parameters);
    otherwise
        disp('LoadSave Subfunction: please give ''load'' or ''save'' as string')
        
end
succes= parameters.INDX;

%% ========================================================================
%  Internal fucntions =====================================================
%  ========================================================================
    function par = SetParameters4Process(option,dataType,LoadSave)
        par.OPTION=option;
        par.DATATYP=dataType;
        par.Flag_folderISfilename=0;
        switch lower(par.DATATYP)
            case 'chamber' % OK
                par.FIELD= {'chamber','flag'}; % for the first Field must contains a field "self.name"
                par.FILTERSPEC= '*.mat'; % define the file extension of each file to differenciate them
                par.FOLDER = app.Path.ChambersDesigns; %default saving/loading folder
                par.FILENAME =[EIDORS.(par.FIELD{1}).name par.FILTERSPEC(2:end)]; %default saving/loading filename based on the field "self.name"
                par.PROMPT_text = 'Chamber Design '; % text used by loading saving dialogboxes
            case 'fmdl'
                par.FIELD= {'fmdl', 'chamber', 'meshQuality','flag'};
                par.FILTERSPEC= '*_fmdl.mat';
                par.FOLDER = app.Path.fmdl;
                par.FILENAME =[EIDORS.(par.FIELD{1}).name par.FILTERSPEC(2:end)];
                par.Flag_folderISfilename=1;
                par.PROMPT_text = 'Forward model ';
            case 'simulation'
                if strcmpi(LoadSave,'save')
                    % if fmdl is saved than
                    par.FIELD= {'fmdl', 'chamber', 'meshQuality','flag'};
                    par.FILTERSPEC= '*_fmdl.mat';
                    par.FOLDER = app.Path.fmdl;
                    par.FILENAME =[EIDORS.(par.FIELD{1}).name par.FILTERSPEC(2:end)];
                    par.Flag_folderISfilename=1;
                    par.PROMPT_text = 'Forward model ';
                    
                    par.PATH = CreateDefaultPath(par);
                    if exist(par.PATH)
                    else
                        %                         warndlg('Actual Fmdl do not exist');
                        op= par.OPTION;
                        par.OPTION= 'user';
                        par = setFILENAME(par);
                        save_(par)
                        par.OPTION= op;
                    end
                    % the user has maybe changed the name of the fmdl so get the
                    % new name...
                    par.FILENAME =[EIDORS.(par.FIELD{1}).name par.FILTERSPEC(2:end)];
                    par.PATH = CreateDefaultPath(par); % reedit the Path of the fmdl mat-file
                    index= strfind(par.PATH,'\');
                    path_fmdl= par.PATH(1:index(end)-1); % get the Folder Path of the fmdl mat-file
                    par.FOLDER = [path_fmdl];
                else
                    par.FOLDER = [app.Path.fmdl]; % fo simulation open in
                end
                par.FIELD= {'sim', 'Pattern','fmdl','flag','chamber', 'meshQuality'};
                par.FILTERSPEC= '*_sim.mat';
                par.FILENAME =[EIDORS.(par.FIELD{1}).name par.FILTERSPEC(2:end)];
                par.Flag_folderISfilename=1;
                par.PROMPT_text = 'Simulations Results ';
            case 'eidors' % OK
                par.FIELD= {'EIDORS'};
                par.FILTERSPEC= '*.mat';
                par.FOLDER = app.Path.Setups;
                par.FILENAME =[par.FIELD{1} par.FILTERSPEC(2:end)];
                par.PROMPT_text = 'EIDORS_DataSet ';
                
            otherwise
                errordlg('LoadSave_DataElectrodes: please give load or as string')
        end
    end

    function par = getFILENAME(par_in) % only for load
        par = par_in;
        if strcmpi(par.OPTION,'user') % User choose file to be loaded
            TITLE = ['Select a .mat-file to load new ' par.PROMPT_text];
            [file,path, par.INDX] = uigetfile(par.FILTERSPEC,TITLE,par.FOLDER); % select file
            par.PATH= [path file];
        elseif strcmpi(par.OPTION,'') % case desactivated
            par.PATH = CreateDefaultPath(par);
            par.INDX=0; %loading cancelled %% disabling automatic loading of data from par.PATH
            errordlg('Loading cancelled! not enough input argument');
        else % use path given as variable 
            par.INDX=1;
            par.PATH= par.OPTION;
        end
    end

    function load_(par)
        if par.INDX == 0 %if loading cancelled
            warndlg('Loading cancelled!');
        else % loading process
            tmp = load(par.PATH);
            index = strfind(par.PATH,'\');
            helpdlg(['File: ' par.PATH(index(end)+1:end) newline...
                'from folder :' replace(par.PATH(1:index(end)-1),app.Path.CurrentFolder,'...') newline...
                'has been loaded !'],'Loading succesful!')
            if strcmp(par.FIELD{1},'EIDORS')% if par.field is 'EIDORS' EIDORS replace by data contain the file
                EIDORS = tmp.EIDORS;
            else % load the predefined par.field in actual EIDORS
                for i_field= 1:size(par.FIELD,2)
                    EIDORS.(par.FIELD{i_field}) = tmp.eidors_data.(par.FIELD{i_field});
                end
            end
        end
    end

    function par = setFILENAME(par_in)
        par = par_in;
        if strcmpi(par.OPTION,'user') % User choose filename in which data has to be saved
            par.PATH = CreateDefaultPath(par);
            index = strfind(par.PATH,'\');
            if exist(par.PATH) % overwriting handling
                prompt = {[par.PROMPT_text ': ' par.PATH(index(end)+1:end) 'already exists' newline...
                    'in folder:' replace(par.PATH(1:index(end)-1),app.Path.CurrentFolder,'...') '!' newline...
                    'To overwrite it continue, otherwise gives a new ' lower(par.PROMPT_text) 'name!']};
            else
                prompt = {['Save actual ' lower(par.PROMPT_text) 'in file:' par.PATH(index(end)+1:end) newline...
                    'under folder :' replace(par.PATH(1:index(end)-1),app.Path.CurrentFolder,'...') '?' newline...
                    'Otherwise enter an new ' lower(par.PROMPT_text) 'name']};
            end
            
            if strcmp(par.FIELD{1},'EIDORS')
                answer = inputdlg(prompt,['Saving ' par.PROMPT_text],[1],{par.FILENAME});
            else
                answer = inputdlg(prompt,['Saving ' par.PROMPT_text],[1],{EIDORS.(par.FIELD{1}).name});
            end
            
            if isempty(answer)
                par.INDX=0; %cancelled
            else
                par.FILENAME =[replace(answer{1},par.FILTERSPEC(2:end),'') par.FILTERSPEC(2:end)];
                if ~strcmp(par.FIELD{1},'EIDORS')
                    EIDORS.(par.FIELD{1}).name= replace(answer{1},par.FILTERSPEC(2:end),'');
                end
                par.INDX=1;
            end
            par.PATH = CreateDefaultPath(par);
        elseif strcmp(par.OPTION,'')
            par.PATH = CreateDefaultPath(par); %default FOLDER and FILENAME
            par.INDX=1;
        else
            par.PATH= par.OPTION;
            par.INDX=1;
        end
    end

    function save_(par)
        if par.INDX == 0 %if loading cancelled
            warndlg('Saving cancelled!');
        else % saving process            
            delete(par.PATH);
            index= strfind(par.PATH,'\');
            mkdir(par.PATH(1:index(end)-1));
            if strcmp(par.FIELD{1},'EIDORS')% if par.field is 'EIDORS' EIDORS is saved
                save(par.PATH,'EIDORS');
            else % save the predefined par.field from EIDORS
                for i_field= 1:size(par.FIELD,2)
                    eidors_data.(par.FIELD{i_field}) = EIDORS.(par.FIELD{i_field});
                end
                save(par.PATH,'eidors_data');
            end
            index = strfind(par.PATH,'\');
            helpdlg(['File: ' par.PATH(index(end)+1:end) newline...
                'has been saved ' newline...
                'in folder :' replace(par.PATH(1:index(end)-1),app.Path.CurrentFolder,'...') '!'],'Saving succesful!')
        end
    end

    function path = CreateDefaultPath(par) 
    % Create a default Path 
        if par.Flag_folderISfilename==0
            path= [par.FOLDER '\' par.FILENAME];
        else
            path= [par.FOLDER '\' replace(par.FILENAME,par.FILTERSPEC(2:end),'') '\' par.FILENAME];
        end
    end

    function isPath = isPath(path)
        % isPath check if a path:
        % is a valid path (return 1) or already exist (return 2)
        % return 0 if is not a valid path
        isPath=0
        if ~isfolder(path)
            [status, msg] = mkdir(path);
            if status
                % is a valid path
                isPath = 1
                rmdir(path)
            end
        else
            % Folder already exist
            isPath=2
        end
        
        return isPath
        
    end

    function isMatFile = isMatFile(path)
        isMatFile =false

        

        return isMatFile
        
    end
     
end

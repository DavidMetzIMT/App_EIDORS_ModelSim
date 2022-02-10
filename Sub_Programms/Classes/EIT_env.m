classdef EIT_env
    %EIT_env define the enviromment vabiables used for the eit
    
    
    properties
        setup EIT_setup % regroup the data for the chamber/pattern
        fmdl % Eidors_fmdl % the forward model from EIDORS
        imdl % Eidors_imdl % the inverse model from EIDORS
        sim EIT_sim_env % simulation env for simulation with EIDORS
        rec EIT_rec_env %Reconstruction environmnent with EIDORS
        
        % old to move/rename some where else... 
        meshQuality
        % chamber -> moved to EIT_setup
        % Pattern -> moved to EIT_setup
        flag
    end
    
    methods
        function obj = EIT_env()
            %SAVE Save n EIT_env in a mat file
            obj.setup=EIT_setup();
            obj.sim=EIT_sim_env();
            obj.rec=EIT_rec_env();


        end


        function succes = save(obj, folder, filename)
            %SAVE Save an EIT_env in a mat file

            succes=0;     
            par = obj.set_param4saving(folder, filename);

            if par.succes
                succes= obj.save_p(par);
            else
                warndlg('Saving aborted!');
            end
        end

        
        function succes = load(obj, folder, filename)
            %LOAD load an EIT_env mat file and return the contained env variable
            %  
            succes=0 ;
            new_env='';
            par = obj.set_param4loading(folder, filename);

            if par.succes
                new_env, succes= obj.load_p(par);
            else
                warndlg('Loading cancelled!');
            end
        end
    
    end 

    methods (Access=private)

        function [folder, filename] = check_folder_filename(obj, folder, filename)
            if strcmp(folder,'') || ~isaValidFolder(folder)
                folder = pwd; % default
            else
                folder= folder;
            end
            %check filename
            if strcmp(filename,'')
                filename = 'filename'; % default
            else
                filename= filename;
            end
        end
        
        function par = set_param4saving(obj, folder, filename)
            par.ext= '.mat';
            par.filter= ['*' par.ext];
            %check folder, filename
            [par.folder, par.filename] = obj.check_folder_filename(folder, filename)

            promptText = 'Enter file to save environement variables'; % text used by loading saving dialogboxes
            par.filepath= path_join(par.folder, par.filename); 
            [par.filename,par.folder, par.succes] = uiputfile(par.filter,promptText,par.filename);
            par.filepath= path_join(par.folder, par.filename);
            
        end
        
        function sucess= save_p(obj, par)
            delete(par.filepath);
            % create folder (if already exist will raise a warning)
            index= strfind(par.filepath,'\');
            mkdir(par.filepath(1:index(end)-1));
            % save the whole env 
            eit_env= obj;
            % appending .mat
            par.filepath= [replace(par.filepath, par.ext,'') par.ext];
            save(par.filepath,'eit_env');
            sucess = logical(exist(par.filepath));
            
        end

        function par = set_param4loading(obj, folder, filename)
            par.ext= '.mat';
            par.filter= ['*' par.ext];
            %check folder, filename
            [par.folder, par.filename] = obj.check_folder_filename(folder, filename)

            promptText = 'Select file to import environement variables'; % text used by loading saving dialogboxes
            par.filepath= path_join(par.folder, par.filename); 
            [par.filename,par.folder, par.succes] = uigetfile(par.filter,promptText,par.filename);
            par.filepath= path_join(par.folder, par.filename);
        end

        function [new_env, sucess]=  load_p(obj, par)

            if exist(par.filepath)
                tmp = load(par.filepath);
                new_env= tmp.eit_env;
                sucess=1;
            else
                new_env='empty';
                sucess=0;
            end
        end
    
    end
end


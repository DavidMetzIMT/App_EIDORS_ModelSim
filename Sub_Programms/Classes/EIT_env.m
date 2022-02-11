classdef EIT_env < handle
    %EIT_env define the enviromment vabiables used for the eit
    
    
    properties
        setup EIT_setup % regroup the data for the chamber/pattern
        fwd_model Eidors_fmdl % the forward model from EIDORS
        inv_model %Eidors_imdl % the inverse model from EIDORS
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
            obj.fwd_model= Eidors_fmdl();
        end

        function success = save(obj, folder, filename)
            %SAVE Save an EIT_env in a mat file
            success=0;     
            par = obj.set_param4saving(folder, filename);
            if ~par.success
                warndlg('Saving aborted!');
                return;
            end
            success= obj.save_p(par);
        end

        function [new_env, success] = load(obj, folder, filename)
            %LOAD load an EIT_env mat file and return the contained env variable
            success=0 ;
            new_env='';
            par = obj.set_param4loading(folder, filename);
            if ~par.success
                warndlg('Loading cancelled!');
                return;
            end
            [new_env, success]= obj.load_p(par);
        end

        function [fmdl, success] = create_fwd_model(obj, add_text)
            %create the foward model and return the fmdl fpr EIDORS/for plot...

            [shape_str, elec_pos, elec_shape, elec_obj, error] = obj.setup.data_for_ng();
            if error.code
                fmdl =0;
                success=0;
                return
            end

            fmdl = obj.fwd_model.gen_fmdl_ng(...
                obj.setup.chamber,...
                shape_str, elec_pos, elec_shape, elec_obj, add_text);

            success=1;
            
        end

    end 

    methods (Access=private)

        function [folder, filename] = check_folder_filename(obj, folder, filename)
            if (strcmp(folder,'') || ~isaValidFolder(folder))
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
            [par.folder, par.filename] = obj.check_folder_filename(folder, filename);

            promptText = 'Enter file to save environement variables'; % text used by loading saving dialogboxes
            par.filepath= path_join(par.folder, par.filename); 
            [par.filename,par.folder, par.success] = uiputfile(par.filter,promptText,par.filepath);
            par.filepath= path_join(par.folder, par.filename);
        end
        
        function success= save_p(obj, par)
            delete(par.filepath);
            % create folder (if already exist will raise a warning)
            index= strfind(par.filepath,'\');
            mkdir(par.filepath(1:index(end)-1));
            % save the whole env 
            eit_env= obj;
            % appending .mat
            par.filepath= [replace(par.filepath, par.ext,'') par.ext];
            save(par.filepath,'eit_env');
            success = logical(exist(par.filepath));
        end

        function par = set_param4loading(obj, folder, filename)
            par.ext= '.mat';
            par.filter= ['*' par.ext];
            %check folder, filename
            [par.folder, par.filename] = obj.check_folder_filename(folder, filename);

            promptText = 'Select file to import environement variables'; % text used by loading saving dialogboxes
            par.filepath= path_join(par.folder, par.filename); 
            [par.filename,par.folder, par.success] = uigetfile(par.filter,promptText,par.filepath);
            par.filepath= path_join(par.folder, par.filename);
        end

        function [new_env, success]=  load_p(obj, par)
            if exist(par.filepath)
                tmp = load(par.filepath);
                new_env= tmp.eit_env
                success=1;
            else
                new_env='empty';
                success=0;
            end
        end

        function myFun(obj, val)
            obj.val= val
            
        end
    
    end
end

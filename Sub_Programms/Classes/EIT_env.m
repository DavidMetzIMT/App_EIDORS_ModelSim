classdef EIT_env < handle
    %EIT_env define the enviromment vabiables used for the eit
    
    
    properties
        setup EIT_setup % regroup the data for the chamber/pattern
        fwd_model Eidors_fmdl % the forward model from EIDORS
        inv_model Eidors_imdl % the inverse model from EIDORS
        sim EIT_sim_env % simulation env for simulation with EIDORS
        rec EIT_rec_env %Reconstruction environmnent with EIDORS
        
        % old to move/rename some where else... 
        meshQuality
        % chamber -> moved to EIT_setup
        % Pattern -> moved to EIT_setup
        flag
    end

    properties (Access=private)
        FMDL_GEN=0;
        
    end
    
    methods
        function obj = EIT_env()
            %SAVE Save n EIT_env in a mat file
            obj.setup=EIT_setup();
            obj.sim=EIT_sim_env();
            obj.rec=EIT_rec_env();
            obj.fwd_model= Eidors_fmdl();
            obj.inv_model= Eidors_imdl();
            obj.FMDL_GEN=0;
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

            obj.FMDL_GEN=0;
            fmdl =0;
            success=0;

            [shape_str, elec_pos, elec_shape, elec_obj, z_contact, error] = obj.setup.data_for_ng();
            if error.code
                error
                errordlg(error.msg);
                return
            end

            fmdl = obj.fwd_model.gen_fmdl_ng(...
                obj.setup.chamber,...
                shape_str, elec_pos, elec_shape, elec_obj, z_contact, add_text);

            success=1;
            obj.FMDL_GEN=1;
            
        end

        function success = generate_pattern(obj)

            success=0;
            if ~obj.FMDL_GEN % test if an fwd_model has beeen succefully generated
                error= build_error('Generate first a Forward Model!',1);
                errordlg(error.msg);
                return;
            end 
            
            %% Generate the pattern
            [stimulation, meas_select, error] = obj.setup.generate_patterning();
            if error.code
                error
                errordlg(error.msg);
                return;
            end
            %% Set the pattern in the fwd_model
            obj.fwd_model.set_pattern(stimulation, meas_select);

            success=1;
        end

        function set_sim(obj, medium, objects)
            % Medium
            obj.sim.mediumConduct= medium;
            
            % Objects (struct)
            obj.sim.reset_objects();
            for i=1:length(objects)
                object=objects(i);
                obj.sim.add_object(EIT_object(object));           
            end
            
        end

        function solve_fwd(obj, add_object_inFEM)

            if add_object_inFEM==1
                warndlg('add object in FEM is not implemented yet')
            end

            obj.sim.fmdl= obj.fwd_model.fmdl();

            obj.sim.solve_fwd()

            % Load per default meas in rec env
            obj.rec.set_data_meas(obj.sim.data_ih, obj.sim.data_h)
            
        end

        function solve_inv(obj, load_meas_path)

            % set fmdl in imdl
            obj.inv_model.set_fwd_model( ...
                obj.fwd_model);

            % set inv model for rec
            obj.rec.imdl=   obj.inv_model.imdl();

            % load measuremnt if path is given!
            if ~strcmp(load_meas_path,'')
                obj.rec.load_measurements(load_meas_path)
            end
            % solve inverso model
            obj.rec.solve_inv()
            
        end


        
    end 

    % --------------------------------------------------------------------------
    %% PRIVATE METHODS
    % --------------------------------------------------------------------------

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

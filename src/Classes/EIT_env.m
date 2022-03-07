classdef EIT_env < handle
    %EIT_ENV Enviromment used for the simulation reconstruction of EIT measurements using the EIDORS Toolbox
    
    properties
        type='eit_env'
        setup EIT_setup % Regroup the data for the Measeuement setups (chamber electrode, pattern)
        fwd_model Eidors_fmdl % the forward model aslike in EIDORS
        inv_model Eidors_imdl % the inverse model aslike in EIDORS
        sim EIT_sim_env % Simulation env for simulation with EIDORS
        rec EIT_rec_env % Reconstruction environmnent with EIDORS
    end
    
    properties (Access=private)
        FMDL_GEN=0;
    end
    
    methods
        function obj = EIT_env()
            %EIT_ENV Constructor set properties to default values
            obj.setup=EIT_setup();
            obj.sim=EIT_sim_env();
            obj.rec=EIT_rec_env();
            obj.fwd_model= Eidors_fmdl();
            obj.inv_model= Eidors_imdl();
            obj.FMDL_GEN=0;
        end

        function update_from_file(obj, path)
            %UPDATE Update fields with value from new_env
            %       it only update the filed which exist in both environment

            [fPath, fName, fExt] = fileparts(path);
            %set the field from the new env!
            [new_env, success, path ]=  obj.load(fPath,[fName, fExt]);
            if success==0
                return;
            end
            obj.update(new_env)
        end


        function update(obj, new_env)
            %UPDATE Update fields with value from new_env
            %       it only update the filed which exist in both environment

            %set the field from the new env!
            new_f= fieldnames(new_env);
            old_f= fieldnames(obj);
            for i=1:length(new_f)
                field= new_f{i};
                if ~isempty(find(strcmp(old_f, field)))
                    value = getfield(new_env,field);
                    setfield(obj,field,value);
                end
            end
        end

        function success = save_auto(obj, folder, filename)
            %SAVE_AUTO Save automatically the environement in a mat-file 
            %       using the passed folder and filename
            %       if folder/filename don not form a valid path the saving will be aborted
            success=0;
            par = obj.set_param4saving(folder, filename, 1);
            if ~par.success
                % warndlg('Saving aborted!');
                return;
            end
            success= obj.save_env(par.filepath);
        end

        function success = save(obj, folder, filename)
            %SAVE Save an EIT_env in a mat file
            %       the user will be asked to select the mat-fil where to save
            %       the passed folder and filename are used as defaulft values
            %       for the dialog
            
            success=0;
            par = obj.set_param4saving(folder, filename, 0);
            if ~par.success
                % warndlg('Saving aborted!');
                return;
            end
            success= obj.save_env(par.filepath);
        end

        function [new_env, success, path] = load(obj, folder, filename)
            %LOAD Load an EIT_env mat file and return the contained env variable
            %       the user will be asked to select the mat-fil where to load
            %       the passed folder and filename are used as defaulft values
            %       for the dialog
            %       it return also the loaded path
            
            success=0 ;
            new_env='';
            path= '';
            par = obj.set_param4loading(folder, filename);
            if ~par.success
                % warndlg('Loading cancelled!');
                return;
            end
            [new_env, success]= obj.load_env(par.filepath);
            path= par.filepath;
        end

        function [fmdl, success] = create_fwd_model(obj, chamber, elec_layout, add_text)
            %CREATE_FWD_MODEL Create the foward model
            % it returns the fmdl for EIDORS/for plots ... and if creation succeed

            obj.setup.chamber= chamber;
            obj.setup.reset_elec_layout()
            for i=1:length(elec_layout)
                obj.setup.add_elec_layout(elec_layout(i));
            end

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

        function success = generate_pattern(obj, pattern)
            %GENERATE_PATTERN Generate the pattern for the fwd_model
            % it returns if generation succeed

            success=0;
            if ~isa(pattern, 'EIT_pattern')
                return;
            end

            obj.setup.pattern= pattern;
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
            %SET_SIM Set the simulation environement for new mediums and objects

            obj.sim.mediumConduct= medium;
            obj.sim.reset_objects();
            for i=1:length(objects)
                    obj.sim.add_object(objects(i));
            end
        end

        function solve_fwd(obj, add_object_inFEM)
            %SOLVE_FWD Solve in the simulation environement the foward model
            if add_object_inFEM==1
                warndlg('add object in FEM is not implemented yet')
            end

            obj.sim.fmdl= obj.fwd_model.fmdl();
            obj.sim.solve_fwd()

            % Load per default meas in rec env
            obj.rec.set_data_meas(obj.sim.data_ih, obj.sim.data_h)
        end

        function solve_inv(obj, load_meas_path)
            %SOLVE_INV Solve in the reconstruction environement the inverse model of the simulated measurements or loaded measurement
            % to load extern measurement set the path 

            % set fmdl in imdl
            obj.inv_model.fwd_model(obj.fwd_model);

            % set inv model for rec
            obj.rec.imdl= obj.inv_model.imdl();

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

        function par = set_param4saving(obj, folder, filename, autosave)
            %SET_PARAM4SAVING set the parameters for saving (filepath)
            par.ext= '.mat';
            par.filter= ['*' par.ext];
            %check folder, filename
            [par.folder, par.filename] = check_folder_filename(folder, filename);
            par.success=1;
            if autosave == 0
                promptText = 'Enter file to save environement variables'; % text used by loading saving dialogboxes
                par.filepath= path_join(par.folder, par.filename); 
                [par.filename,par.folder, par.success] = uiputfile(par.filter,promptText,par.filepath);
            end
            par.filepath= path_join(par.folder, par.filename);
            % appending .mat
            par.filepath= [replace(par.filepath, par.ext,'') par.ext];
        end
        
        function success= save_env(obj, filepath)
            %SAVE_ENV SAVE an eit enviromment 
            delete(filepath);
            % create folder (if already exist will raise a warning)
            index= strfind(filepath,'\');
            mkdir(filepath(1:index(end)-1));
            % save the whole env 
            eit_env= obj;
            save(filepath,'eit_env');
            success = logical(exist(filepath));
        end

        function par = set_param4loading(obj, folder, filename)
            %SET_PARAM4LOADING set the paarmeter for loading (filepath)
            par.ext= '.mat';
            par.filter= ['*' par.ext];
            %check folder, filename
            [par.folder, par.filename] = check_folder_filename(folder, filename);

            promptText = 'Select file to import environement variables'; % text used by loading saving dialogboxes
            par.filepath= path_join(par.folder, par.filename); 
            [par.filename,par.folder, par.success] = uigetfile(par.filter,promptText,par.filepath);
            par.filepath= path_join(par.folder, par.filename);
        end

        function [new_env, success]=  load_env(obj, filepath)
            %LOAD_ENV Load an eit enviromment 
            % i load only the varaible contained in the mat file having the save
            % class as it self!
            new_env='';
            success=0; 
            if ~exist(filepath)
                return
            end
            tmp = load(filepath); %load the mat file
            field_tmp= fieldnames(tmp);
            for i=1:length(field_tmp)
                field= field_tmp{i}
                cls= class(getfield(tmp, field))
                class(obj)
                if strcmp(class(obj), cls)
                    new_env= getfield(tmp, field);
                    success=1;
                    return;
                end
            end
            
        end
    
    end
end

classdef EIT_dataset < EIT_env
    %EIT_DATASET This class is used for the generation of dataset for AI training
    %   It has as parent EIT_env (which is a handle) > see 'EIT_env' class
    %   
    %   Composition of a dataset:
    % 
    %       - /datetime_dataset_name                    % Dataset top folder
    %       -- datetime_dataset_name_eit_dataset.mat    % Matlab EIT_dataset object
    %       -- datetime_dataset_name_infos2py.mat       % Matlab EIT_dataset object for python
    %       -- /src_data                                % src_data folder
    %       --- src_data_1-10.mat                       % src files containing src data 1 to 10
    %       --- src_data_11-20.mat                      % src files containing src data 11 to 20
    %       --- src_data_21-...
    %       -- /samples                                 % samples for AI folder
    %       --- samples_1-10.mat                        % samples files containing samples 1 to 10
    %       --- samples_11-20.mat                       % samples files containing samples 11 to 20
    %       --- samples_21-...
    %
    % Composition of a src file (e.g. src_data_1-10.mat):
    %           src_data = 10 x 1 EIT_sim_env  (see 'EIT_sim_env' class)
    %
    % Composition of a samples file (e.g. samples_1-10.mat):
    %           X = nMeas x 10 x 4 double % the simulated measurements voltages 
    %           y = nElem x 10 x 2 double   % the simulated conductivity of each FEM element of the fwd_model  


    properties
        
        % name                    % Name of the file to save this env
        src_indx                % Array indicating where the #i src_data is saved
                                % e.g. src_indx = [
                                %           1,2,3,4,5,6,7,8,9,10
                                %           11,12,13,14,15,16,17,18,19,20
                                %           21,...
                                %       ]
                                % src_indx(src_filenames_idx, src_data_idx) = i
                                % e.g. to get the #13 src_data
                                % src_filenames_idx=2 (row)
                                % src_data_idx = 3 (col)
                                % f= load(src_filenames{src_filenames_idx})
                                % src_data_13= f.src_data(src_data_idx)
        src_folder              % Absolute path of src files
        src_filenames           % Name of the src files
        samples_indx            % Equivalent to src_indx for samples
                                % e.g. to get the #13 samples (X, y)
                                % samples_filenames_idx=2 (row)
                                % samples_data_idx = 3 (col)
                                % f= load(samples_filenames{samples_filenames_idx})
                                % X_13= f.X(:,samples_data_idx,:)
                                % y_13= f.y(:,samples_data_idx,:)
        samples_folder          % Absolute path of samples files
        samples_filenames       % Name of the samples files
        % dir_path                % Absolute path of the dataset top folder
        user_entry UserEntry    % User entry for generation of AI datasets
    end

    properties (Access = private)
        time_computation
    end
    
    
    methods

        function obj = EIT_dataset()
            %EIT_DATASET Constructor set properties to default values
            obj.type='eit_dataset';
            obj.user_entry=UserEntry();
            obj.init()
        end


        % **********************************************************************
        % ***UTILS
        % **********************************************************************

        function init(obj)
            %INIT reset the list of filename and indexes and folder!
            obj.src_filenames={};
            obj.src_indx=[];
            src_folder = 'src_data';

            obj.samples_filenames={};
            obj.samples_indx=[];
            samples_folder = 'samples';
        end

        function output = is_done(obj)
            %IS_DONE return if the dataset has been completely generated
            output=0;
            if max(max(obj.src_indx))==obj.nSamples()
                output= 1;
            end            
        end

        function n = nSamples(obj)
            %NSAMPLES Return the number of samples
            %   this value if stored in the user entry!

            n= obj.user_entry.samplesAmount;
        end

        function set.user_entry(obj, user_entry)
            %SETTER of user_entry
            %   only UserEntry object are allowed
            %
            %   after succesfull setting the  name of the dataset is 
            %   automatically updated using the name provided in user_entry 
            if ~isa(user_entry, 'UserEntry')
                error('user_entry is not a User_Entry object')
                return;
            end

            obj.user_entry=user_entry;
            obj.update_name(); % Update name of dataset from the name given in user_entry
        end


        function update_from_file(obj, path) 
            %UPDATE Update fields with value from new_env
            %   it only update the filed which exist in both environment
            %
            %  new implementation for EIT_dataset
            %    adding of :
            %    - rebuild the folder path if the path differ from the original one!
            %       

            [fPath, fName, fExt] = fileparts(path);
            %set the field from the new env!
            [new_env, success, loaded_path]=  obj.load(fPath,[fName, fExt]);
            if success==0
                return;
            end
            
            obj.update(new_env)

            % rebuild the folder path if the path differ from the original one!
            [fPath, fName, fExt] = fileparts(loaded_path);
            if ~strcmp(obj.dir_path, fPath)
                obj.dir_path= fPath;
                obj.build_output_dirs();
                % obj.save_dataset_in_mat();
            end
        end

        % **********************************************************************
        % *** LOADING 
        % **********************************************************************

        function [data, idx_data]=load_data(obj,type,idx)
            %LOAD_DATA Return the src_data corresponding to the indexes passed
            %   indx can be a vector of indexes 

            if ~obj.is_done()
                error('no data in the eit_dataset');
                return;
            end

            idx= reshape(idx,1,[]); %flatten the indx
            idx= unique(idx); %delete doublon
            idx= sort(idx); % sort the vector

            if max(idx)> obj.nSamples
                error('wrong index for src data');
                return;
            end

            % set intern varaibale fro each type of data
            switch type
                case 'src_data'
                    mat_idx= obj.src_indx;
                    files= obj.src_filenames;
                    folder= obj.src_folder;

                case 'samples'
                    mat_idx= obj.samples_indx;
                    files= obj.samples_filenames;
                    folder= obj.samples_folder;
                    voltage=[];
                    conduct=[];
            otherwise
                error("wrong data type 'src_data' or 'samples' ");
                return;
            end

            idx_batch = [];
            for i=1:length(idx)
                [file_idx , pos_in_file ]= find(mat_idx==idx(i));
                idx_batch(file_idx, pos_in_file)=idx(i);
            end

            idx_data2load= (idx_batch > 0) .*[1:size(idx_batch,2)];

            idx_data= [];
            data= [];
            add_all_path(obj.dir_path);
            for file_idx=1:size(idx_batch,1)
                idx_i= nonzeros(idx_batch(file_idx,:));
                idx_in_file= nonzeros(idx_data2load(file_idx,:));
                if isempty(idx_in_file)
                    continue %skip the loding of this file idx as it is empty
                end
                %Loading of the src file and extration of the correponding indx
                file= files{file_idx};
                filepath= path_join(folder, file);
                disp(['Loading src file :' file]);
                f= load(filepath);
                switch type
                    case 'src_data'
                        d_i= f.src_data(idx_in_file);
                        data= cat(1, data, d_i);
                    case 'samples'
                        voltage=cat(2, voltage, f.X(:,idx_in_file,:));
                        conduct=cat(2, conduct, f.y(:,idx_in_file,:));
                        data= AI_sample(voltage, conduct);
                end
                idx_data= cat(1, idx_data, idx_i);
            end
            
        end

        % **********************************************************************
        % *** GENERATION of Samples
        % **********************************************************************

        function obj = generate(obj, dirout)
            %GENERATE generate the samples
            
            %Some initializations
            obj.init()
            obj.new_dir(dirout)
            obj.make_output_dirs();

            % generate all samples
            obj.generate_src_data();

            % prepare samples for AI in python
            obj.extract_samples_4_AI();

        end
        
        function obj= generate_src_data(obj)
            %GENERATE_SRC_DATA Generate all src data for each samples
            %   a src_data is an EIT_sim_env
            %
            %   those src_data are saved batchwise in files to
            %   to deliver memory during generation

            msg=['Generation of ' num2str(obj.nSamples) ' Training Samples'];
            disp([ msg ': started...']);
            
            eidors_cache('off');% batch_size= 10e6; %Bytes
            src_data=[];
            tStart= tic;
            obj.time_computation= tStart;     
            for i=1:obj.nSamples
                new_src_data=obj.build_new_src_data(i);
                obj.display_progress(i); % display the generation progress
                src_data = cat(1,src_data, new_src_data);
                src_data = obj.save_batchwise(src_data);
            end
            eidors_cache('on');
            disp([ msg ': Lasted ' num2str(toc(tStart)) ' seconds']);
        end

        function output = build_new_src_data(obj, indx)
            %BUILD_NEW_SRC_DATA Build, solve and return an EIT_sim_env object
            %   - to build the simulation env user_entry are used to generate
            %   randomly: the medium conductivity and objects contained in 
            %   the chamber 
            %   - it solve the forward problem using the fwd_model saved in the 
            %   EIT_dataset (see parent EIT_env) to obtain the training 
            %   data (img_h, img_ih, data_h, data_ih) 
            %  - the solved simulation env is cleaned befored it is returned to
            %  get rid of the multiple fmdl contained (in sim_env, in each img),
            %  fmdl can be get by calling obj.fwd_model.fmdl(). 
            % Note: the name of the new_src_data generated is set as 
            %       it generation index 

            % Create a random simulation environement
            medium_conduct = random_val_from_range(obj.user_entry.mediumsConductRange);
            object_n = random_val_from_range(obj.user_entry.objectAmountRange);
            tmp_obj=EIT_object();
            for i=1:floor(object_n)
                objects(i)= tmp_obj.generate_random(obj.user_entry, obj.setup.chamber);
            end
            obj.set_sim(medium_conduct, objects);
            obj.sim.noise_SNR= obj.user_entry.SNR;
            obj.sim.name=indx; % memory the index on the sample in the name property of the sim
            
            % Solve forward problem (Generation of the Training data) using
            % obj.fwd_model
            obj.solve_fwd(0);

            %show_fem(obj.sim.img_ih)
            %Return a copy of that simulation env (EIT_sim_env)
            output= obj.sim.copy();
            output.clean_fmdl();
        end 

        function obj=display_progress(obj,indx)
            %DISPLAY_PROGRESS Display progress depending on last indx of the generated src_data
            %   for dataset with samples number < 100 progess will be displayed 
            %   at each data otherwise all 10.

            batch_display= 10;
            if obj.nSamples<=100
                batch_display= 1;
            end

            if mod(indx,batch_display)==0
                time = ['Generation of' num2str(batch_display) ' data lasted: ' num2str(toc(obj.time_computation)) 's'];
                disp(['                 Training Data #', num2str(indx) '/' num2str(obj.nSamples), ';' time] )
                obj.time_computation= tic;
            end
        end

        % **********************************************************************
        % *** SAVING
        % **********************************************************************
        
        function data = save_batchwise(obj, data)
            %SAVE_BATCHWISE Save data in different batch files
            % only suported for following type of data:
            %       - 'EIT_sim_env' > save the src files batchwise
            %       - 'AI_sample' > save the samples files batchwise
            % 

            cls= class(data(1));
            switch cls
                case 'EIT_sim_env'
                    file_size = obj.user_entry.srcFileSize;
                    last_data_indx = data(end).name;
                    first_data_indx = data(1).name;
                    n_data= length(data);
                    type= 'src_data';

                case 'AI_sample'
                    % in that case data is a struct
                    % like data.Voltages(nMeas,nsamples,1:2); 1 for homogenious 2 for inhomogenious
                    %      data.Conduct(nElems,nsamples,1:2);
                    data= data(1);
                    file_size = obj.user_entry.samplesFileSize;
                    last_data_indx = obj.nSamples;% Save all!!! %or size(data.Voltages,2);
                    first_data_indx = 1;
                    n_data = size(data.Voltages,2);
                    type= 'samples';
                otherwise
                    error('wrong data type AI_samples');
                    return;
            end
            

            % save only if bacht size has been reached or all the samples have been generated
            if (n_data < file_size) && (last_data_indx~=obj.nSamples)
                return;
            end

            % create the start/end index for each batch of data
            index= get_list(n_data,file_size);
            index2save = index + first_data_indx - 1;
            % safe each batch file
            for i=1:size(index2save,1)
                i_begin= index2save(i,1);
                i_end = index2save(i,2);
                % create nam of the batch file 
                filename= [ type '_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                %save the index of the data
                i_saved=i_begin:i_end;
                if file_size ~= length(i_saved) % add zeros for last batch
                    i_saved(file_size)=0;
                end
                switch cls
                    case 'EIT_sim_env'
                        obj.src_filenames= cat(1, obj.src_filenames, filename);
                        obj.src_indx= cat(1, obj.src_indx, i_saved);
                        src_data= data(index(i,1):index(i,2));
                        %save the batch file
                        path = path_join(obj.src_folder, filename);      
                        save(path, 'src_data');
                        % save the dataset in case of generation break
                        
                    case 'AI_sample'
                        obj.samples_filenames= cat(1, obj.samples_filenames, filename);
                        obj.samples_indx= cat(1, obj.samples_indx, i_saved);
                        X= data.Voltages(:,index(i,1):index(i,2),:);
                        y= data.Conduct(:,index(i,1):index(i,2),:);
                        %save the batch file
                        path = path_join(obj.samples_folder, filename);      
                        save(path, 'X', 'y');
                end
                obj.save_dataset_in_mat();
            end
            data=[];
            
        end
        
        function extract_samples_4_AI(obj)
            %EXTRACT_SAMPLES_4_AI Extract samples for the AI training 
            %   Extracting data from all generated src_data
            %   of homogeneous and inhomogeneous
            %   data of voltages (data_h.meas and data_ih.meas) and conductivities
            %   (img_h.elem_data and img_ih.elem_data) and combining it into separate
            %   matrices accordingly X_h, X_ih, Y_h, Y_ih for further data processing.

            disp(['Extract samples data for AI (Python):Start...']);
            %load all src_data
            [src_data, idx_src_data]=obj.load_data('src_data',[1:obj.nSamples]);

            nMeas= size(obj.fwd_model.meas_select, 1); 
            nElem= size(obj.fwd_model.elems, 1);
            Voltages = zeros( nMeas , obj.nSamples, 4);% Preallocation
            Conduct  = zeros( nElem ,obj.nSamples, 2); % Preallocation

            for i=1:obj.nSamples
                d=src_data(i);
                Voltages(:,i,1) = d.data_h.meas;
                Voltages(:,i,2) = d.data_ih.meas;
                Conduct(:,i,1) = d.img_h.elem_data;
                Conduct(:,i,2) = d.img_ih.elem_data;
                Voltages(:,i,3) = d.data_hn.meas;
                Voltages(:,i,4) = d.data_ihn.meas;
            end

            data=AI_sample(Voltages,Conduct)

            % reset the samples_indx and samples_filenames
            obj.samples_indx=[];
            obj.samples_filenames={};

            %clean samples_folder
            if exist(obj.samples_folder, 'dir')
                rmdir(obj.samples_folder,'s');
                mkdir(obj.samples_folder);
            end

            data = obj.save_batchwise(data);

            obj.save_dataset_in_mat();         
            obj.make_mat_file4py(obj.dir_path);

            disp(['Extract samples data for AI (Python):Done']);
        end

        
        % function make_mat_file4py(obj)
        %     %MAKE_MAT_FILE4PY Create a mat file with all inforamtions contained in EIT_dataser for python 
        %     %   get fields from eit_dataset
        %     %   and save them in a mat file on the top level

        %     [fPath, fName, fExt] = fileparts(obj.name);
        %     filepath= path_join(obj.dir_path, [fName '_infos2py.mat']);
        %     if exist(filepath, 'file')
        %         delete(filepath )
        %     end
        %     struct= get_structure_nested(obj);

        %     obj.save_fieldnames(filepath, struct, '');
            
        % end
        
        % function save_fieldnames(obj,filename, object, nameupperlevels)
        %     %SAVE_FIELDNAMES Save all fields and subfield of structure/object
        %     % e.g.
        %     % 
        %     %   object:
        %     %       a:
        %     %           a1
        %     %           a2:
        %     %               a21
        %     %               a22
        %     %       b
        %     %       c
        %     %
        %     % mat-file 
        %     %   a__a1
        %     %   a__a2__a21
        %     %   a__a2__a22
        %     %   b
        %     %   c
        %     %
        %     %
        %     %

        %     separator= '__';
        %     % if nargin ==3
        %     %     varname = inputname(3);
        %     %     nameupperlevels= '';
        %     % end

        %     if isstruct(object) || isobject(object)

        %     % try
        %         fields= fieldnames(object,'-full');
        %         for i=1:length(fields)
        %             field= fields{i};
        %             if isempty(nameupperlevels)
        %                 nameup=[field];
        %             else
        %                 nameup=[nameupperlevels separator field];
        %             end
        %             len= max(size(object));
        %             if len > 1
        %                 for j=1:len
        %                     nameup=[nameupperlevels '_' num2str(j-1,'%03.f') separator field];
        %                     obj.save_fieldnames(filename,object(j).(field), nameup);
        %                 end
        %             else
        %                 obj.save_fieldnames(filename,object.(field), nameup);
        %             end
        %         end
        %     else
        %     % catch % if it is a variable then save
        %         varname2save=nameupperlevels;
        %         S.(varname2save) = object;
                
        %         if exist(filename, 'file')
        %             save(filename,'-struct', 'S', '-append' );
        %         else
        %             save(filename,'-struct', 'S');
        %         end
        %     end
        % end
        
        

    end

    methods (Access = private)

        function save_dataset_in_mat(obj)
            %SAVE_DATASET_IN_MAT Save itself in a mat-file
            name = [obj.user_entry.name '_eit_dataset.mat'];
            obj.save_auto(obj.dir_path, name);
        end

        function name= update_name(obj)
            %UPDATE_NAME Build the name out of the 
            obj.name = obj.user_entry.name;
        end
        
        function path = new_dir(obj, dirout)
            %NEW_ACTUAL_PATH Generate a new directory for the generation of new samples
            t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
            if ~exist(dirout,'dir')
                dirout= uigetdir(pwd, 'Select output directory');
            end
            folder_out=[char(t) '_' obj.user_entry.name];  
            path = path_join(dirout, folder_out);
            disp(['Dataset will be saved in:' path])
            obj.dir_path= path;
        end   
        
        function success = build_output_dirs(obj)
            %BUILD_OUTPUT_DIRS Create output directories path for samples
            success=0;
            if isempty(obj.dir_path)
                return;
            end
            % make output dir for Src_file and Samples
            obj.src_folder=path_join(obj.dir_path,'src_data');
            obj.samples_folder=path_join(obj.dir_path,'samples');
            success=1;
        end

        function success = make_output_dirs(obj)
            %MAKE_OUTPUT_DIRS Create output directories for samples
            success=0;
            
            if  ~obj.build_output_dirs()
                return;
            end
            % make output dir for Src_file and Samples
            if ~exist(obj.src_folder)
                mkdir(obj.src_folder);
            end
            if ~exist(obj.samples_folder)
                mkdir(obj.samples_folder);
            end
            success=1;
        end
    end
end

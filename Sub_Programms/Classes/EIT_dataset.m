classdef EIT_dataset < EIT_env
    % to get n number of sets write in >> e.g. Cell_Data_Generator(user_entry)
    %  where 5 indicates the number of generated sets, when input data is described in user_entry.
    %
    % If desired, in "for" loop the pause function can be uncommented to observe every generated set. By pressing any keyboard button, it switching from one set to another.
    %
    % The last "for" loop generates Matrices (obtained data) x (number of data sets):
    %   X_h and X_ih are homogeneous and inhomogeneous measurement data of voltages;
    %   Y_h and Y_ih are homogeneous and inhomogeneous obtaned data of conductivities.
    %
    % run C:\EIDORS\eidors\startup.m
    
    properties
        eit_dataset_filename
        single_data_indx
        src_folder = 'src_data';
        src_filenames
        samples_indx
        samples_folder = 'Samples';
        samples_filenames
        actual_path =''
        oldFolder
    end
    
    methods

        function load_env(obj)
            [new_env, success]=  obj.load('','');
            if success==0
                return;
            end
            %set the field from the env!
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
        
        function loaded_dataset = load_EITDataset(obj,path)
            switch nargin
                case 1
                    path= [];
            end
            
            if ~isempty(path)
                actualpath= path;
            else
                file_typ = '*_eit_dataset.mat';
                prompt = 'Select eit_dataset to load';
                folder = pwd;
                
                [file,path, notCancelled] = uigetfile(file_typ,prompt,folder);
                if notCancelled
                    actualpath = [path file];
                else
                    disp('Loading Cancelled')
                    return
                end
            end
            f= load(actualpath);
            tmp= strfind(actualpath,filesep);
            f.eit_dataset.actual_path=actualpath(1:tmp(end)-1);
            loaded_dataset = f.eit_dataset;
            
        end
        
        function s_data=get_single_data(obj,idx)
            
            if ~isempty(obj.single_data_indx)
                [idx_in_filename , idx_in_batch ]= find(obj.single_data_indx==idx);
                path = [obj.actual_path filesep obj.src_folder filesep obj.src_filenames{idx_in_filename} ];
                disp(path)
                f= load(path);
                s_data= f.single_data(idx_in_batch);
            else
                error('no data in the eit_dataset')
                %                 s_data=[];
            end
            %             [r , c ]= find(obj.samples_indx==idx_single_data)
            
        end
        
        function [X,y]=get_sample(obj,idx)
            
            if ~isempty(obj.samples_indx)
                [idx_in_filename , idx_in_batch ]= find(obj.samples_indx==idx);
                
                path = [obj.actual_path filesep obj.samples_folder filesep obj.samples_filenames{idx_in_filename}];
                disp(path)
                f= load(path);
                
                X= f.X(:,idx_in_batch,:);
                y= f.y(:,idx_in_batch,:);
            else
                error('no data in the eit_dataset')
                %                 X= [];
                %                 y= [];
            end
        end
        
%         function obj=change_actual_folder(obj, cmd)
%             
%             switch cmd
%                 case 'goto_actual_path'
%                     obj.oldFolder = pwd;
%                     cd(obj.actual_path);
%                 case 'get_back_old_folder'
%                     cd(obj.oldFolder);
%             end
%             
%         end

        function obj = generate(obj)
            disp('Start: generating Training Data...')

            tStart= tic;    
            t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
            out_path= uigetdir('./Outputs', 'Select output directory');
            folder_out=[char(t) '_' obj.user_entry.name '_dataset'];  

            obj.actual_path = path_join(out_path, folder_out);

            % make output dir for Src_file and Samples
            obj.src_folder=path_join(obj.actual_path,'src_data')
            mkdir(obj.src_folder);
            obj.samples_folder=path_join(obj.actual_path,'samples')
            mkdir(obj.samples_folder);
            
            obj.eit_dataset_filename = [obj.user_entry.name '_eit_dataset.mat'];
            

            obj.compute_samples();
            obj.save_samples();

        end
        
        function obj= compute_samples(obj,size_file_single_data_max)

            switch nargin
                case 2
                otherwise
                    src_file_size = obj.user_entry.srcFileSize;
            end

            % generation of samples_n TrainingDataset:
            samples_n=obj.user_entry.samplesAmount;
            if samples_n<=0
                disp('Abort samples generation: Number of samples <= 0')
                return;
            end

            % batch_size= 10e6; %Bytes
            eidors_cache('off')
            batch_idx=1;
            tic
            reset=0;
            obj.src_filenames={};
            obj.single_data_indx=[];
            single_data=[];

            tStart= tic;

            for i=1:samples_n

                new_sample=obj.compute_single_sample();

                obj.display_progress(i);
                
                single_data=cat(1,single_data, new_sample);
               
                if (length(single_data) == src_file_size) || (i==samples_n)
                    i_begin= i-length(single_data)+1;
                    i_end = i;
                    index2save= i_begin:i_end
                    filename= ['Single_data_' num2str(i_begin) '-' num2str(i_end) '.mat']
                    obj.src_filenames= cat(1, obj.src_filenames, filename) ;
                    obj.single_data_indx(batch_idx,1:i_end-i_begin+1)=i_begin:i_end;
                    path = path_join(obj.src_folder, filename);      
                    save(path, 'single_data');

                    obj.save_auto(obj.actual_path, obj.eit_dataset_filename);
                    batch_idx=batch_idx+1;
                    single_data=[];
                end
            end
            eidors_cache('on')
            disp(['End: generating Training Data; time ', num2str(toc(tStart)), 's'])
        end

        function output = compute_single_sample(obj)

            % Set sim env
            medium_conduct = random_val_from_range(obj.user_entry.mediumsConductRange);
            object_n = random_val_from_range(obj.user_entry.objectAmountRange);
            tmp_obj=EIT_object();
            for i=1:object_n
                objects(i)= tmp_obj.generate_random(obj.user_entry, obj.setup.chamber)
            end

            obj.set_sim(medium_conduct, objects);
            
            % solve foward
            obj.solve_fwd(0);

            %return a copy of the simulation env
            % TODO maybe clean here the sim env for saving....
            output= obj.sim.copy();
        end 

        
        function obj= save_samples(obj, size_file_samples_max)
            
            switch nargin
                case 2
                otherwise
                    size_file_samples_max = obj.user_entry.samplesFileSize;
            end

            tmp= [];
            for i=1:size(obj.src_filenames,2)
                path = path_join(obj.src_folder, obj.src_filenames{i});  
                
                disp(['Loading src file:',path])
                l=load(path,'single_data');
                tmp= cat(1,tmp, l.single_data)
                % if i==1
                %     tmp = l.single_data;
                % else
                %     tmp= [tmp, l.single_data];
                % end
            end
            
            %rmdir(tmp_path,'s');
            single_data= tmp;
            % Extracting data from all generated sets of homogeneous and inhomogeneous
            % data of voltages (data_h.meas and data_ih.meas) and conductivities
            % (img_h.elem_data and img_ih.elem_data) and combining it into separate
            % matrices accordingly X_h, X_ih, Y_h, Y_ih for further data processing.
            samples_n=obj.user_entry.samplesAmount
            size(obj.sim.fmdl.meas_select, 1)
            size(obj.sim.fmdl.elems, 1)
            Voltages = zeros( size(obj.sim.fmdl.meas_select, 1) , samples_n, 4);
            Conduct  = zeros( size(obj.sim.fmdl.elems, 1) ,samples_n, 2);
            %stat_eval=zeros(samples_n,4);
            
            for i=1:samples_n

                Voltages(:,i,1) = single_data(1,i).data_h.meas;
                Voltages(:,i,2) = single_data(1,i).data_ih.meas;
                Conduct(:,i,1) = single_data(1,i).img_h.elem_data;
                Conduct(:,i,2) = single_data(1,i).img_ih.elem_data;
                % Voltages(:,i,3) = single_data(1,i).data_hn.meas;
                % Voltages(:,i,4) = single_data(1,i).data_ihn.meas;
                
                % for stats on generated data
                % stat_ev(indx_cell,index_sample,:)
                % stat_ev(:,:,1) : pos x
                % stat_ev(:,:,2) : pos y
                % stat_ev(:,:,3) : pos z
                % stat_ev(:,:,4) : radius
                % stat_ev(:,:,5) : LayerConduct 1
                %....
                % stat_ev(:,:,4+i) : LayerConduct i
                % stat_ev(:,:,4+i+1) : LayerRatio 1
                %....
                % stat_ev(:,:,4+i+i) : LayerRatio i
                % stat_ev(:,:,end) : bufferConduct
                
                
                % sd= single_data(i);
                % for j=1:sd.maxNumCells
                %     cell= sd.Cells(j);
                %     t= [cell.Pos cell.Radius cell.LayerConduct cell.LayerRatio sd.bufferConduct];
                %     stat_ev(j, i, :)=reshape(t, 1,1,[]);
                % end
                
                %                 stat_eval(:,i,:)= stat_evaltmp
                
            end
            %             size_data= whos('U').bytes+whos('C').bytes;
            %             nb_save_batch= floor(size_data/size_file_samples_max)+1;
            %             inc= floor(samples_n/nb_save_batch);
            
            nb_save_batch= floor(samples_n/size_file_samples_max)+(mod(samples_n,size_file_samples_max)>0)*1;
            inc= size_file_samples_max;
            obj.samples_indx=[];
            obj.samples_filenames={};
            if exist([obj.actual_path filesep obj.samples_folder], 'dir')
                rmdir([obj.actual_path filesep obj.samples_folder],'s');
                mkdir([obj.actual_path filesep obj.samples_folder]);
            end
            for i=1:nb_save_batch
                i_begin= 1+inc*(i-1);
                i_end = inc*i;
                if i_end > samples_n
                    i_end= samples_n;
                end
                obj.samples_indx(i,1:i_end-i_begin+1)= i_begin:i_end;
                obj.samples_filenames{i}= ['Samples_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                X= Voltages(:,i_begin:i_end,:);
                y= Conduct(:,i_begin:i_end,:);        
                try
                    stat_eval= stat_ev;
                    save([ obj.actual_path, filesep, obj.src_folder, filesep 'Stat_eval.mat'],'stat_eval' )
                    save([ obj.actual_path, filesep, obj.samples_folder, filesep, obj.samples_filenames{i}], 'X', 'y' )
                catch
                    stat_eval= stat_ev(:,i_begin:i_end,:);
                    save([ obj.actual_path, filesep, obj.samples_folder, filesep, obj.samples_filenames{i}], 'X', 'y','stat_eval' )
                end
                
            end
            obj.make_mat_file4py()

        end
        
        % function obj= save_eit_dataset(obj)
        %     eit_dataset = obj;
        %     save([obj.actual_path filesep obj.eit_dataset_filename], 'eit_dataset')
        % end
        
        function make_mat_file4py(obj)
            % todo
            % get fields from eit_dataset
            % and save them in a mat file on the top level
            
            obj.eit_dataset_filename;
            pwd
            filename= [obj.actual_path, filesep, obj.user_entry.net_file_name '_infos2py.mat'];
            obj.save_fieldnames(filename,obj);
            
        end
        
        function save_fieldnames(obj,filename, var, nameupperlevels)
            separator= '_';
            if nargin ==3
                varname = inputname(3);
                nameupperlevels= '';%replace(varname,"_","");
            end
            try
                fields= fieldnames(var,'-full');
                for i=1:length(fields)
                    if isempty(nameupperlevels)
                        nameup=[replace(fields{i},"_","")];
                    else
                        nameup=[nameupperlevels separator replace(fields{i},"_","")];
                    end
                    obj.save_fieldnames(filename,var.(fields{i}), nameup);
                end
            catch % if it is a variable then save
                varname2save=nameupperlevels;
                S.(varname2save) = var;
                
                if exist(filename, 'file')
                    save(filename,'-struct', 'S', '-append' )
                else
                    save(filename,'-struct', 'S')
                end
            end
        end
        
        function obj=display_progress(obj,indx)

            if obj.user_entry.samplesAmount<=100
                batch_display= 1;
            else
                batch_display= 10;
            end

            if mod(indx,batch_display)==0
                disp(['                 Training Data #', num2str(indx), '; time: ', num2str(toc),'s'])
                tic
            end
        end
        

    end
end

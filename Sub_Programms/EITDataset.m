classdef EITDataset
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
    
    properties ( Access = public )
        eit_dataset_filename
        user_entry user_entry
        single_data_filename
        single_data_indx
        singledata_path
        samples_filename
        samples_indx
        samples_path
    end
    
    methods ( Access = public )
        
        function loaded_dataset = load_EITDataset(obj,path)
            switch nargin
                case 1
                    path= []
            end
                  
            if ~isempty(path)
                path2load= path;
            else
                file_typ = '*_eit_dataset.mat';
                prompt = 'Select eit_dataset to load';
                folder = pwd;
                
                [file,path, notCancelled] = uigetfile(file_typ,prompt,folder);
                if notCancelled
                    path2load = [path file];
                    
                else
                    disp('Loading Cancelled')
                    return
                end
            end
            f= load([path2load]);
            loaded_dataset = f.eit_dataset;
            
            
        end
        
        function s_data=get_single_data(obj,idx)
            if ~isempty(obj.single_data_indx)
                [idx_in_filename , idx_in_batch ]= find(obj.single_data_indx==idx);
                f= load(obj.single_data_filename{idx_in_filename});
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
                f= load(obj.samples_filename{idx_in_filename});
                X= f.X(:,idx_in_batch,:);
                y= f.y(:,idx_in_batch,:);
            else
                error('no data in the eit_dataset')
%                 X= [];
%                 y= [];
            end
        end
        function obj = generate_EITDataset(obj, user_entry, out_path)
            
            disp('Start: generating Training Data...')
            obj.user_entry= user_entry;
            tStart= tic;
            obj.singledata_path= [out_path filesep 'Single_data'];
            mkdir(obj.singledata_path)
            obj.eit_dataset_filename = [out_path filesep obj.user_entry.net_file_name '_eit_dataset.mat'];
            obj.samples_path = [out_path filesep 'Samples'];
            mkdir(obj.samples_path)
            if obj.user_entry.num_trainingData > 0
                
                obj= obj.generate_single_data();
                disp(['End: generating Training Data; time ', num2str(toc(tStart)), 's'])
                obj.save_samples();
            else
                disp('Abort samples generation: Number of samples are 0')
                return
            end
            %save
        end
        
        function obj= generate_single_data(obj,size_file_single_data_max)
            switch nargin
                case 2
                otherwise
                    size_file_single_data_max = obj.user_entry.size_file_single_data_max;
            end
            obj.mk_default_fmdl(obj.user_entry);
            % generation of num_samples TrainingDataset:
            num_samples=obj.user_entry.num_trainingData;
%             batch_size= 10e6; %Bytes
            if num_samples<=100
                batch_display= 1;
            else
                batch_display= 10;
            end
            eidors_cache('off')
            batch_idx=1;
            tic
            reset=0;
            obj.single_data_filename={};
            obj.single_data_indx=[];
            
            for i=1:num_samples
                new_sample= mk_EIT_sample(obj.user_entry);
                if mod(i,batch_display)==0
                    obj.display_progress(i);
                end
                if i==1 || reset==1
                    single_data=new_sample;
                    reset=0;
                else
                    single_data(end+1)= new_sample;
                end
                size_of_single_data= whos('single_data').bytes+whos('new_sample').bytes; %get number of byte for singal data + 1
                if (size_of_single_data > size_file_single_data_max) || (i==num_samples)
                    i_begin= i-length(single_data)+1;
                    i_end = i;
                    obj.single_data_filename{batch_idx}= [obj.singledata_path filesep 'Single_data_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                    obj.single_data_indx(batch_idx,1:i_end-i_begin+1)=i_begin:i_end;
                    save(obj.single_data_filename{batch_idx}, 'single_data');
                    obj.save_eit_dataset();
                    batch_idx=batch_idx+1;
                    reset=1;
                end
            end
            eidors_cache('on')
        end
        
        function obj= save_samples(obj, size_file_samples_max)
            switch nargin

                case 2   
                otherwise
                    size_file_samples_max = obj.user_entry.size_file_samples_max;
                    
            end
           obj.single_data_filename
            for i=1:size(obj.single_data_filename,2)
                l=load(obj.single_data_filename{i});
                if i==1
                    tmp = l.single_data;
                else
                    tmp= [tmp, l.single_data];
                end
            end
            %rmdir(tmp_path,'s');
            single_data= tmp;
            % Extracting data from all generated sets of homogeneous and inhomogeneous
            % data of voltages (data_h.meas and data_ih.meas) and conductivities
            % (img_h.elem_data and img_ih.elem_data) and combining it into separate
            % matrices accordingly X_h, X_ih, Y_h, Y_ih for further data processing.
            num_samples=obj.user_entry.num_trainingData;
            U = zeros( length(single_data(1).data_h.meas) , num_samples,4);
            C = zeros( length(single_data(1).img_h.elem_data) ,num_samples,2);
            for i=1:num_samples
                U(:,i,1) = single_data(i).data_h.meas;
                U(:,i,2) = single_data(i).data_ih.meas;
                C(:,i,1) = single_data(i).img_h.elem_data;
                C(:,i,2) = single_data(i).img_ih.elem_data;
                U(:,i,3) = single_data(i).data_hn.meas;
                U(:,i,4) = single_data(i).data_ihn.meas;
            end
            size_data= whos('U').bytes+whos('C').bytes;
            nb_save_batch= floor(size_data/size_file_samples_max)+1;
            inc= floor(num_samples/nb_save_batch);
            obj.samples_indx=[];
            obj.samples_filename={};
            if exist(obj.samples_path, 'dir')
                rmdir(obj.samples_path,'s');
                mkdir(obj.samples_path)
            end
            for i=1:nb_save_batch
                i_begin= 1+inc*(i-1);
                i_end = inc*i;
                if i_end > num_samples
                    i_end= num_samples;
                end
                
                obj.samples_indx(i,1:i_end-i_begin+1)= i_begin:i_end;
                obj.samples_filename{i}= [obj.samples_path filesep 'Samples_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                X= U(:,i_begin:i_end,:);
                y= C(:,i_begin:i_end,:);
                save(obj.samples_filename{i}, 'X', 'y')
                obj.save_eit_dataset();
            end
        end
        
        function obj= save_eit_dataset(obj)
            eit_dataset = obj;
            user_entry= obj.user_entry;
            save(obj.eit_dataset_filename, 'user_entry', 'eit_dataset')
        end
        function obj=display_progress(obj,indx)
            disp(['                 Training Data #', num2str(indx), '; time: ', num2str(toc),'s'])
            tic
        end
        
        function obj=save_tmpfile(obj,path, var)
            save(path, var);
        end
        
        function  obj= mk_default_fmdl(obj,user_entry)
            % here make fmdl... if not loaded from GUI
            if user_entry.load_fmdl ==0 % only for old code
                user_entry.fmdl= ng_mk_cyl_models([0,1, 0.5],[16,1],0);
                % ng_mk_cyl_models(cyl_shape= {height, radius, max size of mesh elems}, elec_pos, elec_shape, extra_ng_code)
                user_entry.fmdl.stimulation = mk_stim_patterns(16,1,[0,1],[0,1],{},1);
                user_entry.fmdl.solve= 'fwd_solve_1st_order';
                user_entry.fmdl.jacobian= 'jacobian_adjoint';
                user_entry.fmdl.system_mat= 'system_mat_1st_order';
            end
        end
    end
end

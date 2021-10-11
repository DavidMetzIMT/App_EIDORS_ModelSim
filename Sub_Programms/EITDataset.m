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
        single_data_indx
        single_data_folder = 'Single_data';
        single_data_filenames
        samples_indx
        samples_folder = 'Samples';
        samples_filenames
        actual_path =''
        oldFolder
    end
    
    methods ( Access = public )
        
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
                path = [obj.actual_path filesep obj.single_data_folder filesep obj.single_data_filenames{idx_in_filename} ];
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
        function obj = generate_eit_dataset(obj, user_entry, out_path)
            disp('Start: generating Training Data...')
            obj.user_entry= user_entry;
            tStart= tic;            
            obj.actual_path = out_path;
            % make output dir for Single_data and Samples
            
            mkdir([obj.actual_path filesep obj.single_data_folder]);
            mkdir([obj.actual_path filesep obj.samples_folder]);
            
            obj.eit_dataset_filename = [obj.user_entry.net_file_name '_eit_dataset.mat'];
            
            if obj.user_entry.num_trainingData > 0
                obj= obj.generate_single_data();
                disp(['End: generating Training Data; time ', num2str(toc(tStart)), 's'])
                obj.save_samples();
            else
                disp('Abort samples generation: Number of samples are 0')
                return
            end
            
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
            obj.single_data_filenames={};
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
                %size_of_single_data= whos('single_data').bytes+whos('new_sample').bytes; %get number of byte for singal data + 1
                size_of_single_data= length(single_data);
                if (size_of_single_data == size_file_single_data_max) || (i==num_samples)
                    i_begin= i-length(single_data)+1;
                    i_end = i;
                    obj.single_data_filenames{batch_idx}= ['Single_data_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                    obj.single_data_indx(batch_idx,1:i_end-i_begin+1)=i_begin:i_end;
                    
                    path= [obj.actual_path filesep obj.single_data_folder];
                    path = [path filesep obj.single_data_filenames{batch_idx}];      
                    save(path, 'single_data');
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
            for i=1:size(obj.single_data_filenames,2)
                path= [obj.actual_path filesep obj.single_data_folder];
                path = [path filesep obj.single_data_filenames{i}];  
                
                disp(path)
                l=load(path,'single_data');
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
            Voltages = zeros( size(obj.user_entry.fmdl.meas_select,1) , num_samples,4);
            Conduct = zeros( size(obj.user_entry.fmdl.elems,1) ,num_samples,2);
            %stat_eval=zeros(num_samples,4);
            
            for i=1:num_samples
                Voltages(:,i,1) = single_data(1,i).data_h.meas;
                Voltages(:,i,2) = single_data(1,i).data_ih.meas;
                Conduct(:,i,1) = single_data(1,i).img_h.elem_data;
                Conduct(:,i,2) = single_data(1,i).img_ih.elem_data;
                Voltages(:,i,3) = single_data(1,i).data_hn.meas;
                Voltages(:,i,4) = single_data(1,i).data_ihn.meas;
                
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
                
                
                sd= single_data(i);
                for j=1:sd.maxNumCells
                    cell= sd.Cells(j);
                    t= [cell.Pos cell.Radius cell.LayerConduct cell.LayerRatio sd.bufferConduct];
                    stat_ev(j, i, :)=reshape(t, 1,1,[]);
                end
                
                %                 stat_eval(:,i,:)= stat_evaltmp
                
            end
            %             size_data= whos('U').bytes+whos('C').bytes;
            %             nb_save_batch= floor(size_data/size_file_samples_max)+1;
            %             inc= floor(num_samples/nb_save_batch);
            
            nb_save_batch= floor(num_samples/size_file_samples_max)+(mod(num_samples,size_file_samples_max)>0)*1;
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
                if i_end > num_samples
                    i_end= num_samples;
                end
                obj.samples_indx(i,1:i_end-i_begin+1)= i_begin:i_end;
                obj.samples_filenames{i}= ['Samples_' num2str(i_begin) '-' num2str(i_end) '.mat'];
                X= Voltages(:,i_begin:i_end,:);
                y= Conduct(:,i_begin:i_end,:);        
                try
                    stat_eval= stat_ev;
                    save([ obj.actual_path, filesep, obj.single_data_folder, filesep 'Stat_eval.mat'],'stat_eval' )
                    save([ obj.actual_path, filesep, obj.samples_folder, filesep, obj.samples_filenames{i}], 'X', 'y' )
                catch
                    stat_eval= stat_ev(:,i_begin:i_end,:);
                    save([ obj.actual_path, filesep, obj.samples_folder, filesep, obj.samples_filenames{i}], 'X', 'y','stat_eval' )
                end
                obj.save_eit_dataset();
            end
            obj.make_mat_file4py()

        end
        
        function obj= save_eit_dataset(obj)
            eit_dataset = obj;
            save([obj.actual_path filesep obj.eit_dataset_filename], 'eit_dataset')
        end
        
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
            disp(['                 Training Data #', num2str(indx), '; time: ', num2str(toc),'s'])
            tic
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

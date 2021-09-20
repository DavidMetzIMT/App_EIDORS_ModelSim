classdef Cell_Data_Generator
    
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
        single_data TrainingDataset
        user_entry user_entry
        Samples
        num_samples
    end
    
    methods ( Access = public )
        function obj = Cell_Data_Generator(user_entry)
            obj.user_entry= user_entry;
            disp('Start: generating Training Data...')
            obj.num_samples = user_entry.num_trainingData;
            if obj.num_samples > 0
                obj= obj.Generate_single_data(user_entry);
                disp('End: generating Training Data')
            else
                disp('Abort samples generation: Number of samples are 0')
                return
            end
        end
        
        function obj= Generate_single_data(obj,user_entry)
            % here make fmdl... if not loaded from GUI
            if user_entry.load_fmdl ==0 % only for old code
                chamber_radius = user_entry.chamber_radius;
                chamber_height = user_entry.chamber_height;
                mesh_size = user_entry.mesh_size;
                user_entry.fmdl= ng_mk_cyl_models([chamber_height,chamber_radius, mesh_size],[16,1],0);
                % ng_mk_cyl_models(cyl_shape= {height, radius, max size of mesh elems}, elec_pos, elec_shape, extra_ng_code)
                user_entry.fmdl.stimulation = mk_stim_patterns(16,1,[0,1],[0,1],{},1);
                user_entry.fmdl.solve= 'fwd_solve_1st_order';
                user_entry.fmdl.jacobian= 'jacobian_adjoint';
                user_entry.fmdl.system_mat= 'system_mat_1st_order';
            end
            
            % generation of n (= num_trainingData) number of sets from class TrainingDataset:
            if obj.num_samples<=100
                mod_t= 5;
            elseif obj.num_samples<=10000
                mod_t=10;
            elseif obj.num_samples<=1000000
                mod_t=500;
            end
            t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
            tmp_path= [pwd filesep 'tmp' char(t)];
            mkdir(tmp_path)
            j=1;
            k=1;
            for i=1:obj.num_samples
                single_data(k) = TrainingDataset(user_entry);
                k=k+1;
                if mod(i,mod_t)==0                
                    disp(['                 Training Data #', num2str(i)])
                    file2save{j}= [tmp_path filesep 'tmp' num2str(j) '.mat'];
                    
                    save(file2save{j}, 'single_data')
                    j=j+1;
                    k=1;
                end
            end
            
            obj.file2save= file2save;
            
            for i=1:size(file2save,2)
                l=load(file2save{i});
                if i==1
                    tmp = l.single_data;
                else
                    tmp= [tmp, l.single_data];
                end
            end
            
            rmdir(tmp_path,'s')
            
            obj.single_data= tmp;
            % Extracting data from all generated sets of homogeneous and inhomogeneous
            % data of voltages (data_h.meas and data_ih.meas) and conductivities
            % (img_h.elem_data and img_ih.elem_data) and combining it into separate
            % matrices accordingly X_h, X_ih, Y_h, Y_ih for further data processing.
            
            obj.Samples.X_h = zeros( length(obj.single_data(1).data_h.meas) , obj.num_samples);
            obj.Samples.X_ih = zeros( length(obj.single_data(1).data_ih.meas) , obj.num_samples);
            obj.Samples.Y_h = zeros( length(obj.single_data(1).img_h.elem_data) , obj.num_samples );
            obj.Samples.Y_ih = zeros( length(obj.single_data(1).img_ih.elem_data) , obj.num_samples);
            for i=1:obj.num_samples
                obj.Samples.X_h(:,i) = obj.single_data(i).data_h.meas;
                obj.Samples.X_ih(:,i) = obj.single_data(i).data_ih.meas;
                obj.Samples.Y_h(:,i) = obj.single_data(i).img_h.elem_data;
                obj.Samples.Y_ih(:,i) = obj.single_data(i).img_ih.elem_data;
                obj.Samples.X_ihn(:,i) = obj.single_data(i).data_ihn.meas;
            end
        
           
        end
        function obj= save_samples(obj,path)
            X_h = obj.Samples.X_h;
            X_ih =obj.Samples.X_ih;
            Y_h =obj.Samples.Y_h;
            Y_ih = obj.Samples.Y_ih;
            X_ihn=obj.Samples.X_ihn;
            
            save(path, 'X_h', 'X_ih','Y_h', 'Y_ih' ,'X_ihn')
        end
    end
end

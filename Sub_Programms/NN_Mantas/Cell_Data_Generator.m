classdef Cell_Data_Generator
    
    % to get n number of sets write in >> e.g. Cell_Data_Generator(user_entry, 5)
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
        TrainingSet
    end
    
    methods ( Access = public )
        function obj = Cell_Data_Generator(user_entry)
            
            disp('Start: generating Training Data...')
            num_trainingData = user_entry.num_trainingData;
            % here make fmdl...
            if user_entry.load_fmdl ==0
                chamber_radius = user_entry.chamber_radius;
                chamber_height = user_entry.chamber_height;
                mesh_size = user_entry.mesh_size;
                user_entry.fmdl= ng_mk_cyl_models([chamber_height,chamber_radius, mesh_size],[16,1],0);
                % ng_mk_cyl_models(cyl_shape= {height, radius, max size of mesh elems}, elec_pos, elec_shape, extra_ng_code)
                user_entry.fmdl.stimulation = mk_stim_patterns(16,1,[0,1],[0,1],{},1);
                user_entry.fmdl.solve= 'fwd_solve_1st_order';
                user_entry.fmdl.jacobian= 'jacobian_adjoint';
                user_entry.fmdl.system_mat= 'system_mat_1st_order';
                
            else
                user_entry.fmdl=EIDORS.fmdl;
            end
            
            % generation of n (= num_trainingData) number of sets from class TrainingDataset:
            obj.user_entry= user_entry;
            
            %parpool('local', 4);
            for i=1:num_trainingData
                disp(['                 Training Data #', num2str(i)])
                single_data(i) = TrainingDataset(user_entry);
            end
            delete(gcp('nocreate'))
            obj.single_data= single_data;
            % Extracting data from all generated sets of homogeneous and inhomogeneous
            % data of voltages (data_h.meas and data_ih.meas) and conductivities
            % (img_h.elem_data and img_ih.elem_data) and combining it into separate
            % matrices accordingly X_h, X_ih, Y_h, Y_ih for further data processing.
            obj.TrainingSet.X_h = zeros( length(obj.single_data(1).data_h.meas) , num_trainingData);
            obj.TrainingSet.X_ih = zeros( length(obj.single_data(1).data_ih.meas) , num_trainingData);
            obj.TrainingSet.Y_h = zeros( length(obj.single_data(1).img_h.elem_data) , num_trainingData);
            obj.TrainingSet.Y_ih = zeros( length(obj.single_data(1).img_ih.elem_data) , num_trainingData);
            for i=1:num_trainingData
                obj.TrainingSet.X_h(:,i) = obj.single_data(i).data_h.meas;
                obj.TrainingSet.X_ih(:,i) = obj.single_data(i).data_ih.meas;
                obj.TrainingSet.Y_h(:,i) = obj.single_data(i).img_h.elem_data;
                obj.TrainingSet.Y_ih(:,i) = obj.single_data(i).img_ih.elem_data;
                obj.TrainingSet.X_ihn(:,i) = obj.single_data(i).data_ihn.meas;
            end
            
            
            disp('End: generating Training Data')
        end
    end
    
end


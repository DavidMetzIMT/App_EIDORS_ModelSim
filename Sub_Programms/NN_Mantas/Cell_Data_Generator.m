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
            % generation of n (= num_trainingData) number of sets from class TrainingDataset:
            for i=1:num_trainingData
                disp(['                 Training Data #', num2str(i)])
                obj.single_data(i) = TrainingDataset(user_entry);
            end
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
            disp('Stop: generating Training Data')
        end
    end
    
end


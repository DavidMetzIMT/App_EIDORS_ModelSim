function [element_data,element_data_n] = Net_solver(user_entry, TrainingsDataSet)

%this function uses Neural Network (NN) inverse solver, which was generated after
%training NN and should be saved in a file defined in a 'user_entry.net_file_name'.
% In a 'voltage' variable there is generated information about voltage (input).
tic
l=load([user_entry.net_file_name]);

% nets = load('Trained_Network.mat', 'nets')
% @mantas hier you have just load it in the worksapce... and as a function hier I would rather

if isempty(gcp('nocreate'))
    delete(gcp('nocreate'))
end
useGPUs = [1];
parpool('local', numel(useGPUs));

spmd
    gpuDevice(useGPUs(labindex))
end

parfor i=1:length(TrainingsDataSet.conduct_element)
    i
   element_data(i,:) = sim(l.nets{i},TrainingsDataSet.data_ih.meas,'useParallel','no','useGPU','yes','showResources','yes'); % here we have to look how to mae it flexible...
   element_data_n(i,:) = sim(l.nets{i},TrainingsDataSet.data_ihn.meas,'useParallel','no','useGPU','yes','showResources','yes');
end
delete(gcp('nocreate'))
toc
end
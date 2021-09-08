function [net, nets, time_train_h, tr] = Neural_Network(user_entry, train_data)     % Artificial Neural Network code
disp('Start: Training of Neural Network...')
tic
% X'- input matrix 96 x 50000 of training cases
% Y'- output matrix 2883 x 50000 of training cases
% Choose a Training Function
trainFcn = 'trainlm';% In this case Levenberg-Marquardt backpropagation was chosen
trainFcn = 'trainscg'; %thi is GPU supported....
hiddenLayerSize = 10; % Choose a number of hidden layers
net = fitnet(hiddenLayerSize,trainFcn); % Create a fitting network under variable 'net'
% Choose input and output pre/post-processing functions
% 'removeconstantrows' - remove matrix rows with constant values
% 'mapminmax' - map matrix row minimum and maximum values to [-1 1]

% net.input.processFcns = {'removeconstantrows','mapminmax'};
% net.output.processFcns = {'removeconstantrows','mapminmax'};

net.input.processFcns = {'mapminmax'};
net.output.processFcns = {'mapminmax'};

% Setup division of data for training, validation, testing
net.divideFcn = 'dividerand'; % Divide data randomly
net.divideMode = 'sample'; % Divide up every sample
net.divideParam.trainRatio = 70/100; % 70% of cases is allocated for training
net.divideParam.valRatio = 15/100; % 15% of cases is allocated for validation
net.divideParam.testRatio = 15/100; % 15% of cases is allocated for testing
net.performFcn = 'mse'; % Mean Squared Error will be used for performance evaluation

x = train_data.TrainingSet.X_ih;  % need to try with (-train_data.TrainingSet.X_h) %input = voltage
y = train_data.TrainingSet.Y_ih;  % need to try with (-train_data.TrainingSet.Y_h) %known output = conductivity

N=length(y(:,1)); % The resolution of output picture grid

if ~isempty(gcp('nocreate'))
    delete(gcp('nocreate'))
end
useGPUs = [1];
parpool('local', numel(useGPUs));

spmd
    gpuDevice(useGPUs(labindex))
end

parfor i=1:50 % Start 'for' loop with parallel computing
    disp(i)
    % Train the network. The variable 'nets_for_pixels' is a structure that consists of 2883
    % separately trained neural networks.
    [nets{i},tr{i}] = train(net,x,y(i,:),'useParallel','no','useGPU','yes','showResources','yes'); 
    
end % End 'parfor' loop

delete(gcp('nocreate'))
disp('Stop: Training of Neural Network...')
time_train_h= toc/60/60;

end
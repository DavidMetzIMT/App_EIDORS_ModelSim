function filename = Neural_Network(user_entry, train_data)     % Artificial Neural Network code
tic
disp('Start: Training of Neural Network...')
% X'- input matrix 96 x 50000 of training cases
% Y'- output matrix 2883 x 50000 of training cases
% Choose a Training Function
trainFcn = 'trainlm'; % In this case Levenberg-Marquardt backpropagation was chosen
hiddenLayerSize = 10; % Choose a number of hidden layers
net = fitnet(hiddenLayerSize,trainFcn); % Create a fitting network under variable 'net'
% Choose input and output pre/post-processing functions
% 'removeconstantrows' - remove matrix rows with constant values
% 'mapminmax' - map matrix row minimum and maximum values to [-1 1]
net.input.processFcns = {'removeconstantrows','mapminmax'};
net.output.processFcns = {'removeconstantrows','mapminmax'};
% Setup division of data for training, validation, testing
net.divideFcn = 'dividerand'; % Divide data randomly
net.divideMode = 'sample'; % Divide up every sample
net.divideParam.trainRatio = 70/100; % 70% of cases is allocated for training
net.divideParam.valRatio = 15/100; % 15% of cases is allocated for validation
net.divideParam.testRatio = 15/100; % 15% of cases is allocated for testing
net.performFcn = 'mse'; % Mean Squared Error will be used for performance evaluation

x = train_data.TrainingSet.X_ih;  % need to try with (-train_data.TrainingSet.X_h) %input = voltage
x = train_data.TrainingSet.X_ihn;  % need to try with (-train_data.TrainingSet.X_h) %input = voltage
y = train_data.TrainingSet.Y_ih;  % need to try with (-train_data.TrainingSet.Y_h) %known output = conductivity

N=length(y(:,1)); % The resolution of output picture grid
parfor i=1:N % Start 'for' loop with parallel computing
    % Assign an i-th row of reference cases to the variable t. Each of the 2883 lines corresponds
    % to one pixel of the output image
    t = y(i,:);  %target
    % Train the network. The variable 'nets_for_pixels' is a structure that consists of 2883
    % separately trained neural networks.
    [nets{i},~] = train(net,x,t);
end % End 'parfor' loop

t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');

% filename= [user_entry.net_file_name '_' char(t) '.mat'];
filename= user_entry.net_file_name;
save(filename, 'user_entry', 'net','nets') %network data is saved in user defined file (and folder)

disp(['Trained Neural Network saved in: ' filename])
disp('Stop: Training of Neural Network...')
toc

end
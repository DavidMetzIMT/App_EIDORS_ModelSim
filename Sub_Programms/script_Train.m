clear
ask4Load=0;


%% Please give an folder name for the results
folder_out= 'test_user'
folder_out=['Train_' folder_out]
%% Add all the Subfolder of the App
current_path= pwd;
out_path= [current_path '\Outputs'];
mkdir(out_path);
out_path= [current_path '\Outputs\' folder_out];
mkdir(out_path);
addpath([current_path '\Sub_Programms'])
AddAllSubFolders(current_path)

%% Start EIDORS Toolbox
Start_EIDORS()

%% Init the protocol???
t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
proto_fid=fopen([out_path '\' 'Protocol_' char(t) '.txt'],'w');
fprintf(proto_fid,['Protocol Init' '\n']);
fprintf(proto_fid,['Date time: ' char(t) '\n']);

%% define User entry
user_entry = user_entry();

%for now, Neural Network solver works fine with following data:
% here you can also open an dialog
title_ = ['Select a file to load user_enty '];
folder= current_path;
notCancelled=0;
if ask4Load
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
end
%load_file_with_user_entry = 'user_entry_1_IMT0616.mat';
if notCancelled
    file2load=[path file];
    l = load(file2load);
    user_entry=l.user_entry
    fprintf(proto_fid,['user_entry loaded from: ' replace(file2load, '\','\\') '\n']);
else
    %TODO init user_entry with default values
    user_entry=init_user_entry(user_entry);
    
    
end
user_entry.net_file_name = folder_out;% PLEASE Ohne .mat   % file name, which contains suitable nets for invers solving

if 1
%% #####################################################
    % Here change user entry
    %  ####################################################
%     user_entry.net_file_name = folder_out;% PLEASE Ohne .mat   % file name, which contains suitable nets for invers solving
     user_entry.load_fmdl =0;                             % get the fmdl from GUI
%     user_entry.range_num_of_cells = [1 2];
    %user_entry.range_cell_conductivity = [1.5, 1.5 , 1 ; 1, 1, 0.3; 0.5, 0.5, 0.1];         % 5 or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
%     user_entry.withcells = 1;
    user_entry.num_trainingData = 3;                  % the number of sets for generating training data
    user_entry.NN = 0; % execute training
    % #####################################################
end


% Save user entry
file2save = [out_path '\' user_entry.net_file_name '_user_entry' '.mat'];
save(file2save, 'user_entry')
% Update protocol
fprintf(proto_fid,['user_entry saved in: ' replace(file2save, '\','\\') '\n']);


%% Training Dataset
% here you can also open an dialog
title_ = ['Select a file to load Training Dataset '];
folder= current_path;
notCancelled=0;
if ask4Load
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
end
if notCancelled
    file2load=[path file];
    train_dataset = load(file2load, 'TrainingSet')
    trainset_filename= file2load;
    fprintf(proto_fid,['Train dataset loaded from : ' replace(file2load, '\','\\') '\n']);
else
    % if cancelled than
    % rng(1223)% to get all teh time same random generation...
    train_dataset = Cell_Data_Generator(user_entry);
    fprintf(proto_fid,['Train dataset generated ' '\n']);
    % Save Traindataset with user_entry in case of need of traceback...
    file2save = [out_path '\' user_entry.net_file_name '_train_dataset' '.mat'];
    save(file2save, 'user_entry', 'train_dataset')
    % Update protocol
    fprintf(proto_fid,['Train dataset saved in: ' replace(file2save, '\','\\') '\n']);
end

%% Plot some sample of trained data!
figName= 'some Samples of generated data';

clf
h= getCurrentFigure_with_figName(figName);

nb_samples=3;
for sample=1:nb_samples
    img = train_dataset.single_data(sample).img_ih;
    data=train_dataset.single_data(sample).data_ih.meas;
    
    subplot(nb_samples,2,(sample-1)*2+1)
    title(['Conduct Sample# ' num2str(sample)]);
    h= show_fem(img,[1,0,0]);
    set(h,'EdgeColor','none');
    
    subplot(nb_samples,2,sample*2)
    title(['Voltages Sample# ' num2str(sample)]);
    plot(data)
end

%% Train

if user_entry.NN == 1
    
    [net, nets,time_train_h, tr]= Neural_Network(user_entry,train_dataset);
    file2save= [out_path '\' user_entry.net_file_name '_trained_net' '.mat'];
    
    save(file2save, 'user_entry', 'net','nets') %network data is saved in user defined file (and folder)
    disp(['Trained Neural Network saved in: ' file2save])
    fprintf(proto_fid,['Training time in hours:  %f\n'], time_train_h);
    fprintf(proto_fid,['Trained net saved in: ' replace(file2save, '\','\\') '\n']);
end

fclose(proto_fid)

function user_entry=init_user_entry(user_entry)
user_entry.net_file_name = 'Default';   % file name, which contains suitable nets for invers solving
user_entry.load_fmdl =0;                             % get the fmdl from GUI
user_entry.chamber_type = 'circle';                 % 'circle' or 'rectangle' defines chamber shape and objects coordinates
user_entry.chamber_radius = 1;                    % 1 indicates radius of the buffer(chamber)
user_entry.chamber_height = 0;                      % 0 indicates 2D object, number indicates the height of 3D chamber
user_entry.mesh_size = 0.035;                             % max size of mesh elems

user_entry.range_num_of_cells = [1 4];              % 5 or e.g [5 10], one number indicates the maximum possible number of cells, two numbers means the range of possible number of cells, e.g. [5 10] from 5 to 10 cells
user_entry.range_buffer_conductivity = [2 3];       % 5 or e.g [5 10], one number indicates the maximum possible conductivity of the buffer, two numbers means the range of possible conductivity of the buffer
user_entry.range_cell_conductivity = [1.5, 1.5 , 1 ; 1, 1, 0.3; 0.5, 0.5, 0.1];         % 5 or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
user_entry.withcells = 1;
% user_entry.range_cell_conductivity = [1, 1; 0.72, 0.72];         % 5 or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells

user_entry.range_cell_radius = [0.1 0.4];           % 0.25 or e.g [0.5 1.0], one number indicates the maximum possible radius of cells, two numbers means the range of possible radius of cells
user_entry.cell_nucleus = 1;                        % if 1 - depicts cell nucleus with bigger condutivity, if 0 - no nucleus is depicetd

user_entry.inv_solver_name = 'GN';                  % 'GN' (for Gauss Newton one step), 'TV' (for Total Variation/PDIPM)' or 'NN' (for Neural Network solver)
%@Mantas: you don't need it
%user_entry.invSolver = 1;                           % 1 indicates the use of inv_solver, if 0 - inv_solver is not used

user_entry.SNR = 20;                                % noise ratio

user_entry.NN = 1;                                  % 1 indicates the activation of Neural network

user_entry.num_trainingData = 5;                  % the number of sets for generating training data
user_entry.mk_antibodies=0; % test
end


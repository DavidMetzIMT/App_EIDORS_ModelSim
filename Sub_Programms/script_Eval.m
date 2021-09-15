clear

ask4Load=1;
notCancelled=0;
%% Please give an folder name for the results
folder_out= 'Test_Mantas'
folder_out=['Eval_' folder_out]
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
proto_fid=fopen([out_path '\' 'Eval_protocol' char(t) '.txt'],'w');
fprintf(proto_fid,['Protocol Init' '\n']);
fprintf(proto_fid,['Date time: ' char(t) '\n']);

%% define User entry
user_entry = user_entry();

%for now, Neural Network solver works fine with following data:
% here you can also open an dialog
title_ = ['Select a file to load user_enty '];
folder= current_path;
if ask4Load
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
end
%load_file_with_user_entry = 'user_entry_1_IMT0616.mat';
if notCancelled
    file2load=[path file];
    tmp = load(file2load, 'user_entry');
    user_entry=tmp.user_entry
    fprintf(proto_fid,['user_entry loaded from: ' replace(file2load, '\','\\') '\n']);
else
    return
end

user_entry.num_trainingData = 5;

%% Evaluation Dataset
title_ = ['Select a file to load eval Dataset '];
folder= current_path;
if ask4Load
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
end
if notCancelled
    file2load=[path file];
    eval_dataset = load(file2load, 'eval_dataset');
    trainset_filename= file2load;
    fprintf(proto_fid,['Eval dataset loaded from : ' replace(file2load, '\','\\') '\n']);
else
    % if cancelled than
    eval_dataset = Cell_Data_Generator(user_entry);
    fprintf(proto_fid,['Eval dataset generated ' '\n']);
    % Save Traindataset with user_entry in case of need of traceback...
    file2save = [out_path '\' user_entry.net_file_name '_eval_dataset' '.mat'];
    save(file2save, 'user_entry', 'eval_dataset')
    % Update protocol
    fprintf(proto_fid,['Train dataset saved in: ' replace(file2save, '\','\\') '\n']);
end

%% Plot some sample of Eval data!
figName= 'some Samples of generated data';

clf
h= getCurrentFigure_with_figName(figName);

nb_samples=3;
for sample=1:nb_samples
    img = eval_dataset.single_data(sample).img_ih;
    data=eval_dataset.single_data(sample).data_ih.meas;
    
    subplot(nb_samples,2,(sample-1)*2+1)
    title(['Conduct Sample# ' num2str(sample)]);
    show_fem(img,[1,1,0]);
    
    subplot(nb_samples,2,sample*2)
    title(['Voltages Sample# ' num2str(sample)]);
    plot(data)
end


%% Testing of the NN
figName= 'Results  from reconstruction of some test data';
clf
h= getCurrentFigure_with_figName(figName);

title_ = ['Select a file to load NN '];
folder= current_path;
if ask4Load
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
end
if notCancelled
    file2load=[path file];
    fprintf(proto_fid,['NN loaded from : ' replace(file2load, '\','\\') '\n']);
else
    return
end

user_entry.net_file_name=file2load;

% plot >> todo make a function of integrate it to a class
for i = 1:user_entry.num_trainingData
    x = eval_dataset.single_data(i);
    
    tic
    user_entry.inv_solver_name='GN';
    gn_data = invSolver(user_entry, x);
    disp(['GN Inverse solver elapsed ' num2str(toc) ' s'])
    
    tic
    user_entry.inv_solver_name='TV';
    tv_data = invSolver(user_entry, x);
    disp(['TV Inverse solver elapsed ' num2str(toc) ' s'])
    
    tic
    user_entry.inv_solver_name='NN';
    nn_data = invSolver(user_entry, x);
    disp(['Inverse NN solver elapsed ' num2str(toc) ' s'])
    
    % nn_data = tv_data
    
    % TODO calulate MSE, ICC, etc.. to evaluate the NN..
    %
    
    y_ref = eval_dataset.single_data(i).img_ih.elem_data; %defining reference output (conductivity) of nodes
    y_rec_gn = gn_data.iimg.elem_data;                    %defining reconstructed by gn output (conductivity) of nodes without noise
    y_rec_tv = tv_data.iimg.elem_data;                    %defining reconstructed by tv output (conductivity) of nodes without noise
    y_rec_nn = nn_data.iimg.elem_data;                    %defining reconstructed by nn output (conductivity) of nodes without noise
    %%
    fprintf(proto_fid,'coeff GN TV NN\n');
    %Mean Squared Error (MSE):
    % MSE.gn = sum((y_ref-y_rec_gn).^2)/length(y_ref)
    MSE.gn = immse(y_ref,y_rec_gn);
    MSE.tv = immse(y_ref,y_rec_tv);
    MSE.nn = immse(y_ref,y_rec_nn);
    fprintf(proto_fid,'MSE %f %f %f\n',MSE.gn,MSE.tv,MSE.nn);
    %Relative Image Error (RIE)
    RIE.gn = norm(y_ref-y_rec_gn)./norm(y_ref);
    RIE.tv = norm(y_ref-y_rec_tv)./norm(y_ref);
    RIE.nn = norm(y_ref-y_rec_nn)./norm(y_ref);
    fprintf(proto_fid,'RIE %f %f %f\n',RIE.gn,RIE.tv,RIE.nn);
    %Image Correlation Coefficient (ICC)
    % ICC.gn = sum((y_ref-mean(y_ref)).*(y_rec_gn-mean(y_rec_gn)))/sqrt(sum((y_ref-mean(y_ref)).^2).*sum((y_rec_gn-mean(y_rec_gn)).^2));
    ICC.gn = corr2(y_ref,y_rec_gn);
    ICC.tv = corr2(y_ref,y_rec_tv);
    ICC.nn = corr2(y_ref,y_rec_nn);
    fprintf(proto_fid,'ICC %f %f %f\n',ICC.gn,ICC.tv,ICC.nn);
    %%
    subplot(2,4,[1,5]);
    title('fwd model with anomally');
    show_fem(x.img_ih,[1,1,0]);
    
    subplot(2,4,2);
    title('GN');
    show_fem(gn_data.iimg,[1,1,0]);
    
    subplot(2,4,3);
    title('TV');
    show_fem(tv_data.iimg,[1,1,0]);
    
    subplot(2,4,4);
    title('NN');
    show_fem(nn_data.iimg,[1,1,0]);
    
    subplot(2,4,6);
    title('GN with noise');
    show_fem(gn_data.iimg_n,[1,1,0]);
    
    subplot(2,4,7);
    title('TV with noise');
    show_fem(tv_data.iimg_n,[1,1,0]);
    
    subplot(2,4,8);
    title('NN with noise');
    show_fem(nn_data.iimg_n,[1,1,0]);
    pause
    
end

%% Train
if user_entry.NN == 1
    [net, nets, filename,time_train_h]= Neural_Network(user_entry,train_dataset);
    file2save= [out_path '\' user_entry.net_file_name 'trained_net' '.mat'];
    save(file2save, 'user_entry', 'net','nets') %network data is saved in user defined file (and folder)
    disp(['Trained Neural Network saved in: ' file2save])
    fprintf(proto_fid,['Training time in hours: ' time_train_h '\n']);
    fprintf(proto_fid,['Trained net saved in: ' replace(file2save, '\','\\') '\n']);
end

fclose(proto_fid)




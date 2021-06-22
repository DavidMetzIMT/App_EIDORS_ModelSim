clear

if ~exist('show_fem')
    run C:\EIDORS\eidors\startup.m
end


user_entry = user_entry();

%for now, Neural Network solver works fine with following data:
load_file_with_user_entry = 'user_entry_1_IMT0616.mat';
load(load_file_with_user_entry)

user_entry.net_file_name = 'Trained_Network_1_IMT0616.mat';   % file name, which contains suitable nets for invers solving
user_entry.load_fmdl =0;                             % get the fmdl from GUI
user_entry.range_num_of_cells = [1 2];
%user_entry.range_cell_conductivity = [1.5, 1.5 , 1 ; 1, 1, 0.3; 0.5, 0.5, 0.1];         % 5 or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
user_entry.withcells = 1;

user_entry.num_trainingData = 10;                  % the number of sets for generating training data

train_dataset = Cell_Data_Generator(user_entry);

% show the 3 first
figName= 'some Samples of generated data';
clf
h= getCurrentFigure_with_figName(figName);

nb_samples=3;
for i=1:nb_samples
    img = train_dataset.single_data(i).img_ih;
    data=train_dataset.single_data(i).data_ih.meas;
    
    subplot(nb_samples,2,(i-1)*2+1)
    title(['Conduct Sample ', num2str(i)]);
    show_fem(img,[1,1,0]);
    
    subplot(nb_samples,2,i*2)
    title(['Voltages Sample ', num2str(i)]);
    plot(data)
end
pause
%% Testing of the NN

user_entry.num_trainingData = 1;
test_dataset = Cell_Data_Generator(user_entry);

figName= 'Results  from reconstruction of some test data';
clf
h= getCurrentFigure_with_figName(figName);


% plot >> todo make a function of integrate it to a class
for i = 1:user_entry.num_trainingData
    x = test_dataset.single_data(i);
    
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

y_ref = test_dataset.single_data(i).img_ih.elem_data; %defining reference output (conductivity) of nodes
y_rec_gn = gn_data.iimg.elem_data;                    %defining reconstructed by gn output (conductivity) of nodes without noise
y_rec_tv = tv_data.iimg.elem_data;                    %defining reconstructed by tv output (conductivity) of nodes without noise
y_rec_nn = nn_data.iimg.elem_data;                    %defining reconstructed by nn output (conductivity) of nodes without noise

%Mean Squared Error (MSE):
% MSE.gn = sum((y_ref-y_rec_gn).^2)/length(y_ref)
MSE.gn = immse(y_ref,y_rec_gn);
MSE.tv = immse(y_ref,y_rec_tv);
MSE.nn = immse(y_ref,y_rec_nn) 

%Relative Image Error (RIE)
RIE.gn = norm(y_ref-y_rec_gn)./norm(y_ref);
RIE.tv = norm(y_ref-y_rec_tv)./norm(y_ref);
RIE.nn = norm(y_ref-y_rec_nn)./norm(y_ref)

%Image Correlation Coefficient (ICC)
% ICC.gn = sum((y_ref-mean(y_ref)).*(y_rec_gn-mean(y_rec_gn)))/sqrt(sum((y_ref-mean(y_ref)).^2).*sum((y_rec_gn-mean(y_rec_gn)).^2));
ICC.gn = corr2(y_ref,y_rec_gn);
ICC.tv = corr2(y_ref,y_rec_tv);
ICC.nn = corr2(y_ref,y_rec_nn)
    
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



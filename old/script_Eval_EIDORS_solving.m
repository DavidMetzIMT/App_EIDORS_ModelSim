clear
% add complete path load use functions
add_all_path();

%% Start EIDORS Toolbox
Start_EIDORS();


%% load eit_dataset and testdataset_U4Solve
prompt = ['Select a eit_dataset-file to load'];
folder= pwd;
file_typ= 'eit_dataset.mat';
path = get_path_user_entrys(prompt, folder, file_typ);

if isempty(path{1})
    return
end
path=path{1};

dataset = EITDataset();
dataset=dataset.load_EITDataset(path);


[fPath, fName, fExt] = fileparts(path);

prompt = ['Select a testdataset_U4Solve-file to load'];
folder= fPath;
file_typ= 'testdataset_U4Solve.mat';
path = get_path_user_entrys(prompt, folder, file_typ);

if isempty(path{1})
    return
end
path=path{1};
l=load(path);
idx_test= l.idx_test;


%% solve using EIDORS
dataset.user_entry.inv_solver_name='GN';

j= 1;
filename={};
k=1
for i = 1:length(idx_test)
    i
    s_data= dataset.get_single_data(idx_test(i));
    
    tmp = invSolver(dataset.user_entry, s_data);
    
    elem_data(:,j)= tmp.iimg.elem_data;
    elem_data_n(:,j)= tmp.iimg_n.elem_data;
    j=j+1;
    
    if j==250 || i==length(idx_test)
        filename{k}= ['tmp_sdata' num2str(j) '.mat']
        k=k+1;
        save( [fPath, filesep, filename{j}], 'elem_data', 'elem_data_n')
        elem_data= [];
        elem_data_n= [];
        j= 1;
    end
end

for i= 1:size(filename,2)
    file= load([fPath, filesep, filename{i}]);
    
    if i==1
        elem_data = file.elem_data;
        elem_data_n = file.elem_data_n;
    else
        elem_data = [elem_data file.elem_data];
        elem_data_n = [elem_data_n file.elem_data_n];
    end
end




save( [fPath, filesep, 'elems_solved.mat'], 'elem_data', 'elem_data_n')




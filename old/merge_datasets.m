function train_dataset = merge_datasets()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
global a b
title_ = ['Select a file to load Training Dataset '];
folder= pwd;
i= 0;
while 1
    i= i+1;
    [file,path, notCancelled] = uigetfile('*.*',title_,folder);
    if notCancelled
        file2load=[path file];
        tmp = load(file2load, 'train_dataset');
        tmp= tmp.train_dataset;
        
        if i==1
            train_dataset= tmp;
            file2save= [replace(file2load,'.mat', '') '_merge.mat'];

        else
            %todo improve the test of user entry
            b= tmp;
            o_s1= size(tmp.single_data(1, 1).img_h.elem_data,1);
            i_s1= size(tmp.single_data(1, 1).data_h.meas,1);
            
            o_s0= size(train_dataset.single_data(1, 1).img_h.elem_data,1);
            i_s0= size(train_dataset.single_data(1, 1).data_h.meas,1);
            if (o_s1==o_s0 && i_s1==i_s0)
                fields=fieldnames(train_dataset.TrainingSet);
                for i=1:length(fields)
                %train_dataset.single_data=[train_dataset.single_data;tmp.single_data]
                    train_dataset.TrainingSet.(fields{i})=[train_dataset.TrainingSet.(fields{i}), tmp.TrainingSet.(fields{i})];
                end
            end
        end
        
    else
        break
    end
    
end

save(file2save, 'train_dataset')


end


function plot_samples(indexes, path)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if nargin==1
    % path of the file
    prompt = ['Select a file to load user_entry-file'];
    folder= pwd;
    file_typ= '*.*';
    path = get_path_user_entrys(prompt, folder, file_typ);
    
    if isempty(path{1})
        return
    end
   path=path{1};
end

%% Plot some sample of trained data!
    if usejava('desktop')
        figName= ['some Samples of generated data of user_entry #' num2str(indexes)];
        h= getCurrentFigure_with_figName(figName);
        nb_single_data=3;
        train_dataset = EITDataset();
        train_dataset=train_dataset.load_EITDataset(path);
        
        for idx=indexes
            s_data= train_dataset.get_single_data(idx);
            img = s_data.img_ih;
            img.elem_data(1:10)
            img.fwd_model= train_dataset.user_entry.fmdl;
            data=s_data.data_ih.meas;
            
            subplot(nb_single_data,2,(idx-1)*2+1)
            title(['Conduct Sample# ' num2str(idx)]);
            h= show_fem(img,[1,0,0]);
            set(h,'EdgeColor','none');
            
            subplot(nb_single_data,2,idx*2)
            title(['Voltages Sample# ' num2str(idx)]);
            plot(data)
        end
        
        
    end




end


clear
% add complete path load use functions
add_all_path();

% read user_entry
[ue, user_entry_path ]= read_UserEntry();
if isempty(ue); return; end
% select user entry index to generate
indxs = input(['Enter index of user entry data to use (e.g. [1,3,5] or enter for all): ']);
if isempty(indxs)
    indxs=1:length(ue);
else
    if max(ue)>length(ue)
        disp('Wrong indexes');
        return;
    end
end
t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
out_path_root= [current_path filesep 'Outputs'];
mkdir(out_path_root);

%% Start EIDORS Toolbox
Start_EIDORS();

% loop for each
for indx=indxs
    user_entry = ue{indx};
    %% folder name for the results
    folder_out=[char(t) '_' user_entry.net_file_name '_dataset'];
    %% Add all the Subfolder of the App
    out_path= [out_path_root filesep folder_out];
    mkdir(out_path);
    
    %% Init the protocol
    t = datetime('now','TimeZone','local','Format','yyyyMMdd_HHmmss');
    proto_fid=fopen([out_path filesep 'Protocol_' char(t) '.txt'],'w');
    fprintf(proto_fid,['Protocol Init' '\n']);
    fprintf(proto_fid,['Date time: ' char(t) '\n']);
    fprintf(proto_fid,['user_entry loaded from: ' replace(user_entry_path{indx}, '\','\\') '\n']);
    % Save user entry separately in the folder!
    file2save = [out_path filesep user_entry.net_file_name '_user_entry.mat'];
    save(file2save, 'user_entry');
    % Update protocol
    fprintf(proto_fid,['user_entry saved in: ' replace(file2save, '\','\\') '\n']);
    
    %% Training Dataset
    % if cancelled than
    % rng(1223)% to get all teh time same random generation...
    train_dataset = EITDataset();
    train_dataset.generate_eit_dataset(user_entry, out_path);
    fprintf(proto_fid,['Train dataset generated ' '\n']);
    % Save Traindataset with user_entry in case of need of traceback...
%     file2save = [out_path filesep user_entry.net_file_name '_train_dataset.mat'];
%     save(file2save, 'user_entry', 'train_dataset')
    
    % Update protocol
    fprintf(proto_fid,['Train dataset saved in: ' replace(file2save, '\','\\') '\n']);
    
    
    
    
    path = [out_path filesep user_entry.net_file_name '_eit_dataset.mat'];
    plot_samples([1:3], path)
    
end
fclose(proto_fid);







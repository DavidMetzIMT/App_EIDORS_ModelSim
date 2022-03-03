function [u_entry, path]= read_UserEntry()
addpath(genpath(pwd))

% path of the file
prompt = ['Select a file to load user_entry-file'];
folder= pwd;
file_typ= '*.*';
path = get_path_user_entrys(prompt, folder, file_typ);
if isempty(path)
    ue=[];
    return
end
j=0
for i= 1:size(path,2)
    file=load(path{i});
    fields = fieldnames(file);
    ue= user_entry();
    for i=1:length(fields)
        if isa(file.(fields{i})(1), 'user_entry')
            ue=file.(fields{i});
            j=j+1;
            break % get the first field in the file
        end
    end
    u_entry{j}= ue;
end

for i=1:length(u_entry)
    indx_of_user_entry=i
    u_entry{i}
end

end
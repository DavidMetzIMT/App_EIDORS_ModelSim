function ue= read_UserEntry()
addpath(genpath(pwd))

% path of the file
prompt = ['Select a file to load user_entry-file'];
folder= pwd;
file_typ= '*.*';
path = get_path_user_entrys(prompt, folder, file_typ);
if isempty(path)
    return
end
file=load(path);
fields = fieldnames(file)
ue= user_entry();
for i=1:length(fields)
    if isa(file.(fields{i})(1), 'user_entry')
        ue=file.(fields{i});
        break % get the first field in the file
    end
end

for i=1:length(ue)
    i
    ue(i)
end
end
% if usejava('desktop')
%     disp('This Matlab instance runs with a desktop')
% else
%     disp('This Matlab instance runsin console')
% end
% % path of the file
% prompt = ['Select a file to load user_entry-file'];
% folder= pwd;
% file_typ= '*.*';
% path = get_path_user_entrys(prompt, folder, file_typ);
% if isempty(path)
%     return
% end

l=load('user_entrys.mat');
fields = fieldnames(l)
user_entry= user_entry()
for i=1:length(fields)
    fields{i}
    if isstruct(l.(fields{i}))
    if isfield(l.(fields{i}),class_type)
        if l.(fields{i})(1).class_type== 'user_entry';
            user_entry=l.fields{i}
            return
        end
    end
    end
end

for i=1:length(user_entry)
    i
    user_entry(i)
end
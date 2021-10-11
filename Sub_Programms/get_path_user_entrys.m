function file2load = get_path_user_entrys(prompt, folder, file_typ)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if usejava('desktop')
    %     disp('This Matlab instance runs with a desktop')
    [file,path, notCancelled] = uigetfile(file_typ,prompt,folder,'MultiSelect','on');
    
    if notCancelled
        if iscell(file)
            for i= 1:size(file,2)
            file2load{i}=[path file{i}];
            end
        else
            file2load{1}=[path file];
        end
        
    else
        file2load{1}=[];
        disp('Loading Cancelled')
        return
    end
else
    file2loadtmp = input([prompt '/r/n enter relativ path from pwd: /r/n' folder filesep ' '],'s')
    folder
    file2load{1}=[folder filesep file2loadtmp]
    %     disp('This Matlab instance runs in console')
end

for i= 1:size(file2load,2)
    if ~exist(file2load{i},'file')
        disp(['please provide existing file path:' file2load])
        file2load{1}=[];
    end
end


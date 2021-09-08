function file2load = get_path_user_entrys(prompt, folder, file_typ)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here


if usejava('desktop')
    %     disp('This Matlab instance runs with a desktop')
    [file,path, notCancelled] = uigetfile(file_typ,prompt,folder);
    if notCancelled
        file2load=[path file];
    else
        file2load=[];
        disp('Loading Cancelled')
        return
    end
else
    file2load = input([prompt '/r/n enter relativ path from pwd:/r/n' folder],'s');
    file2load=[folder file2load];
    %     disp('This Matlab instance runs in console')
end

if ~exist(file2load,'file')
    disp(['please provide existing file path:' file2load])
    file2load=[];
end
end

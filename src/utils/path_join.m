function path = path_join(folder, filename) 
    %PATH_JOIN concatenate a folderlike and a filename to a single pathLike string
    if strcmp(folder(end), filesep)
        folder= folder(1:end-1);
    end
    path= [folder filesep filename];
end

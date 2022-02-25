function path = path_join(folder, filename) 
    % Create a default Path
    if strcmp(folder(end), filesep)
        folder= folder(1:end-1);
    end
    path= [folder filesep filename];
end

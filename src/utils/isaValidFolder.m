function isValid = isaValidFolder(path)
    %ISAVALIDFOLDER check if path is a valid folder
    % is a valid path (return 1) or already exist (return 2)
    % return 0 if is not a valid path
    isValid=0;
    if ~isfolder(path)
        [status, msg] = mkdir(path);
        if status
            % is a valid path
            isValid = 1;
            rmdir(path);
        end
    else
        % Folder already exist
        isValid=2;
    end    
end
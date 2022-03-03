function isValid = isaValidMatFile(path)
    %ISAVALIDMATFILE Check if path is a valid mat-file
    % is a valid path (return 1) or already exist (return 2)
    % return 0 if is not a valid path
    isValid=0
    if ~isfile(path)
        [status, msg] = mkdir(path);
        if status
            % is a valid path
            isValid = 1
            rmdir(path)
        end
    else
        % Folder already exist
        isValid=2
    end
    
    return isValid

    

    return isMatFile
    
end
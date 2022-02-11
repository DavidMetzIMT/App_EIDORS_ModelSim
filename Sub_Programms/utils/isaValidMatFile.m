function isValid = isaValidMatFile(path)
    % isaValidMatFile check if a path:
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
function [folder, filename] = check_folder_filename(folder, filename)
    %CHECK_FOLDER_FILENAME Check if the couple folder/ filename
    % if they are empty or unvalid then they will be set to default values
    
    if (strcmp(folder,'') || ~isaValidFolder(folder))
        folder = pwd; % default
    else
        folder= folder;
    end
    %check filename
    if strcmp(filename,'')
        filename = 'filename'; % default
    else
        filename= filename;
    end
end
function AddAllSubFolders(path)

disp(['Add all sub folder from: ' path]);

addpath(replace(genpath(path),'\old',''));

end


% try delete(findall(0));end
path= mfilename('fullpath');
[path, fName, fExt] = fileparts(path);
cd(path);
disp(['Add to "Matlab-PATH" all subfolder from: ' path]);
addpath(genpath(path));
app = FwdModel_App(path);
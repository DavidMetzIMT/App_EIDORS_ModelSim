path=pwd;
disp(['Add to "Matlab-PATH" all subfolder from: ' path]);
addpath(genpath(path));
app = FwdModel_App;
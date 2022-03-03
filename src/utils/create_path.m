function create_path(path)
% Test if inputs path exist, if not the folder wil be created.
%
% INPUT: path is a structure of several string
%
% Example: path.setups = 'C:....\Setups'
%          path.user = 'C:....\user'
%

% get all field of the structure path
fields = fieldnames(path);
for i=1:length(fields)
    k = fields(i);
    a = k{1};
    if ~exist(path.(a),'dir')
        mkdir (path.(a));
        display(['Create:',fullfile(path.(a))]);
    end
end


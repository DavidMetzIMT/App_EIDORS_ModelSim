function Start_EIDORS(path)
if nargin == 0
    path = 'C:\EIDORS\eidors\startup.m';
end

if ~exist('show_fem')
    disp(['Starting EIDORS from path: ' path]);
    run(path);
else
    disp(['EIDORS already started']);
end

end


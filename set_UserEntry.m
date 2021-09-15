% Set from the GUI
%     disp('This Matlab instance runs with a desktop')
% else
%     disp('This Matlab instance runsin console')
% end
% % path of the file
% prompt = ['Select a file to load user_entry-file'];
% folder= pwd;
% file_typ= '*.*';
% path = get_path_user_entrys(prompt, folder, file_typ);
% if isempty(path)
%     return
% end

global EIDORS
u_entry= user_entry();
u_entry.fmdl = EIDORS.fmdl;
u_entry.chamber = EIDORS.chamber;



u_entry.net_file_name =EIDORS.entry.name                      % file name, which contains suitable nets for invers solving
% chamber_type = [];                  % = 'circle'; % 'circle' or 'rectangle' defines chamber shape and objects coordinates
% chamber_height = [];                % 0 indicates 2D object, number indicates the height of chamber
% chamber_radius = [];                % = 2; % indicates radius of the buffer(chamber)
% mesh_size = [];                          % max size of mesh elems
u_entry.range_num_of_cells = str2num(EIDORS.entry.range_num_of_cells);            % = 10; % or e.g [5 10], one number indicates the maximum possible number of cells, two numbers means the range of possible number of cells, e.g. [5 10] from 5 to 10 cells
u_entry.range_buffer_conductivity = str2num(EIDORS.entry.range_buffer_conductivity);     % = 5; % or e.g [5 10], one number indicates the maximum possible conductivity of the buffer, two numbers means the range of possible conductivity of the buffer
u_entry.range_cell_conductivity = str2num(EIDORS.entry.range_cell_conductivity);       % = [5 10]; % or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
u_entry.range_cell_radius = str2num(EIDORS.entry.range_cell_radius);             % = 0.5; % or e.g [0.5 1.0], one number indicates the maximum possible radius of cells, two numbers means the range of possible radius of cells
%cell_nucleus = [];                  % if 1 - depicts cell nucleus with bigger condutivity, if 0 - no nucleus is depicetd
u_entry.SNR = EIDORS.entry.SNR;                           % noise ratio
u_entry.inv_solver_name = [];               % 'GN' (for Gauss Newton one step) or 'TV' (for Total Variation/PDIPM)'
u_entry.num_trainingData = EIDORS.entry.num_trainingData;
%invSolver = [];                     % 1 indicates the use of inv_solver, if 0 - in_solver is not used
%NN = [];                            % 1 indicates the activation of Neural network
u_entry.fmdl
%imdl
u_entry.load_fmdl= 1
type_of_artefacts=EIDORS.entry.type_of_artefacts

save(EIDORS.entry.filename)




addpath(genpath(pwd))

l=load('user_entrys.mat');
fields = fieldnames(l)
user_entry= user_entry()
for i=1:length(fields)
    fields{i}
    if isstruct(l.(fields{i}))
        if isfield(l.(fields{i}),class_type)
            
            if l.(fields{i})(1).class_type== 'user_entry';
                user_entry=l.fields{i}
                return
            end
        end
    end
end

for i=1:length(user_entry)
    i
    user_entry(i)
end
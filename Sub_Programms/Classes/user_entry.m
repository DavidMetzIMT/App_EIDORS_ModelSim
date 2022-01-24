classdef user_entry < handle
  
    properties ( Access = public )
        class_type= 'user_entry';
        net_file_name =[]                      % file name, which contains suitable nets for invers solving
        % chamber_type = [];                  % = 'circle'; % 'circle' or 'rectangle' defines chamber shape and objects coordinates
        % chamber_height = [];                % 0 indicates 2D object, number indicates the height of chamber
        % chamber_radius = [];                % = 2; % indicates radius of the buffer(chamber)
        % mesh_size = [];                          % max size of mesh elems
        range_num_of_cells = [];            % = 10; % or e.g [5 10], one number indicates the maximum possible number of cells, two numbers means the range of possible number of cells, e.g. [5 10] from 5 to 10 cells
        range_buffer_conductivity = [];     % = 5; % or e.g [5 10], one number indicates the maximum possible conductivity of the buffer, two numbers means the range of possible conductivity of the buffer        
        range_cell_conductivity = [];       % = [5 10]; % or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
        range_cell_radius = [];             % = 0.5; % or e.g [0.5 1.0], one number indicates the maximum possible radius of cells, two numbers means the range of possible radius of cells
        %cell_nucleus = [];                  % if 1 - depicts cell nucleus with bigger condutivity, if 0 - no nucleus is depicetd
        SNR = [];                           % noise ratio
        inv_solver_name = [];               % 'GN' (for Gauss Newton one step) or 'TV' (for Total Variation/PDIPM)'
        num_trainingData = [];
        %invSolver = [];                     % 1 indicates the use of inv_solver, if 0 - in_solver is not used
        %NN = [];                            % 1 indicates the activation of Neural network
        fmdl
        %imdl
        load_fmdl=[]
        type_of_artefacts=[]                % cells, antibodies, invsolver
        chamber
        
        size_file_samples_max= 1e6%bytes
        size_file_single_data_max= 10e6%bytes
        %withcells
        %mk_antibodies
        
        
    end
    
    methods 
        % @Mantas it is useless as the properties are public...
%         function set.net_file_name(obj, in) 
%             obj.net_file_name = in;   
%         end
%         
%         function set.chamber_type(obj, in) 
%             obj.chamber_type = in;   
%         end
%         
%         function set.chamber_height(obj, in) 
%             obj.chamber_height =  in;   
%         end
%         
%         function set.chamber_radius(obj, in) 
%             obj.chamber_radius =  in;   
%         end
%         
%         function set.mesh_size(obj, in) 
%             obj.mesh_size =  in;   
%         end
%         
%         function set.range_num_of_cells(obj, in) 
%             obj.range_num_of_cells = in;   
%         end
%         
%         function set.range_buffer_conductivity(obj, in)
%             obj.range_buffer_conductivity = in;   
%         end
%         
%         function set.range_cell_conductivity(obj, in) 
%             obj.range_cell_conductivity = in;  
%         end
%         
%         function set.range_cell_radius(obj, in)   
%             obj.range_cell_radius = in;   
%         end
%        
%         function set.cell_nucleus(obj, in)   
%             obj.cell_nucleus = in;   
%         end
%         
%         function set.SNR(obj, in) 
%             obj.SNR = in;   
%         end
%         
%         function set.inv_solver_name(obj, in) 
%             obj.inv_solver_name = in;   
%         end
%         
%         function set.num_trainingData(obj, in) 
%             obj.num_trainingData = in;   
%         end
%         
%         function set.NN(obj, in) 
%             obj.NN = in;   
%         end
%         
%         function set.invSolver(obj, in) 
%             obj.invSolver = in;   
%         end
    end
end


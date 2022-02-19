classdef UserEntry < handle
  
    properties ( Access = public )
        type= 'user_entry';
        name =''                      % file name, which contains suitable nets for invers solving
        samplesAmount = [];

        mediumsConductRange = [];     % = 5; % or e.g [5 10], one number indicates the maximum possible conductivity of the buffer, two numbers means the range of possible conductivity of the buffer        
        objectType=[]                % cells, antibodies, invsolver
        objectAmountRange = [];            % = 10; % or e.g [5 10], one number indicates the maximum possible number of cells, two numbers means the range of possible number of cells, e.g. [5 10] from 5 to 10 cells
        objectDimRange = [];             % = 0.5; % or e.g [0.5 1.0], one number indicates the maximum possible radius of cells, two numbers means the range of possible radius of cells
        objectConductRange = [];       % = [5 10]; % or e.g [5 10], one number indicates the maximum possible conductivity of cells, two numbers means the range of possible conductivitie of cells
        
        SNR = [];                           % noise ratio
        
        samplesFileSize= 1e6%bytes
        srcFileSize= 10e6%bytes
        
    end
    
    methods 
        function obj = UserEntry(varargin)
             % Set the prperties from the object electrodes layout
            % varargin{1} >> struct :
            %                           --Number % of electrode
            %                           --Form % of the electrode: Circular, Rectangular, Point
            %                           --Diameter_Width % electrode width
            %                           --Height % electrode height
            %                           --Position % position in the chamber Wall, Top, Bottom
            %                           --Design % Ring, Grid, Polka Dot
            %                           --Diameter % Diameter design
            if nargin==1
                var= varargin{1};
                obj.name               = var.Name; 
                obj.samplesAmount       = var.Samples_amount; 
                obj.mediumsConductRange = str2num_array(var.Medium_conduct); 
                obj.objectType          = var.Object_type; 
                obj.objectAmountRange   = str2num_array(var.Object_amount);
                obj.objectDimRange      = str2num_array(var.Object_dimension); 
                obj.objectConductRange  = str2num_array(var.Object_conduct); 
                obj.SNR                 = var.Noise_SNR;
                obj.samplesFileSize     = var.Samples_file_size;
                obj.srcFileSize         = var.Src_file_size; 
            else

                object=EIT_object();
                obj.name                = 'Dataset_name'; 
                obj.samplesAmount       = 10000; 
                obj.mediumsConductRange = [1, 2]; 
                obj.objectType          = object.type; 
                obj.objectAmountRange   = [1, 2];
                obj.objectDimRange      = [0.1,0.2]; 
                obj.objectConductRange  = [0.1, 0.2]; 
                obj.SNR                 = 20;
                obj.samplesFileSize     = 1000;
                obj.srcFileSize         = 250; 
            end
            
        end

        function var = get_struct_4_gui(obj)
            % attention here the order count
            var.Name                = obj.name; 
            var.Samples_amount      = obj.samplesAmount; 
            var.Medium_conduct      = num_array2str(obj.mediumsConductRange); 
            var.Object_type         = obj.objectType; 
            var.Object_amount       = num_array2str(obj.objectAmountRange);
            var.Object_dimension    = num_array2str(obj.objectDimRange); 
            var.Object_conduct      = num_array2str(obj.objectConductRange); 
            var.Noise_SNR           = obj.SNR;
            var.Samples_file_size   = obj.samplesFileSize;
            var.Src_file_size       = obj.srcFileSize; 
            
        end

        function format = get_format_4_gui(obj)
            % attention here the order count
            object=EIT_object();
            format={'char', 'numeric', 'char', object.allowed_type(), 'char', 'char', 'char','numeric','numeric','numeric' };
        end



        % @Mantas it is useless as the properties are public...
        function set.objectConductRange(obj, range_in) 

            for layer =1:size(range_in,1) % we have a multiple layer cell
                range(layer,:)= range_in(layer,:);
                len= size(range(layer,:),2);
                switch len
                    case 1
                        range(layer,1:3)=[range(layer,1) range(layer,1) 1];
                    case 2
                        range(layer,1:3)=[range(layer,:) 1];
                    case 3
                        if range(layer,3)>1
                            errordlg(['Wrong Conduct range: layer ratio (>1) on layer:', num2str(layer)]);
                            return;
                        end
                    otherwise
                        errordlg(['Wrong Conduct range']);
                        return;
                end
            end

            obj.objectConductRange = range;
        end
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


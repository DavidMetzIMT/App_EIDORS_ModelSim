classdef bufferClass
    
    properties ( Access = public )
       maxNumCells
       bufferConduct
    end
    
    methods (Access = public)
        function obj = bufferClass(user_entry)
            
            range_num_of_cells = user_entry.range_num_of_cells;
            range_buffer_conductivity = user_entry.range_buffer_conductivity;
             
            %% defining cell range
            if length(range_num_of_cells)==1
                obj.maxNumCells = floor(range_num_of_cells*rand())+1;
            else
                obj.maxNumCells = floor(range_num_of_cells(1)+(range_num_of_cells(2) - range_num_of_cells(1))*rand());
            end

            %% defining buffer conductivity range
            if length( range_buffer_conductivity)==1
                obj.bufferConduct =  range_buffer_conductivity(1)*rand();
            else
                obj.bufferConduct =  range_buffer_conductivity(1)+( range_buffer_conductivity(2)- range_buffer_conductivity(1))*rand();
            end
        end
        
    end
    
end


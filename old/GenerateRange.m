classdef GenerateRange
    
    properties ( Access = public )
       maxNumCells
       bufferConduct
    end
    
    methods (Access = public)
        function obj = GenerateRange(user_entry)
            
            range_nb_cells = user_entry.range_num_of_cells;
            range_buffer_conduct = user_entry.range_buffer_conductivity;
            
             
            %% defining nb cell range
            if length(range_nb_cells)==1
                obj.maxNumCells = floor(range_nb_cells*rand())+1;
            else
                obj.maxNumCells = floor(range_nb_cells(1)+(range_nb_cells(2) - range_nb_cells(1))*rand());
            end
            
            
            %% defining buffer conductivity
            if length( range_buffer_conduct)==1
                obj.bufferConduct =  range_buffer_conduct(1)*rand();
            else
                obj.bufferConduct =  range_buffer_conduct(1)+( range_buffer_conduct(2)- range_buffer_conduct(1))*rand();
            end
            
            
        end
        
    end
    
end


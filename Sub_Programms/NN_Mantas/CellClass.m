classdef GenerateCell
    
    properties ( Access = public )
        Pos 
        Radius
        LayerConduct
        LayerRatio
    end
    
    methods (Access = public)
        
        function obj = GenerateCell(user_entry)
            obj.Pos = gen_position(user_entry);
            [obj.LayerConduct,obj.LayerRatio, obj.Radius] = mk_conduct_radius(user_entry);
        end
        
        function pos = gen_position(user_entry)
        % generate a position ina defined area 
        % TODO implement 2D/3D cases...
            chamber_type = user_entry.chamber_type;
            chamber_radius = user_entry.chamber_radius;
            chamber_height = user_entry.chamber_height;
            if contains(chamber_type, 'circle')
                r = chamber_radius*rand();
                alpha = 2*pi()*rand();
                pos = [r*cos(alpha) r*sin(alpha) chamber_height*rand()];
            elseif contains(chamber_type, 'rectangle')
                pos = [chamber_radius(1)*(-1+2*rand()) chamber_radius(1)*(-1+2*rand()) chamber_height*rand()];
            else
                error("ERROR: Wrong chamber statment! Try 'circle' or 'rectangle'!")
            end
        end
        
        function [LayerConduct,LayerRatio, Radius] = mk_conduct_radius(user_entry)
        % generate a position ina defined area 
        % TODO implement 2D/3D cases...
            range_cell_conduct = user_entry.range_cell_conductivity;
            range_cell_radius = user_entry.range_cell_radius;
            %% defining cell conductivity
            
            for layer =1:size(range_cell_conduct,1) % we have a multiple layer cell
                layer_range= range_cell_conduct(layer,1:2);
                if length(layer_range)==1
                    LayerConduct(layer) = layer_range(1)*rand();
                else
                    LayerConduct(layer) = layer_range(1)+(layer_range(2)- layer_range(1))*rand();
                end
                if size(range_cell_conduct,3)>2
                    LayerRatio(layer)= range_cell_conduct(layer,3);
                else
                    LayerRatio(layer)= 1; %if ratio not given 
                end
            end
            
            %% defining cell radius
            if length(range_cell_radius)==1
                Radius = range_cell_radius(1)*rand();
            else
                Radius = range_cell_radius(1)+(range_cell_radius(2)- range_cell_radius(1))*rand();
            end
        end
        
    end
    
end


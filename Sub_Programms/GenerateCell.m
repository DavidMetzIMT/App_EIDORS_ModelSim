classdef GenerateCell
    
    properties ( Access = public )
        Pos
        Radius
        LayerConduct
        LayerRatio
    end
    
    methods (Access = public)
        
        function obj = GenerateCell(user_entry)
            obj.Pos = obj.gen_position(user_entry);
            [obj.LayerConduct,obj.LayerRatio, obj.Radius] = obj.mk_conduct_radius(user_entry);
        end
        
        function pos = gen_position(obj,user_entry)
            % generate a position ina defined area
            % TODO implement 2D/3D cases...
            chamber_type = user_entry.chamber.body.typ;
            chamber_radius = user_entry.chamber.body.diameter_length/2;
            chamber_height = user_entry.chamber.body.height;
            z= chamber_height*rand();
            if contains(chamber_type, 'Cylinder') || contains(chamber_type, '2D_Circ')
                r = chamber_radius*rand();
                alpha = 2*pi()*rand();
                pos = [r*cos(alpha) r*sin(alpha) z];
            elseif contains(chamber_type, 'cubic')
                pos = [chamber_radius(1)*(-1+2*rand()) chamber_radius(1)*(-1+2*rand()) z];
            else
                error("ERROR: Wrong chamber statment! Try 'circle' or 'rectangle'!")
            end
        end
        
        function [LayerConduct,LayerRatio, Radius] = mk_conduct_radius(obj,user_entry)
            % generate a position ina defined area
            % TODO implement 2D/3D cases...
            range_conduct = user_entry.range_cell_conductivity;
            range_radius = user_entry.range_cell_radius;
            
            %% defining cell conductivity
            for layer =1:size(range_conduct,1) % we have a multiple layer cell
                if size(range_conduct(layer,:),2)==1
                    range_conduct(layer,:)=[range_conduct(layer,:) range_conduct(layer,:)];
                end
                layer_range= range_conduct(layer,1:2);
                if length(layer_range)==1
                    LayerConduct(layer) = layer_range(1)*rand();
                else
                    LayerConduct(layer) = layer_range(1)+(layer_range(2)- layer_range(1))*rand();
                end
                if size(range_conduct,2)> 2
                    if range_conduct(layer,3)<=1
                        LayerRatio(layer)= range_conduct(layer,3);
                    else
                        disp(['wrong layer ratio (<=1) on layer:', num2str(layer)])
                    end
                else
                    LayerRatio(layer)= 1; %if ratio not given
                end
            end
            
            %% defining cell radius
            if length(range_radius)==1
                Radius = range_radius(1)*rand();
            else
                Radius = range_radius(1)+(range_radius(2)- range_radius(1))*rand();
            end
        end
    end
end


classdef EIT_setup < handle
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        chamber EIT_chamber
        pattern EIT_pattern
        elec_layout EIT_elec_layout
    end
    
    methods
        function obj = EIT_setup()
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            obj.chamber= EIT_chamber();
            obj.inj= EIT_pattern();
            obj.meas= EIT_pattern();
            obj.elec_layout= EIT_elec_layout();
        end

        function obj = set.chamber(obj, chamber)
            %UNTITLED2 Construct an instance of this class
            %   Detailed explanation goes here
            if isa(chamber_in, 'EIT_chamber')
                obj.chamber= chamber;
            else
                errordlg('Chamber has to be an EIT_Chamber cls')
            end
        end

        function obj = reset_elec_layout(obj)
            %reset_elec_layout clear the electrode layouts
            obj.elec_layout=EIT_elec_layout()
        end

        function obj = add_elec_layout(obj, layout)
            %add_elec_layout append an electrode layout
            if isa(layout, 'EIT_elec_layout')
                if obj.elec_layout.is_reset()
                    obj.elec_layout(1)= layout;
                else
                    obj.elec_layout(length(obj.elec_layout) + 1 ) = layout;
                end
            else
                errordlg('Electrode Layout has to be an EIT_elec_layout cls')
            end
        end
        
        function obj = set.pattern(obj, pattern)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            if isa(pattern, 'EIT_pattern') 
                obj.pattern= pattern;
            else
                errordlg('Chamber has to be an EIT_Chamber cls')
            end
     
        end
    end
end


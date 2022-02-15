classdef EIT_pattern
    %UNTITLED2 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        injAmplitude % amplitude of the injection current in A
        injType % ad, op,....
        injSpecial %some types need some special infos
        measType % ad, op,....
        measSpecial %some types need some special infos
        patternOption % patterning function can accept some options
        patternFunc % patterning function maybe handle?
    end

    properties (Access=private)
        GENERATING_FUNCTIONS={'Ring patterning','Array patterning','3D patterning'};
    end
    
    methods
        function obj = EIT_pattern(varargin)
            % Set the properties of an object pattern
            % varargin:
            %        obj.injAmplitude = varargin{1}; % amplitude of the injection current in A
            %        obj.injType=varargin{2}; % ad, op,....
            %        obj.injSpecial= varargin{3};%some types need some special infos
            %        obj.measType=varargin{4}; % ad, op,....
            %        obj.measSpecial=varargin{5}; %some types need some special infos
            %        obj.patternOption=varargin{6}; % patterning function can accept some options
            %        obj.patternFunc=varargin{7}; % patterning function maybe handle?
            if nargin==7
                obj.injAmplitude = varargin{1};
                obj.injType=varargin{2};
                obj.injSpecial= varargin{3};
                obj.measType=varargin{4};
                obj.measSpecial=varargin{5};
                obj.patternOption=varargin{6};
                obj.patternFunc=varargin{7};
            else % default values >>> TODO
                % obj.injAmplitude = varargin{1};
                % obj.injType=varargin{1};
                % obj.injSpecial= varargin{1};
                % obj.measType=varargin{1}; 
                % obj.measSpecial=varargin{1};
                % obj.patternOption=varargin{1}; 
                % obj.patternFunc=varargin{1}; 
            end

        end



        %% Setter 
        function obj = set.injAmplitude(obj, value)
            obj.injAmplitude = value;
            
        end

        function obj = set.injType(obj, value)
            obj.injType=value;
            
        end

        function obj = set.injSpecial(obj, value)
            obj.injSpecial= value;
            
        end

        function obj = set.measType(obj, value)
            obj.measType=value; 
            
        end

        function obj = set.measSpecial(obj, value)
            obj.measSpecial=value; 
            
        end

        function obj = set.patternOption(obj, value)
            obj.patternOption=value;
                       
        end

        function obj = set.patternFunc(obj, value)
            obj.patternFunc=value;
            
        end

        %% Getter
        function val = get_generating_func(obj)
            val= obj.GENERATING_FUNCTIONS;
            
        end

        function [stimulation,meas_select, error] = make(obj, n_elec, n_row)

            stimulation = 0; 
            meas_select = 0;
            error = build_error('', 0);

            amplitude = obj.injAmplitude;
            inj = get_pattern_params(obj.injType, obj.injSpecial);
            meas = get_pattern_params(obj.measType, obj.measSpecial);

            option = obj.patternOption';

            gen_func= obj.patternFunc;
            switch gen_func
                case obj.GENERATING_FUNCTIONS{1} %'Ring patterning'
                    [stimulation, meas_select] = mk_stim_patterns_dm(n_elec,1,inj,meas,option,amplitude);

                % case obj.GENERATING_FUNCTIONS{2} %'Array patterning'
                %     [stimulation,meas_select]=mk_stim_pattern_Array(inj,meas,option,amplitude);
                % case obj.GENERATING_FUNCTIONS{3} %''3D patterning'
                %     [stimulation,meas_select]=mk_stim_3Dpattern(inj,meas,option,amplitude);
                    
                otherwise
                    error = build_error('generating patterning not implemented', 1);
                    return;
            end
        end


    end
end

function pattern = get_pattern_params(pattern_typ, special_user)

    special_pattern=special_user;
    special_pattern=replace(special_pattern,'[','');
    special_pattern=replace(special_pattern,']','');
    special_pattern= str2num(special_pattern);
    switch pattern_typ
        case 'user defined'
            pattern = special_pattern;
        case '3d_adop_user'
            pattern = special_pattern;
        otherwise
            pattern = pattern_typ;
    end
    
end
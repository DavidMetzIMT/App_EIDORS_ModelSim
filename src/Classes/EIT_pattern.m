classdef EIT_pattern < handle
    %EIT_PATTERN Data about the injection and measurement pattern 
    %   
    
    properties
        type= 'eit_pattern'
        injAmplitude % amplitude of the injection current in A
        injType % ad, op,....
        injSpecial %some types need some special infos
        measType % ad, op,....
        measSpecial %some types need some special infos
        patternOption % patterning function can accept some options
        patternFunc % patterning function maybe handle?
    end

    properties (Access=private)
        GENERATING_FUNCTIONS={
            'Ring patterning',
            'Array patterning',
            '3D Ring patterning',
            '3D patterning'
        };
        PATTERNS= {
            {'{ad}';'{op}';'user defined'};
            {'array_ad_simple';'array_ad_full';'array_ad_line';'array_op'};
            {'planar';'zigzag';'square'};
            {'3d_ad_0';'3d_ad_1';'3d_ad_2';'3d_ad_3';'3d_op_inoutplane';'3d_op';'user defined'};
        }
    end
    
    methods
        function obj = EIT_pattern(varargin)
            %EIT_PATTERN Constructor set the properties of an object pattern
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
                obj.injAmplitude = 1;
                obj.injSpecial= '[1 2]';
                obj.measSpecial='[1 2]';
                obj.patternOption='meas_current';
                obj.init_pattern_func(obj.GENERATING_FUNCTIONS{1});
            end
        end

        function init_pattern_func(obj, value)
            %INIT_PATTERN_FUNC Init itself for a given patterning function
            obj.patternFunc=value;
            p=obj.get_patterns();
            obj.injType=p{1};
            obj.measType=p{1};
        end

        function val = get_generating_func(obj)
            %GET_GENERATING_FUNC Return the available patterning functions
            val= obj.GENERATING_FUNCTIONS;
        end

        function val = get_patterns(obj)
            %GET_PATTERNS Returns the implemented patterns type for a patterning function
            
            indx= find(strcmp(obj.GENERATING_FUNCTIONS,obj.patternFunc));
            val= obj.PATTERNS{indx};
        end

        function [stimulation,meas_select, error] = make(obj, n_tot, n_row, n_elec, n_XY)
            %MAKE Generate the "stimulation" and "meas_select" variables to define fmdl in EIDORS

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
                    if n_row > 1
                        disp("WARNING you selected a 2d pattering for mor than 2 electrodes layout")
                    end 
                    n_elec= n_elec(1,:); % select only first layout!
                    [stimulation, meas_select] = mk_stim_patterns_dm(n_elec,1,inj,meas,option,amplitude);

                case obj.GENERATING_FUNCTIONS{2} %'Array patterning'
                    if n_row > 1
                        disp("WARNING you selected a 2d pattering for mor than 2 electrodes layout")
                    end
                    n_elec= n_elec(1,:); % select only first layout!
                    n_XY= n_XY(1,:); % select only first layout!
                    if n_XY(2)<=0
                        error = build_error('Array patterning only for grid array', 1);
                        return;
                    end
                    [stimulation, meas_select] = mk_stim_pattern_Array(n_elec,n_XY,inj,meas,option,amplitude);
                case obj.GENERATING_FUNCTIONS{3} %''3D ring patterning'
                    [stimulation,meas_select]=mk_stim_ring_patterns_3D(n_elec,n_row,inj,meas,option,amplitude);
                % case obj.GENERATING_FUNCTIONS{3} %''3D patterning'
                %     [stimulation,meas_select]=mk_stim_pattern_3D(inj,meas,option,amplitude);
                    
                otherwise
                    error = build_error('generating patterning not implemented', 1);
                    return;
            end
        end
    end
end

function pattern = get_pattern_params(pattern_typ, special_user)
    %GET_PATTERN_PARAMS Return the pattern corresponding to pattern typ
    %       if pattern_typ is user_defined
    %       > pattern = special_user
    %       otherwise pattern = pattern_typ

    special_pattern=special_user;
    special_pattern = str2num_array(special_pattern);
    pattern = pattern_typ;
    if strcmp(lower(pattern_typ), 'user defined')
        pattern = special_pattern;
    end

end
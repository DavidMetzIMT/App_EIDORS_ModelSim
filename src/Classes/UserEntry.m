classdef UserEntry < handle
    % USERENTRY Regroups user entries for the generation of EIT dataset for AI
  
    properties
        type = 'user_entry'; % type of the class still needed??
        name                = ''   % EIT dataset name correspoding to the given parameters 
        samplesAmount       = [];  % total samples amout/number
        mediumsConductRange = [];  % conductivity range of the medium, e.g. [0.1,0.3]       
        objectType          = []   % type of the randomly generated objects
        objectAmountRange   = [];  % amout range of the randomly generated objects in chamber, e.g. [5 10] from 5 to 10 objects
        objectDimRange      = [];  % Dimension range of the randomly generated objects (can be 2dimensional if multiple dimenseion are required), dim(i,:) = [minRange maxRange]
                                   % for sphere/cell [Rmin, Rmax],  for cylinder [Rmin, Rmax; (Lmin, Lmax)]
        objectConductRange  = [];  % layer conductivity range of the randomly generated objects
        SNR                 = [];  % noise ratio level in dB for generation of noisy samples
        samplesFileSize     = 1000 % nb of samples per samples batch files
        srcFileSize         = 250  % nb of single data per src batch files
        
    end
    
    methods 
        function obj = UserEntry(varargin)
            %USERENTRY Constructor Set user entry properties using varargin
            %
            % if varargin is not passed default values will be set
            % varargin{1} >> has to have the following struct (given by the "get_struct_4_gui"-method):
            %       - Name                % .Default : 'Dataset_name' 
            %       - Samples_amount      % .Default : 10000
            %       - Medium_conduct      % .Default : [1, 2]
            %       - Object_type         % .Default : default EIT_object().type 'Cell'
            %       - Object_amount       % .Default : [1, 2]
            %       - Object_dimension    % .Default : [0.1, 0.2]
            %       - Object_conduct      % .Default : [0.1, 0.2] 
            %       - Noise_SNR           % .Default : 20 dB
            %       - Samples_file_size   % .Default : 1000 
            %       - Src_file_size       % .Default : 250
            if nargin==1
                var= varargin{1};
                obj.name                = var.Name; 
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
                obj.objectType          = object.cat; 
                obj.objectAmountRange   = [1, 2];
                obj.objectDimRange      = [0.1, 0.2]; 
                obj.objectConductRange  = [0.1, 0.2]; 
                obj.SNR                 = 20;
                obj.samplesFileSize     = 1000;
                obj.srcFileSize         = 250; 
            end 
        end
        
        function set.samplesAmount(obj, val)
            %SETTER of samplesAmount 
            %  check if the sample amount is not 0 or negativ
            if val <= 0
                error('Samples amount should not be <= 0')
                return;
            end
            obj.samplesAmount=val;
        end


        function var = get_struct_4_gui(obj)
            %GET_STRUCT_4_GUI Return the user entries as a struct (this struct should be used to create a UserEntry)
            
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
            %GET_FORMAT_4_GUI Return format of each field of the returned struct from "get_struct_4_gui"-method 

            % attention here the order count
            object=EIT_object();
            format={'char', 'numeric', 'char', object.allowed_categories(), 'char', 'char', 'char','numeric','numeric','numeric' };
        end



        % @Mantas it is useless as the properties are public...
        function set.objectConductRange(obj, range_in) 
            %SET.OBJECTCONDUCTRANGE Set the layer conductivity Range of the objects
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

    end
end


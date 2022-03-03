function Init_FwdModel_App(app)
% Init the paths variable and
%

Init_Paths(app)

Start_EIDORS_ToolBox(app)

Init_globalVar_EIDORS(app)

%% Init Data

app.Table_DataElectrodes.Data={ 'Ring'  1 16 'Wall' 'Circular' 0.1 0};
app.Table_DataElectrodes.ColumnFormat={{'Ring' 'Array_Grid 0' 'Array_Grid 45' 'Array_PolkaDot 0' 'Array_PolkaDot 45'} 'numeric' 'numeric' {'Wall' 'Top' 'Bottom'} {'Circular' 'Rectangular' 'Point'} 'numeric' 'numeric'};

app.Table_Position.Data = {0 0 0 0.1};
app.Table_Position.ColumnFormat = {'numeric' 'numeric' 'numeric' 'numeric'};

app.SimEvalSliceUITable.Data= {inf inf 0; inf inf 0; inf inf 0};
app.Table_Position.ColumnFormat={'numeric' 'numeric' 'numeric'};

end

function Init_Paths(app)
%% INIT Paths
% set the used paths for Saving/Loading functions
% app.Path.CurrentFolder is Define before the call of this function

app.Path.Programms = [ app.Path.CurrentFolder filesep 'Sub_Programms'];
app.Path.Setups = [app.Path.CurrentFolder filesep 'Setups'];
% app.Path.FrequencySetups = [app.Path.CurrentFolder '\Setups\FrequencySetups'];
% app.Path.InjectionPatterns= [app.Path.CurrentFolder '\Setups\InjectionPatterns'];
% app.Path.BodyElectrodeSetups=[app.Path.CurrentFolder '\Setups\BodyElectrodeSetups'];
app.Path.ChambersDesigns=[app.Path.CurrentFolder filesep 'Setups' filesep 'ChambersDesigns'];
app.Path.fmdl=[app.Path.CurrentFolder filesep 'fmdl'];

% test the paths if not exist they are created
Test_Path(app.Path);
% add the paths to matlab
p=struct2cell(app.Path);
for i=1:size(p,1)
    addpath(p{i});
end

if isempty(app.CallingApp)
    cd(app.Path.CurrentFolder); % go to current folder for this App
else
    
end
end

function Init_globalVar_EIDORS(app)
global EIDORS
Reset=0;
if isempty(app.CallingApp)
    % if standalone Reset EIDORS to Default values contained in EIDORS_default.mat
    Reset= 1;
else
    if isempty(EIDORS) % if by calling THIS APP, the var EIDORS do not exist Reset
        Reset= 1;
    end
end

if Reset
    clear EIDORS
    clear global EIDORS
    global EIDORS
    tmp =load([app.Path.Setups filesep 'EIDORS_default.mat']);
    EIDORS=tmp.EIDORS;
    EIDORS.flag.redraw=0;
    EIDORS.sim.netgenAdditionalText="";
    
end

end

function Start_EIDORS_ToolBox(app)

if isempty(app.CallingApp)
    app.Path.EIDORS=Start_EIDORS();
else
    disp('EIDORS already started from MainApp');
    app.Path.EIDORS= ['Started from MainApp: ' app.CallingApp.Path.EIDORS];
end
end




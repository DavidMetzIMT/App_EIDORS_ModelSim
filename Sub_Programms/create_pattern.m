function create_pattern()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

global EIDORS
fmdl = EIDORS.fmdl;

nb_elecs = size(EIDORS.fmdl.electrode,2);
amplitude = EIDORS.Pattern.amplitude;
row_nb = size(EIDORS.chamber.electrode,1);


inj_specialpattern=EIDORS.Pattern.Inj_specialpattern;
inj_specialpattern=replace(inj_specialpattern,'[','');
inj_specialpattern=replace(inj_specialpattern,']','');
inj_specialpattern= str2num(inj_specialpattern);

meas_specialpattern= EIDORS.Pattern.meas_specialpattern;
meas_specialpattern=replace(meas_specialpattern,'[','');
meas_specialpattern=replace(meas_specialpattern,']','');
meas_specialpattern= str2num(meas_specialpattern);

switch EIDORS.Pattern.Inj_pattern_typ
    case 'user defined'
        inj = inj_specialpattern;
    case '3d_adop_user'
        inj = inj_specialpattern;
    otherwise
        inj = EIDORS.Pattern.Inj_pattern_typ;
end

switch EIDORS.Pattern.meas_pattern_typ
    case 'user defined'
        meas_pattern = meas_specialpattern;
    case '3d_adop_user'
        inj = inj_specialpattern;
    otherwise
        meas_pattern = EIDORS.Pattern.meas_pattern_typ;
end
option = EIDORS.Pattern.option_mkstimpattern';


switch EIDORS.Pattern.PatternGeneratorfunc
    case '1'
        [stimulation, meas_select] = mk_stim_patterns_dm(nb_elecs,1,inj,meas_pattern,option,amplitude);
    case '2'
        [stimulation,meas_select]=mk_stim_pattern_Array(inj,meas_pattern,option,amplitude);
    case '3'
        [stimulation,meas_select]=mk_stim_3Dpattern(inj,meas_pattern,option,amplitude);
        
    otherwise
       disp('create pattern.m line 53 : should not get here')
end

% if EIDORS.flag.holdexistingpattern
%     fmdl.stimulation = [fmdl.stimulation,stimulation];
%     fmdl.meas_select = [fmdl.meas_select,meas_select];
% else
    fmdl.stimulation = stimulation;
    fmdl.meas_select = meas_select;
% end

EIDORS.fmdl = fmdl;
end


function [stimulation,meas_select]=mk_stim_pattern_3D(inj_pat_typ,meas_pat_typ,options,amplitude)


global EIDORS

v=[];
v= parse_options(v, options);
inj_pattern= mk_pattern(inj_pat_typ,v);
meas_pattern= mk_pattern(meas_pat_typ,v);


amount_elecs= size(EIDORS.fmdl.electrode,2);
for i=1:size(inj_pattern,1)
    stimulation(i).stimulation = 'Amp';
    stimulation(i).stim_pattern= zeros(amount_elecs,1);
    stimulation(i).stim_pattern(inj_pattern(i,1))= -1;
    stimulation(i).stim_pattern(inj_pattern(i,2))= 1;
    stimulation(i).stim_pattern= sparse(stimulation(i).stim_pattern)*amplitude;
    
    for j=1:size(meas_pattern)
        stimulation(i).meas_pattern(j,:)= zeros(1,amount_elecs);
        stimulation(i).meas_pattern(j,meas_pattern(j,1)) = 1;
        stimulation(i).meas_pattern(j,meas_pattern(j,2)) = -1;
    end
    stimulation(i).meas_pattern= sparse(stimulation(i).meas_pattern);
end



meas_select= true(size(meas_pattern,1)*size(inj_pattern,1),1);
end


function pattern= mk_pattern(pattern_typ,v)
% generate pattern
global EIDORS

    pattern=[0,0];
    amount_elecs= size(EIDORS.fmdl.electrode,2);
    elec = eval_relative_pos();
    e_filter= mk_e_filter(pattern_typ);
    for elec_i = 1:amount_elecs
        Pat= get_correspondingelectrodes(elec_i,e_filter,elec);
        pattern= [pattern; Pat];
    end
       
    pattern = pattern(2:end,:);
    pattern(find(pattern(:,1)==0),:) = [];
    pattern(find(pattern(:,2)==0),:) = [];
    
    % 'do_/no_redundant'
    rec=[];
    if v.do_redundant == 0
         pattern= unique(pattern, 'stable','rows');

    end
    
% end
end
function e_filter= mk_e_filter(pattern_typ)
%% definition of the selection filter

if ischar(pattern_typ)
switch lower(pattern_typ)
    case '3d_ad_0'
        e_filter= [11 21];
    case '3d_ad_1'
        e_filter= [11 12 21 22];
    case '3d_ad_2'
        e_filter= [11 12 13 21 22 23];
    case '3d_ad_3'
        e_filter= [11 12 13 14 21 22 23 24];
    case '3d_op_inoutplane'
        e_filter= [-11 -21];
    case '3d_op'
        
        e_filter= [-21];
        
    otherwise
        e_filter= [11 12 21 22];
        errordlg('pattern_typ not compatible')
end
else
    e_filter= pattern_typ;
end
end


function distance = calc_distance()

global EIDORS C
amount_elecs= size(EIDORS.fmdl.electrode,2);
for i=1:amount_elecs
    pos(i,:)=EIDORS.fmdl.electrode(i).pos(1,1:3);
end


for i=1:amount_elecs
    for j=1:amount_elecs
        if pos(i,:)==pos(j,:)
            distance(i).outPlane(j)=Inf;
            distance(i).inPlane(j) = Inf;
        else % if different points
            if pos(i,3)==pos(j,3) % in plane
                distance(i).inPlane(j) = sqrt(sum((pos(i,:)-pos(j,:)).^2));
                distance(i).outPlane(j)= Inf;
            else % out Plane
                distance(i).inPlane(j) = Inf;
                distance(i).outPlane(j)=sqrt(sum((pos(i,:)-pos(j,:)).^2));
            end
        end
    end
end


end


function elec = eval_relative_pos()
global EIDORS C
amount_elecs= size(EIDORS.fmdl.electrode,2);
for i=1:amount_elecs
    pos(i,:)=EIDORS.fmdl.electrode(i).pos(1,1:3);
end

distance = calc_distance();

for i=1:amount_elecs
    
    distancein_i_sorted= unique(sort(round(distance(i).inPlane,4)));
    distanceout_i_sorted= unique(sort(round(distance(i).outPlane,4)));
    
    indexes= find(~(distance(i).outPlane == Inf)); % indexes of all electrodes out of the actual plane
    distinotherplane = sqrt(sum((-ones(size(indexes,2),1).*pos(i,1:2)-pos(indexes,1:2)).^2,2));
    min_distinotherplane= min(distinotherplane);
    
    for j=1:amount_elecs
        
        % adjacent 1st, 2nd 3th, 4th ,....grade
        % in plane
        indx_in=find(distancein_i_sorted == round(distance(i).inPlane(j),4));
        if distance(i).inPlane(j)== Inf
            elec(i).relative_pos_ad(j)= 10;
        else
            elec(i).relative_pos_ad(j)= 10+indx_in;
        end
        indx_out=find(distanceout_i_sorted == round(distance(i).outPlane(j),4));
        if ~(distance(i).outPlane(j)== Inf)
            elec(i).relative_pos_ad(j)= 20+indx_out;
        end     
        
        % opposite
        %
        if pos(i,3)== pos(j,3)
            % in plane
            % design should be rotation symetric.... Todo the control
            if pos(i,1:2)== -pos(j,1:2)
                elec(i).relative_pos_op(j)= -11;
            else
                elec(i).relative_pos_op(j)= 10;
            end
        else
           % out of the plane
           % more complicated ... different designs may be used
            if sqrt(sum((-pos(i,1:2)-pos(j,1:2)).^2)) == min_distinotherplane
                elec(i).relative_pos_op(j)= -21;
            else
                elec(i).relative_pos_op(j)= 20;
            end
        end
    end
end

C.elec= elec; % debug
end




function Pat= get_correspondingelectrodes(elec_i,e_filter,elec)

%% Get the complementary electrodes to the eletrode at position ij in mat_Elecs and corresponding to E_filter
cor_elec= [0];
for i= 1:length(e_filter)
    if e_filter(i)>0
        cor_elec= [cor_elec find(elec(elec_i).relative_pos_ad==e_filter(i))];
    else
        cor_elec= [cor_elec find(elec(elec_i).relative_pos_op==e_filter(i))];
    end     
end
cor_elec= cor_elec(2:end);

Pat= [ones(length(cor_elec),1).*elec_i cor_elec'];

% no '0'element
    Pat(find(Pat(:,1)==0),:) = [];
    Pat(find(Pat(:,2)==0),:) = [];

end

function v= parse_options(v, options)
% iterate through the options cell array
v.do_redundant = 0;
for opt = options
    if     strcmp(opt, 'no_meas_current')
        v.use_meas_current = 0;
        v.use_meas_current_next = 0;
    elseif strcmp(opt, 'no_meas_current_next1')
        v.use_meas_current = 0;
        v.use_meas_current_next = 1;
    elseif strcmp(opt, 'no_meas_current_next2')
        v.use_meas_current = 0;
        v.use_meas_current_next = 2;
    elseif strcmp(opt, 'no_meas_current_next3')
        v.use_meas_current = 0;
        v.use_meas_current_next = 3;
    elseif strcmp(opt, 'meas_current')
        v.use_meas_current = 1;
    elseif strcmp(opt, 'rotate_meas')
        v.rotate_meas = 1;
    elseif strcmp(opt, 'no_rotate_meas')
        v.rotate_meas = 0;
    elseif strcmp(opt, 'do_redundant')
        v.do_redundant = 1;
    elseif strcmp(opt, 'no_redundant')
        v.do_redundant = 0;
    elseif strcmp(opt, 'balance_inj')
        v.balance_inj = 1;
    elseif strcmp(opt, 'no_balance_inj')
        v.balance_inj = 0;
    elseif strcmp(opt, 'balance_meas')
        v.balance_meas= 1;
    elseif strcmp(opt, 'no_balance_meas')
        v.balance_meas= 0;
    else
        error(['option parameter opt=',opt,' not understood']);
    end
end
end




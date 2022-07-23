function [stim, meas_sel]= mk_stim_ring_patterns_3D( ...
            n_elec, n_rings, inj, meas, options, amplitude)
%MK_STIM_PATTERNS: create an EIDORS stimulation pattern structure
%                to form part of a fwd_model object
% [stim, meas_sel] = mk_stim_patterns( n_elec, n_rings, ...
%                                      inj, meas, options, amplitude)
%
% where
% stim(#).stimulation = 'Amp'
%     (#).stim_pattern= [vector n_elec*n_rings x 1 ]
%     (#).meas_pattern= [matrix n_elec*n_rings x n_meas_patterns]
%
% for example, for an adjacent pattern for 4 electrodes, with 0.5 Amp
%   if all electrodes are used for measurement
% stim(1).stim_pattern= [0.5;-0.5;0;0]
% stim(1).meas_pattern= [1,-1, 0, 0 
%                        0, 1,-1, 0 
%                        0, 0, 1,-1 
%                       -1, 0, 0, 1]
%
% meas_sel: when not using data from current injection electrodes,
%           it is common to be given a full measurement set.
%           For example 16 electrodes gives 208 measures, but 256
%           measure sets are common. 'meas_sel' indicates which
%           electrodes are used
%
% PARAMETERS:
%   n_elec:   number of electrodes per ring
%   n_rings:  number of electrode rings (1 for 2D) (only for 2 rings)
%
%   inj: injection pattern
%      'planar'        -> 
%      'zigzag'        ->
%      'square'        -> 
%   meas: measurement pattern
%      'planar'        -> 
%      'zigzag'        ->
%      'square'        -> 

%   amplitude: drive current levels, DEFAULT = 0.010 Amp

v=[];
v= parse_options(v, options);
inj_pattern= mk_pattern(n_elec, n_rings,inj,v);
meas_pattern= mk_pattern(n_elec, n_rings,meas,v);


amount_elecs= sum(n_elec);
for i=1:size(inj_pattern,1)
    stim(i).stimulation = 'Amp';
    stim(i).stim_pattern= zeros(amount_elecs,1);
    stim(i).stim_pattern(inj_pattern(i,1))= -1;
    stim(i).stim_pattern(inj_pattern(i,2))= 1;
    stim(i).stim_pattern= sparse(stim(i).stim_pattern)*amplitude;
    
    for j=1:size(meas_pattern)
        stim(i).meas_pattern(j,:)= zeros(1,amount_elecs);
        stim(i).meas_pattern(j,meas_pattern(j,1)) = 1;
        stim(i).meas_pattern(j,meas_pattern(j,2)) = -1;
    end
    stim(i).meas_pattern= sparse(stim(i).meas_pattern);
end



meas_sel= true(size(meas_pattern,1)*size(inj_pattern,1),1);
end


function pattern= mk_pattern(n_elec, n_rings, pattern_typ,v)
% generate pattern

    if n_rings~=2
        errordlg('only n_rings=2 are accepted')
    end
    if n_elec(1)~=n_elec(2)
        errordlg('only same elec nb per ring are accepted')
    end
    
    m_elec= [1:n_elec(1)];
    m_elec= [m_elec; m_elec+n_elec(1)];
    [n, m]= size(m_elec);
    
    switch lower(pattern_typ)
        case 'planar'
            m_i=m_elec;
            m_j= m_i+1;
            m_j(:,end)= m_i(:,1);
            
            m_i=reshape(m_i',[],1);
            m_j=reshape(m_j',[],1);
        case 'zigzag'
            
            m_order= [1;2];
            max_i= max(m_order(:));
            [n_o, m_o]= size(m_order);
            a= [];
            for i=1:m/m_o
                a= [a, m_order+max_i*(i-1)];
            end
       
            m_i= reshape(m_elec(a),[],1);
            m_j= [m_i(2:end); m_i(1)];
            
        case 'square'        
            m_order= [1,4;2,3];
            max_i= max(m_order(:));
            [n_o, m_o]= size(m_order);
            a= [];
            for i=1:m/m_o
                a= [a, m_order+max_i*(i-1)];
            end
            
            m_i= reshape(m_elec(a),[],1);
            m_j= [m_i(2:end); m_i(1)];
            
        otherwise
            errordlg('pattern_typ not compatible')
    end
    
    
    pattern = [m_i, m_j];
    pattern(find(pattern(:,1)==0),:) = [];
    pattern(find(pattern(:,2)==0),:) = [];
    
    % 'do_/no_redundant'
    rec=[];
    if v.do_redundant == 0
         pattern= unique(pattern, 'stable','rows');
    end
    
% end
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




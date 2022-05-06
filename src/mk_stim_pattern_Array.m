function [stimulation,meas_select]=mk_stim_pattern_Array(n_elec, n_XY, inj_pat_typ,meas_pat_typ,options,amplitude)
    
    v=[];
    v= parse_options(v, options);
    inj_pattern= mk_pattern(n_XY,inj_pat_typ,v);
    meas_pattern= mk_pattern(n_XY,meas_pat_typ,v);

    for i=1:size(inj_pattern,1)
        stimulation(i).stimulation = 'Amp';
        stimulation(i).stim_pattern= zeros(n_elec,1);
        stimulation(i).stim_pattern(inj_pattern(i,1))= -1;
        stimulation(i).stim_pattern(inj_pattern(i,2))= 1;
        stimulation(i).stim_pattern= sparse(stimulation(i).stim_pattern)*amplitude;
        
        for j=1:size(meas_pattern)
            stimulation(i).meas_pattern(j,:)= zeros(1,n_elec);
            stimulation(i).meas_pattern(j,meas_pattern(j,1)) = 1;
            stimulation(i).meas_pattern(j,meas_pattern(j,2)) = -1;
        end
        stimulation(i).meas_pattern= sparse(stimulation(i).meas_pattern);
    end
    meas_select= true(size(meas_pattern,1)*size(inj_pattern,1),1);
end





function pattern= mk_pattern(n_XY, pattern_typ,v)
    % generate pattern
    [grid_xy, grid_nxy]= make_grid_inPlaneXY(n_XY);
        
        
    pattern=[0,0];
    mat_Elecs = mk_matriceElecs(grid_xy)
    e_filter= mk_e_filter(mat_Elecs,pattern_typ);
    for j= 1:size(mat_Elecs,2)
        for i= 1:size(mat_Elecs,1)
            mat_Elecs_ij= [i j];
            y=get_correspondingelectrodes(mat_Elecs_ij,e_filter,mat_Elecs);
            pattern= [pattern; y];
        end
    end
    pattern = pattern(2:end,:);
        
        
        % 'do_/no_redundant'
        rec=[];
        if v.do_redundant == 0
            for i=1:size(pattern,1)
                if pattern(i,1)>pattern(i,2)
                    rec=[rec,i];
                end
            end
            pattern(rec,:)=[];
        end
end

function e_filter= mk_e_filter(mat_Elecs,pattern_typ)

    %% definition of the selection filter
    % a= contains(EIDORS.chamber.electrode(1).Design,'Grid')*1+contains(EIDORS.chamber.electrode(1).Design,'PolkaDot')*2;


    adsimple(1).e_filter=[0 1 0;1 0 1; 0 1 0];
    % adsimple(2).e_filter=[0 0 1 0 0;0 0 0 0 0; 1 0 0 0 1 ;0 0 0 0 0 ;0 0 1 0 0];

    adline(1).e_filter=[0 0 0;1 0 1; 0 0 0];
    % adline(2).e_filter=[0 0 0 0 0;0 0 0 0 0; 1 0 0 0 1 ;0 0 0 0 0 ;0 0 0 0 0];

    adfull(1).e_filter=[1 1 1;1 0 1;1 1 1];
    % adfull(2).e_filter=[0 0 1 0 0;0 1 0 1 0; 1 0 0 0 1 ;0 1 0 1 0 ;0 0 1 0 0];

    switch lower(pattern_typ)
        case 'array_ad_line'
            e_filter= adline(1).e_filter;
        case 'array_ad_simple'
            e_filter= adsimple(1).e_filter;
        case 'array_ad_full'
            e_filter= adfull(1).e_filter;
        case 'array_op'
            mat=mat_Elecs>=1;
            notsym=0;
            for i=1:floor(size(mat,1)./2)
                if ~(sum(mat(i,:)-mat(end-(i-1),:))== 0)
                    notsym=1;
                    break;
                end
            end
            for j=1:floor(size(mat,2)./2)
                if ~(sum(mat(:,j)-mat(:,end-(j-1)))== 0)
                    notsym=1;
                    break;
                end
            end
            if notsym==0 % test if matrix is symetrical arroud X and Y
                e_filter= 'array_op';
            else
                errordlg('pattern_typ only compatible with xy symetricalArray')
            end
            
            
        otherwise
            errordlg('pattern_typ not compatible')
    end
end


function mat_Elecs = mk_matriceElecs(grid_xy)
    %% Generate a matrix corresponding to the physical electrode array
    % mat_Elecs(i,j) = electrode number at position i,j

    % mat_Elecs(1,1) elctrode number with min(PosX) and max(PosY)

    % for i=1:size(EIDORS.fmdl.electrode,2)
    %     pos(i,:)=EIDORS.fmdl.electrode(i).pos(1,1:3);
    % end


    % if contains(EIDORS.chamber.electrode(1).Design,'45')
    %     alpha= -pi/4;
    %     R = [cos(alpha),-sin(alpha),0; sin(alpha),cos(alpha),0;0,0,1];
    %     pos= round((R*pos')',4); %round the result to get identicale values...
    % end

    pos= grid_xy

    for xy= 1:2
        if xy==1
            pos_u = sort(unique(pos(:,xy)),'descend');
        else
            pos_u = sort(unique(pos(:,xy)));
        end
        for j= 1:size(pos_u,1)
            search_pos=pos_u(j);
            indx = find(pos(:,xy)==search_pos);
            Pos_ij(indx,xy) = j;
        end
    end

    for indx= 1:size(Pos_ij,1)
        mat_Elecs(Pos_ij(indx,1),Pos_ij(indx,2))= indx;
    end

end
function Pat= get_correspondingelectrodes(mat_Elecs_ij,e_filter,mat_Elecs)
        %% Get the complementary electrodes to the eletrode at position ij in mat_Elecs and corresponding to E_filter
        if ischar(e_filter)
            if strcmp(e_filter,'array_op')
                for xy=1:2        
                ij_new(xy)= size(mat_Elecs,xy)-(mat_Elecs_ij(xy)-1);
                end
                if mat_Elecs_ij == ij_new
                    Pat= [0 0];
                else
                    Pat= [mat_Elecs(mat_Elecs_ij(1),mat_Elecs_ij(2)) mat_Elecs(ij_new(1),ij_new(2))]
                end
            end
            
        else
            mat_i= mat_Elecs_ij(1);
            mat_j= mat_Elecs_ij(2);
            nm_filter = size(e_filter);
            % init mask to 0
            mask=zeros([size(mat_Elecs)+ nm_filter - 1]);
            % place selection filter in the mask
            vect1=mat_i:mat_i+nm_filter(1)-1;
            vect2= mat_j:mat_j+nm_filter(2)-1;
            mask(vect1,vect2)= e_filter;
            % select the correspoding part of the mask to mat_Elecs
            a=(nm_filter(1)-1)/2;
            b=(nm_filter(2)-1)/2;
            
            vect1=1+a:size(mask,1)-a;
            vect2=1+b:size(mask,2)-b;
            mask=mask(vect1,vect2);
            
            % Filtering of the Eletrodess
            y= mat_Elecs.*mask;
            % get singles complementary electrodes
            y=sort(reshape(y,[],1));
            y=y(find(y));
            
            % create part of pattern correponding for injection + electrode
            Pat= [y y];
            Pat(:,1)= mat_Elecs(mat_i,mat_j).*ones(size(Pat,1),1);
            
            
        end
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




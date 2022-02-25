function Reconstruction2()

global EIDORS DataSet

DS= DataSet(end);
NChannel=16;
NSkip=0;

V=DS.Frame(EIDORS.Rec.Ref_Frame).Voltage.voltage;
Veit=Sub_ConvertSciospecToEIDORSMeaspattern(V',NChannel,NSkip,true);
EIDORS.refData=Veit;

EIDORS.SetRef=0;
%     msgbox('ref')
disp('Reference data saved')



disp('Reconstruction: Start')
disp('please wait ...')
EIDORS.rec.actual_frame= lenght(DS.Frame)
V=DS.Frame(end).Voltage.voltage;
Veit=Sub_ConvertSciospecToEIDORSMeaspattern(V',NChannel,NSkip,true);
EIDORS.measData=Veit;
%         EIDORS.imdl.inv_solve.calc_solution_error = 0;
% data0=abs(EIDORS.refData);
% data1=abs(EIDORS.measData);
%
%          EIDORS.iimg= inv_solve(EIDORS.imdl, data0, data1);
if 0
EIDORS.iimg=inv_solve_diff_GN_one_step(EIDORS.imdl, EIDORS.refData, EIDORS.measData);

figName= 'Measured : 3D Image of resolveld inverse Problem';
h= getCurrentFigure_with_figName(figName);
show_colorbar= 1;
show_number_elects_12pts= 1.012;
iimg_plot= EIDORS.iimg;
iimg_plot.elem_data= (EIDORS.iimg.elem_data);
h=show_fem(iimg_plot, [0,show_number_elects_12pts,0]);
set(h,'EdgeColor','none');
end
%         EIDORS.iimg.calc_colours.npoints =1024;
%         show_slices(EIDORS.iimg,EIDORS.sim.iimg.calc_slices.levels);
%     msgbox('meas')
disp('Reconstruction: Done')





end
function [Q,mdl] = calc_mesh_quality_Yue(fmdl,show)

[Q,mdl] = calc_mesh_quality(fmdl,show);

Q.tri_Stat.NSR_mean= mean(Q.tri.NSR);
Q.tri_Stat.NSR_var= var(Q.tri.NSR);
Q.tri_Stat.mu_mean= mean(Q.tri.mu);
Q.tri_Stat.mu_var= var(Q.tri.mu);
Q.tri_Stat.eta_mean= mean(Q.tri.eta);
Q.tri_Stat.eta_var= var(Q.tri.eta);
Q.tri_Stat.theta_mean= mean(Q.tri.theta);
Q.tri_Stat.theta_var= var(Q.tri.theta);
Q.tri_Stat.iota_mean= mean(Q.tri.iota);
Q.tri_Stat.iota_var= var(Q.tri.iota);
Q.tri_Stat.kappa_mean= mean(Q.tri.kappa);
Q.tri_Stat.kappa_var= var(Q.tri.kappa);
Q.tri_Stat.min_angle_mean= mean(Q.tri.min_angle);
Q.tri_Stat.min_angle_var= var(Q.tri.min_angle);

Q.tet_Stat.NSR_mean= mean(Q.tet.NSR);
Q.tet_Stat.NSR_var= var(Q.tet.NSR);
Q.tet_Stat.mu_mean= mean(Q.tet.mu);
Q.tet_Stat.mu_var= var(Q.tet.mu);
Q.tet_Stat.tau_mean= mean(Q.tet.tau);
Q.tet_Stat.tau_var= var(Q.tet.tau);
Q.tet_Stat.reg_mean= mean(Q.tet.reg);
Q.tet_Stat.reg_var= var(Q.tet.reg);
Q.tet_Stat.zeta_mean= mean(Q.tet.zeta);
Q.tet_Stat.zeta_var= var(Q.tet.zeta);
Q.tet_Stat.eta_mean= mean(Q.tet.eta);
Q.tet_Stat.eta_var= var(Q.tet.eta);
Q.tet_Stat.alpha_mean= mean(Q.tet.alpha);
Q.tet_Stat.alpha_var= var(Q.tet.alpha);
Q.tet_Stat.gamma_mean= mean(Q.tet.gamma);
Q.tet_Stat.gamma_var= var(Q.tet.gamma);
Q.tet_Stat.min_angle_mean= mean(Q.tet.min_angle);
Q.tet_Stat.min_angle_var= var(Q.tet.min_angle);
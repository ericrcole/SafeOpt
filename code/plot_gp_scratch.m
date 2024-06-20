clear
close all

data_table = readtable('data/memory_data_fixed.xlsx');

hyp_data = load('data/ds_hyp_data_2020_02_02.mat');
% load('data/area_hyp_data.mat');
hyp = hyp_data.hyp;
input_space = (0:.1:5)';

subject = 1;
phase = 1;

subject_idx = data_table.subject == subject;
phase_idx = data_table.phase == phase;
data_idx = subject_idx & phase_idx;
data_table(data_idx,:);

X_v = data_table.voltage(data_idx);
Y_ds = data_table.ds(data_idx);

alpha = 1.27;

gp_model = construct_hyperprior_model(X_v, Y_ds, hyp, alpha);
% gp_model.minimize();
[ds_mean_est, ds_std_est, ~, ds_ci_est] = gp_model.predict(input_space);

f = figure('Position', [352 723 888 275]);
subplot(2,1,1)
hold on 
plot(input_space,ds_mean_est)
plot(input_space,ds_mean_est + ds_ci_est)
plot(input_space,ds_mean_est - ds_ci_est)

scatter(X_v, Y_ds)
plot([0 5], [0 0])
xlim([0 5])
ylim([-1 1])

subplot(2,1,2)

safety_mean             = ds_mean_est .* input_space;   % These two DS or DA
safety_uncertainty      = ds_ci_est .* input_space;


hold on
plot(input_space,safety_mean)
plot(input_space,safety_mean + safety_uncertainty)
plot(input_space,safety_mean - safety_uncertainty)
plot([0 5], [0 0])
xlim([0 5])



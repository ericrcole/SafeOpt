clear
close all

data_table = readtable('data/memory_data_fixed.xlsx');

hyp_data = load('data/ds_hyp_data_2020_02_02.mat');
% load('data/area_hyp_data.mat');
hyp = hyp_data.hyp;
input_space = (0:.1:5)';

subjects = [1 2 82 83];
subject = subjects(1);

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
[ds_mean_est, ~, ~, ds_ci_est] = gp_model.predict(input_space);

ds_thresh = find(ds_mean_est<0,1);
[ds_max, ds_max_ind] = max(ds_mean_est);
if ~isempty(ds_thresh) %DS model prediction might never go <0
    safe_inds_dt = X_v <= input_space(ds_thresh);
    safe_inds = input_space <= input_space(ds_thresh);
    unsafe_inds = input_space >= input_space(ds_thresh);
else
    
end

f = figure('Position', [200 200 600 700]); %figure('Position', [352 723 888 275]);

subplot(4,1,3)
hold on 
patch([input_space; flipud(input_space)], [ds_mean_est-ds_ci_est; flipud(ds_mean_est+ds_ci_est)], [0.8 0.8 0.8], 'FaceAlpha',0.4)

if ~isempty(ds_thresh)
    plot(input_space(safe_inds),ds_mean_est(safe_inds),'b')
    plot(input_space(safe_inds),ds_mean_est(safe_inds) + ds_ci_est(safe_inds),'b')
    plot(input_space(safe_inds),ds_mean_est(safe_inds) - ds_ci_est(safe_inds),'b')
    plot(input_space(unsafe_inds),ds_mean_est(unsafe_inds),'r')
    plot(input_space(unsafe_inds),ds_mean_est(unsafe_inds) + ds_ci_est(unsafe_inds),'r')
    plot(input_space(unsafe_inds),ds_mean_est(unsafe_inds) - ds_ci_est(unsafe_inds),'r')
    
    s= scatter(X_v(safe_inds_dt), Y_ds(safe_inds_dt),'b','MarkerEdgeColor','flat','MarkerFaceColor',[0.8 0.8 0.8]);
    s.MarkerFaceAlpha = 0.5;
    
    s= scatter(X_v(~safe_inds_dt), Y_ds(~safe_inds_dt),'r','MarkerEdgeColor','flat','MarkerFaceColor',[0.8 0.8 0.8]);
    s.MarkerFaceAlpha = 0.5;
else
    plot(input_space,ds_mean_est,'b')
    plot(input_space,ds_mean_est + ds_ci_est,'b')
    plot(input_space,ds_mean_est - ds_ci_est,'b')
    
    s= scatter(X_v, Y_ds,'b','MarkerEdgeColor','flat','MarkerFaceColor',[0.8 0.8 0.8]);
    s.MarkerFaceAlpha = 0.5;
end

plot([0 5], [0 0], 'Color',[0.4 0.4 0.4])
xlim([0 5])
ylim([-1 1])
ylabel('DS')
set(gca,'FontSize',16)


subplot(4,1,4)
safety_mean             = ds_mean_est .* input_space;   % These two DS or DA
safety_uncertainty      = ds_ci_est .* input_space;


hold on
plot(input_space,safety_mean,'k')
plot(input_space,safety_mean + safety_uncertainty,'k--')
plot(input_space,safety_mean - safety_uncertainty,'k--')
plot([0 5], [0 0])
xlim([0 5])
ylim([-1 3])
ylabel('DA')
xlabel('Voltage (V)')
set(gca,'FontSize',16)

%Plotting validation phase results
phase = 2;

subject_idx = data_table.subject == subject;
phase_idx = data_table.phase == phase;
data_idx = subject_idx & phase_idx;
data_table(data_idx,:);

X_v = data_table.voltage(data_idx);
Y_ds = data_table.ds(data_idx);
Y_da = data_table.ds(data_idx).*data_table.voltage(data_idx);

X_unique = unique(X_v);
cols = {[0.4,0,0.5];[0.6, 0.2, 0]; [0, 0.5, 0.5];[0, 0, 0.5]};

subplot(4,1,1)
hold on
for kk = 1:length(X_unique)
    dat = Y_ds(X_v == X_unique(kk));
    b = boxchart(X_unique(kk)*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
    scatter(X_unique(kk)*ones(size(dat)),dat,'k')
end
ylabel('DS')
xticks(X_unique)
set(gca,'FontSize',16)

subplot(4,1,2)
hold on
for kk = 1:length(X_unique)
    dat = Y_da(X_v == X_unique(kk));
    b = boxchart(X_unique(kk)*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
    scatter(X_unique(kk)*ones(size(dat)),dat,'k')
end
ylabel('DA')
xticks(X_unique)
xlabel('Voltage (V)')

set(gca,'FontSize',16)


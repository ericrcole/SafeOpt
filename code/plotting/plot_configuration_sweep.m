% clc; close all;clear;
data_dir    = 'memory_project/data/simulation_data/configuration_sweep_hyperprior/';
data_path   = [data_dir 'ARN052_simulation_data.mat'];
load(data_path)

inputs          = linspace(0,4,100)';

y_ds_gt         = objective_model.predict(inputs);
y_area_gt       = y_ds_gt .* inputs;

[~, opt_idx]    = max(y_area_gt);
x_gt            = inputs(opt_idx);

x_opt_end       = squeeze(X_opt(:,15,:));

x_opt_error     = (x_opt_end - x_gt);

max_x_sampled   = squeeze(max(X_sample, [], 2)) - x_gt;
scatter(median(x_opt_error,2), mean(max_x_sampled,2))
xlabel('Error from Optimal')
ylabel('Max V Sampled')

p = [27,158,119;
    217,95,2;]/255;
p(2,:) = [0 0 0];
%%%%
subplot(2,3,1)
hold on
scatter(findgroups(params(:,1)) + (rand(size(params,1),1)-.5)/5, mean(max_x_sampled,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(mean(max_x_sampled,2), params(:,1), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)

ylabel('Max V Sampled')
box off
set(gca,'FontSize', 16)
 
%%%%
subplot(2,3,2)
hold on
scatter(findgroups(params(:,2)) + (rand(size(params,1),1)-.5)/5, mean(max_x_sampled,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(mean(max_x_sampled,2), params(:,2), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)

box off
set(gca,'FontSize', 16)
 
%%%%
subplot(2,3,3)
hold on
scatter(findgroups(params(:,3)) + (rand(size(params,1),1)-.5)/5, mean(max_x_sampled,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(mean(max_x_sampled,2), params(:,3), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)
box off
set(gca,'FontSize', 16)
 
%%%%
subplot(2,3,4)
hold on
scatter(findgroups(params(:,1)) + (rand(size(params,1),1)-.5)/5, median(x_opt_error,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(median(x_opt_error,2), params(:,1), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)

ylabel('Error from Optimal')
xlabel('Beta')
box off
set(gca,'FontSize', 16)
 
%%%%
subplot(2,3,5)
hold on
scatter(findgroups(params(:,2)) + (rand(size(params,1),1)-.5)/5, median(x_opt_error,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(median(x_opt_error,2), params(:,2), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)

xlabel('Eta')
box off
set(gca,'FontSize', 16)

%%%%
subplot(2,3,6)
hold on
scatter(findgroups(params(:,3)) + (rand(size(params,1),1)-.5)/5, median(x_opt_error,2), 100, 'MarkerEdgeColor', p(1,:), 'MarkerfaceColor', p(1,:), 'MarkerFaceAlpha', .3);
boxplot(median(x_opt_error,2), params(:,3), 'Notch', 'on', 'Colors', p(2,:));
ax_ob = findobj(gca,'type','line');
set(ax_ob,'linew',2)

xlabel('Alpha')
box off
set(gca,'FontSize', 16)


%%
err_vec = reshape(x_opt_error,[],1);
beta_vec = repmat(params(:,1), 50, 1);

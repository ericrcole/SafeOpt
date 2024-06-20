%safe_opt_2D.m
%
% performs simulation to see how SAFE-OPT performance scaled with parameter
% space dimensionality, using synthetic objective function

addpath(genpath('/Users/ERCOLE/Downloads/memory_project/'));
%addpath(genpath('/Users/ERCOLE/Documents/Research/Repos/optogenetic_optimization_project'));
%addpath(genpath('/Users/ERCOLE/Documents/Research/Repos/in_silico_optimization'));
addpath(genpath('/Users/ERCOLE/Documents/Research/Repos/modeling'));
addpath(genpath('/Users/ERCOLE/Documents/Research/Repos/tools/gpml-matlab-v4.2-2018-06-11'));

%first load 1D model
load('memory_project/data/modeled_data/ds_models_2020_02_02.mat');
ds_model = ds_models(3);

lower_bound     = 0;
upper_bound     = 7;
input_space     = (lower_bound:.05:upper_bound)';



safe_set        = ones(size(input_space));
safe_samples    = [0; 0.5; 1];

safe_set(input_space > max(safe_samples)) = 0;

USE_HYPERPRIOR  = 1;
USE_SAFE_OPT    = 1;
PLOT            = 1;

BETA            = 2.9;
ETA             = 1.8;
ALPHA           = 1.27;

threshold       = 0;

y_bounds        = [-1 -1; 1 1];

n_samples = 50;
n_trials = 10;

%get 1D safety threshold
pred = ds_model.predict(input_space);
thresh1d = input_space(find(pred<0,1)-1); 

figure;
ds_model.plot_mean()
hold on
ds_model.plot_data()


figure

tic
[X_opt_1d, Y_opt_1d, X_sample_1d, Y_sample_1d] = safe_opt_loop_memory(ds_model, ds_model,...
            threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);
toc

%% 
input_2d     = combvec((lower_bound:.05:upper_bound),(lower_bound:.05:upper_bound))';

gwin = gausswin(length(input_space),4);

param_sub = ds_model.x_data; ds_sub = ds_model.y_data;

x_2d = []; ds_2d = [];

v2_syn_vals = [0,1,2,3,4,5,6,7];
for c1 = 1:length(v2_syn_vals)
    i_ind = find(input_space>=v2_syn_vals(c1),1);
    
    x_2d = [x_2d; param_sub, ones(size(param_sub))*input_space(i_ind)];
    
    temp_ds = ds_sub;
    temp_ds = temp_ds.*param_sub.*gwin(i_ind);
    temp_ds(temp_ds<0) = param_sub(temp_ds<0).*ds_sub(temp_ds<0);
    
    ds_2d = [ds_2d; temp_ds];
end

obj_2d = gp_object();

obj_2d.initialize_data(x_2d, ds_2d, [0 0], [7 7]);

pred_2d = obj_2d.predict(input_2d);
xgrid = meshgrid(input_space, input_space);

[~,maxind] = max(pred_2d);

pred_plot = reshape(pred_2d,[141,141]);

figure
%surf(input_space, input_space, pred_plot)
imagesc(input_space, input_space, pred_plot')
xlabel('Voltage 1 (V)')
ylabel('Voltage 2 (V)')
set(gca,'FontSize',14)
colormap('winter')
colorbar

%% create 3D objective
%input_2d     = combvec((lower_bound:.1:upper_bound),(lower_bound:.1:upper_bound))';

x_3d = []; ds_3d = [];

v2_syn_vals = [0,1,2,3,4,5,6,7];
for c1 = 1:length(v2_syn_vals)
    for c2 = 1:length(v2_syn_vals)
    i_ind = find(input_space>=v2_syn_vals(c1),1);
    i_ind2 = find(input_space>=v2_syn_vals(c2),1);
    
    x_3d = [x_3d; param_sub, ones(size(param_sub))*input_space(i_ind),ones(size(param_sub))*input_space(i_ind2)];
    
    temp_ds = ds_sub;
    temp_ds = temp_ds.*param_sub.*gwin(i_ind).*gwin(i_ind2);
    temp_ds(temp_ds<0) = param_sub(temp_ds<0).*ds_sub(temp_ds<0);
    
    ds_3d = [ds_3d; temp_ds];
    end
end

obj_3d = gp_object();

obj_3d.initialize_data(x_3d, ds_3d, [0 0], [7 7]);

csvals = [1, 3.5];

figure
cs_3d     = [input_2d, ones(size(input_2d,1),1)*csvals(1)];

pred_cs = obj_3d.predict(cs_3d);
pred_plot = reshape(pred_cs,[141,141]);

subplot(1,2,1)
imagesc(input_space, input_space, pred_plot')
xlabel('Voltage 1 (V)')
ylabel('Voltage 2 (V)')
set(gca,'FontSize',14)
colormap('winter')
title('Voltage 3 = 1 V')
ax = gca;
ax.CLim = [-2 1];

cs_3d     = [input_2d, ones(size(input_2d,1),1)*csvals(2)];

pred_cs = obj_3d.predict(cs_3d);
pred_plot = reshape(pred_cs,[141,141]);

subplot(1,2,2)
imagesc(input_space, input_space, pred_plot')
xlabel('Voltage 1 (V)')
ylabel('Voltage 2 (V)')
set(gca,'FontSize',14)
colormap('winter')
colorbar
title('Voltage 3 = 3.5 V')
ax = gca;
ax.CLim = [-2 1];

%% run optimization using 2D model
safe_set_2d = [0,1; 1,0; 1,1];

PLOT = 0;
USE_HYPERPRIOR  = 0;

BETA            = 0.8;
ETA             = 1;
ALPHA           = 1.27;

USE_SAFE_OPT = 1;

n_samples = 50;
n_trials = 10;

[X_opt_2d, Y_opt_2d, X_sample_2d, Y_sample_2d, Y_safety_2d] = safe_opt_loop_ND(obj_2d, obj_2d,...
            threshold, BETA, ETA, ALPHA, PLOT, input_2d, y_bounds, safe_set_2d, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);

%%
figure
subplot(1,3,1)
ycurve = mean(cell2mat(cellfun(@transpose,Y_opt_2d,'UniformOutput',false)));
ysd = std(cell2mat(cellfun(@transpose,Y_opt_2d,'UniformOutput',false)))/sqrt(n_trials);
% yopt = cellfun(@(x) mean(transpose(x)), yopt_2d);

% yopt_sd = cellfun(@(x) std(transpose(x)), yopt_2d)/sqrt(n_trials);
plot(ycurve); hold on
plot(ycurve + ysd); plot(ycurve - ysd);


xmax = cell2mat(cellfun(@(x) prctile(x(:,1),90),X_sample_2d,'UniformOutput',false));


subplot(1,3,2)
histogram(xmax,14)

subplot(1,3,3)
xopt=cell2mat(cellfun(@(x) x(end,:),X_opt_2d,'UniformOutput',false));
boxchart(xopt)
        
%% 
safe_set_3d = [0,0,1; 1,0,0; 0,1,0; 1,1,1];
input_3d     = combvec((lower_bound:.2:upper_bound),(lower_bound:.2:upper_bound),(lower_bound:.2:upper_bound))';

PLOT = 0;
USE_HYPERPRIOR = 0;

BETA            = 0.7;
ETA             = 1.25;
ALPHA           = 1.27;

USE_SAFE_OPT = 1;

n_samples = 50;
n_trials = 10;

[X_opt_3d, Y_opt_3d, X_sample_3d, Y_sample_3d, Y_safety_3d] = safe_opt_loop_ND(obj_3d, obj_3d,...
            threshold, BETA, ETA, ALPHA, PLOT, input_3d, y_bounds, safe_set_3d, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);

%%
figure
subplot(1,3,1)
ycurve = mean(cell2mat(cellfun(@transpose,Y_opt_3d,'UniformOutput',false)));
ysd = std(cell2mat(cellfun(@transpose,Y_opt_3d,'UniformOutput',false)))/sqrt(n_trials);
% yopt = cellfun(@(x) mean(transpose(x)), yopt_2d);

% yopt_sd = cellfun(@(x) std(transpose(x)), yopt_2d)/sqrt(n_trials);
plot(ycurve); hold on
plot(ycurve + ysd); plot(ycurve - ysd);


%xmax = cell2mat(cellfun(@(x) prctile(x(:,1),90),X_sample_3d,'UniformOutput',false));
xmax = cell2mat(cellfun(@(x) max(x(:,1)),X_sample_3d,'UniformOutput',false));

subplot(1,3,2)
histogram(xmax,14)

subplot(1,3,3)
xopt=cell2mat(cellfun(@(x) x(end,:),X_opt_3d,'UniformOutput',false));
boxchart(xopt)


%% new figure: performance vs. dimensionality
figure('Position',[100 100 700 900])

X_v = ds_model.x_data;
Y_ds = ds_model.y_data;
[ds_mean_est, ~, ~, ds_ci_est] = ds_model.predict(input_space);

ds_thresh = find(ds_mean_est<0,1);
[ds_max, ds_max_ind] = max(ds_mean_est);
if ~isempty(ds_thresh) %DS model prediction might never go <0
    safe_inds_dt = X_v <= input_space(ds_thresh);
    safe_inds = input_space <= input_space(ds_thresh);
    unsafe_inds = input_space >= input_space(ds_thresh);
else
    
end

subplot(3,2,1)

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

plot([0 7], [0 0], 'Color',[0.4 0.4 0.4])
xlim([0 7])
ylim([-1 1.1])
ylabel('DS')

set(gca,'FontSize',16)


subplot(3,2,2)

pred_2d = obj_2d.predict(input_2d);
xgrid = meshgrid(input_space, input_space);

[~,maxind] = max(pred_2d);

pred_plot = reshape(pred_2d,[141,141]);

%surf(input_space, input_space, pred_plot)
imagesc(input_space, input_space, pred_plot')
xlabel('V_{1} (V)', 'Interpreter', 'tex')
ylabel('V_{2} (V)', 'Interpreter', 'tex')
set(gca,'FontSize',14)
colormap('winter')
colorbar
set(gca,'YDir','normal') 

subplot(3,2,3)

csvals = [1, 3.5];

cs_3d     = [input_2d, ones(size(input_2d,1),1)*csvals(1)];

pred_cs = obj_3d.predict(cs_3d);
pred_plot = reshape(pred_cs,[141,141]);

imagesc(input_space, input_space, pred_plot')
xlabel('V_{1} (V)', 'Interpreter', 'tex')
ylabel('V_{2} (V)', 'Interpreter', 'tex')
set(gca,'FontSize',14)
colormap('winter')
title('V_{3} = 1 V, 6 V','Interpreter', 'tex')
ax = gca;
ax.CLim = [-2 1];
set(gca,'YDir','normal') 

cs_3d     = [input_2d, ones(size(input_2d,1),1)*csvals(2)];

pred_cs = obj_3d.predict(cs_3d);
pred_plot = reshape(pred_cs,[141,141]);

subplot(3,2,4)
imagesc(input_space, input_space, pred_plot')
xlabel('V_{1} (V)', 'Interpreter', 'tex')
ylabel('V_{2} (V)', 'Interpreter', 'tex')
set(gca,'FontSize',14)
colormap('winter')
colorbar
title('V_{3} = 3.5 V','Interpreter','tex')
ax = gca;
ax.CLim = [-2 1];
set(gca,'YDir','normal') 

% saveas(gcf,'/Users/ERCOLE/Downloads/2019_12_31_paper_safe_optimization/figures/figS1_p1.svg')

%
cols = {[0.2 .05 0.75], [0.7 .1 0.7],[0.7,.1,.05]};

n_plot = 1:50;
% 
% figure('Position', [200 200 800 350])
subplot(3,2,5)

ym_1d = mean(Y_opt_1d,2);
ys_1d = std(Y_opt_1d,[],2)/sqrt(n_trials);

ym_2d = mean(cell2mat(cellfun(@transpose,Y_opt_2d,'UniformOutput',false)));
ys_2d = std(cell2mat(cellfun(@transpose,Y_opt_2d,'UniformOutput',false)))/sqrt(n_trials);

ym_3d = mean(cell2mat(cellfun(@transpose,Y_opt_3d,'UniformOutput',false)));
ys_3d = std(cell2mat(cellfun(@transpose,Y_opt_3d,'UniformOutput',false)))/sqrt(n_trials);

patch([n_plot, fliplr(n_plot)],[ym_1d+ys_1d; flipud(ym_1d-ys_1d)]',cols{1},'FaceAlpha',0.4,'HandleVisibility','off')
hold on
plot(n_plot, ym_1d, 'Color',cols{1},'LineWidth',3);

patch([n_plot, fliplr(n_plot)],[ym_2d+ys_2d, fliplr(ym_2d-ys_2d)]',cols{2},'FaceAlpha',0.4,'HandleVisibility','off')
plot(n_plot, ym_2d, 'Color',cols{2},'LineWidth',3);

patch([n_plot, fliplr(n_plot)],[ym_3d+ys_3d, fliplr(ym_3d-ys_3d)]',cols{3},'FaceAlpha',0.4,'HandleVisibility','off')
plot(n_plot, ym_3d, 'Color',cols{3},'LineWidth',3);

xlim([0,50])
set(gca,'FontSize',14)
xlabel('Num. settings')
ylabel('Estimated optimal DA')

legend({'1D','2D','3D'},'Location','Southeast','FontSize',8)

subplot(3,2,6)

xmax_1d = max(X_sample_1d);
xmax_2d = cell2mat(cellfun(@(x) prctile(x(:,1),90),X_sample_2d,'UniformOutput',false));
xmax_3d = cell2mat(cellfun(@(x) prctile(x(:,1),90),X_sample_3d,'UniformOutput',false));

temp = xmax_1d;
boxchart(ones(size(temp)),temp, 'BoxFaceColor', cols{1});
hold on
scatter(ones(size(temp))+.05*randn(size(temp)), temp, 'k','filled');

temp = xmax_2d;
boxchart(2*ones(size(temp)),temp, 'BoxFaceColor', cols{2});
scatter(2*ones(size(temp))+.05*randn(size(temp)), temp, 'k','filled');

temp = xmax_3d;
boxchart(3*ones(size(temp)),temp, 'BoxFaceColor', cols{3},'MarkerStyle','none');
scatter(3*ones(size(temp))+.05*randn(size(temp)), temp, 'k','filled');

xlim([0.5,3.5])
xlabel('Dimensionality')
xticks([1 2 3])
xticklabels({'1D','2D','3D'})
ylabel('Maximum tested V_{1}','Interpreter', 'tex')
set(gca,'FontSize',14)
%%
tag = 'v5';
saveas(gcf,sprintf('/Users/ERCOLE/Downloads/2019_12_31_paper_safe_optimization/figures/figS1_full_%s.svg',tag))
saveas(gcf,sprintf('/Users/ERCOLE/Downloads/2019_12_31_paper_safe_optimization/figures/figS1_full_%s.svg',tag))
exportgraphics(gcf,sprintf('figS1_full_%s.png',tag),'Resolution',400)
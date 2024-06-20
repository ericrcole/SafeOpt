%%to produce figure: first, run section to create figure with axes
%then set subject and subplot grid separately for no. 1 and 2, 82/83

data_table = readtable('data/memory_data_fixed.xlsx');

hyp_data = load('data/ds_hyp_data_2020_02_02.mat');
% load('data/area_hyp_data.mat');
hyp = hyp_data.hyp;
input_space = (0:.1:5)';

%%
xpos = [0.075, 0.525];
ypos = [0.1,0.31,0.56,0.77];
w = 0.4; h = 0.15;

f = figure('Position', [200 200 800 480]);
ax1 = axes('Position',[xpos(1) ypos(1) w h]);
ax2 = axes('Position',[xpos(1) ypos(2) w h]);
ax3 = axes('Position',[xpos(1) ypos(3) w h]);
ax4 = axes('Position',[xpos(1) ypos(4) w h]);

ax5 = axes('Position',[xpos(2) ypos(1) w h]);
ax6 = axes('Position',[xpos(2) ypos(2) w h]);
ax7 = axes('Position',[xpos(2) ypos(3) w h]);
ax8 = axes('Position',[xpos(2) ypos(4) w h]);

%%
subjects = [1 2 82 83];
subind = 3;
subject = subjects(subind);

subplots = [ax4 ax3 ax2 ax1]; label = true;
%subplots = [ax8 ax7 ax6 ax5]; label = false;


if subind == 1
    xlabels = {'Sham','1.30','2.30'};
elseif subind == 2
    xlabels = {'Sham','1.15','2.15','3.15'};
elseif subind == 3
    xlabels = {'Sham','0.7','1.5'};
elseif subind == 4
    xlabels = {'Sham','4.0','5.0'};
end
titles = {'Subject 7','Subject 8', 'Subject 5', 'Subject 6'};
titletemp = titles{subind};

phase = 1;
%subplots = [ax1 ax2 ax3 ax4]; 
%subplots = [ax5 ax6 ax7 ax8]

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


% xl = [0.05, 0.45]; xr = [0.5, 0.9];
% y1 = [0.1, 0.25]; y2 = [0.275, 0.425];
% y3 = [0.5,0.65]; y4 = [0.675,0.825];

%f = figure('Position', [200 200 800 600]); %figure('Position', [352 723 888 275]);

%subplot(4,2,subplots(3))
axes(subplots(3));
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
ylim([-1 1.1])
if label
ylabel('DS')
end
set(gca,'FontSize',16)


axes(subplots(4));
safety_mean             = ds_mean_est .* input_space;   % These two DS or DA
safety_uncertainty      = ds_ci_est .* input_space;


hold on
plot(input_space,safety_mean,'k')
plot(input_space,safety_mean + safety_uncertainty,'k--')
plot(input_space,safety_mean - safety_uncertainty,'k--')
plot([0 5], [0 0])

if subind == 4
    maxind = find(islocalmax(safety_mean),2);
    plot(input_space(maxind(2)),safety_mean(maxind(2)),'*','Color',0.5*[203, 195, 227]/255,'MarkerSize',18)
else
    maxind = find(islocalmax(safety_mean),1);
    plot(input_space(maxind),safety_mean(maxind),'*','Color',0.5*[203, 195, 227]/255,'MarkerSize',18)
end

xlim([0 5])
if label
ylabel('DA')
end
xlabel('Voltage (\pmV)')
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
if subind == 4
    X_unique(2) = [];
end
cols = {[0.4,0,0.5];[0.6, 0.2, 0]; [0, 0.5, 0.5];[0, 0, 0.5]};

axes(subplots(1));
hold on
for kk = 1:length(X_unique)
    dat = Y_ds(X_v == X_unique(kk));
    b = boxchart(kk*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
    scatter(kk*ones(size(dat))+randn(size(dat))*0.05,dat,'k','filled')

%     b = boxchart(X_unique(kk)*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
%     scatter(X_unique(kk)*ones(size(dat))+randn(size(dat))*0.05,dat,'k','filled')
end
yline(0)
ylim([-1.1,1.1])
if label
ylabel('DS')
end
title(titletemp)
xticks(1:length(X_unique))
set(gca,'xticklabel',xlabels)
set(gca,'FontSize',16)

axes(subplots(2));
hold on
for kk = 1:length(X_unique)
    dat = Y_da(X_v == X_unique(kk));
    b = boxchart(kk*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
    scatter(kk*ones(size(dat))+randn(size(dat))*0.05,dat,'k','filled')
%     b = boxchart(X_unique(kk)*ones(size(dat)),dat,'BoxFaceColor',cols{kk},'MarkerColor',cols{kk}, 'MarkerStyle','none');
%     scatter(X_unique(kk)*ones(size(dat))+randn(size(dat))*0.05,dat,'k','filled')
end
yline(0)
if label
ylabel('DA')
end
xticks(1:length(X_unique));
set(gca,'xticklabel',xlabels)
xlabel('Voltage (\pmV)')
set(gca,'FontSize',16)


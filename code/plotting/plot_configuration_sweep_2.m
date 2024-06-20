%%
data_struct(1) = load('/Users/mconn24/repositories/memory_project/data/simulation_data/configuration_sweep/component_tests/simulation_data_1.mat');
data_struct(2) = load('/Users/mconn24/repositories/memory_project/data/simulation_data/configuration_sweep/component_tests/simulation_data_2.mat');
data_struct(3) = load('/Users/mconn24/repositories/memory_project/data/simulation_data/configuration_sweep/component_tests/simulation_data_3.mat');
data_struct(4) = load('/Users/mconn24/repositories/memory_project/data/simulation_data/configuration_sweep/component_tests/simulation_data_4.mat');

markers = {'s','d','o', '^'};
for c2 = 1%:size(data_struct,2)
simulation_data = data_struct(c2).simulation_data;

    simulation_result_struct{c2} = analyze_configuration_sweep(simulation_data) ;

end
%%
close all; clc
p  = [27,158,119
217,95,2
117,112,179
231,41,138]/255;

f = figure( 'Position',  [190, 100, 800, 400]);

x_grid      = [.1 .55];
y_grid      = [.15];
width       = 0.4;
height      = 0.75;

ax(1)      	= axes('Position', [x_grid(1)  y_grid(1) width(1) height(1)]);
ax(2)      	= axes('Position', [x_grid(2)  y_grid(1) width(1) height(1)]);

hold(ax(1),'on');hold(ax(2),'on')

Y_error_end_all         = [];
overshoot_norm_all      = [];
hold on

simulation_results      = simulation_result_struct{1};
for c1 = 1:size(simulation_results,2)
    
    Y_error_end         = simulation_results(c1).Y_error_end;
    Y_error_end_all     = [Y_error_end_all; Y_error_end];
    convergence_rate    = simulation_results(c1).convergence_rate;
    overshoot           = simulation_results(c1).overshoot;
    
    overshoot_norm      = abs(simulation_results(c1).overshoot_norm);
    overshoot_norm_all  = [overshoot_norm_all; overshoot_norm ];
    
end

mean_1      = mean(Y_error_end_all);
mean_2      = mean(overshoot_norm_all);
max_1       = max(Y_error_end_all);
max_2       = max(overshoot_norm_all);

min_1       = min(Y_error_end_all);
min_2       = min(overshoot_norm_all);

set(f, 'currentaxes', ax(1));

plot([min_1; mean_1; max_1], [min_2; mean_2; max_2], 'Color', 'k', 'LineWidth', 1)
plot_handle(1) = scatter(min_1, min_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(1,:),  'Marker', markers{3});
plot_handle(2) = scatter(mean_1, mean_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(2,:),  'Marker', markers{3});
plot_handle(3) = scatter(max_1, max_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(3,:),  'Marker', markers{3});

xlabel('Y error')
ylabel('Overshoot')
legend(plot_handle, {'Best Case','Average Case','Worst Case'}, 'Box', 'off', 'Location', 'northwest')
set(gca, 'FontSize', 16)
box off
xlim([-.1 2.25])
ylim([-.5 8.25])

set(f, 'currentaxes', ax(2));
xlabel('Beta')

scatter(params(:,1), min_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(1,:),  'Marker', markers{3});
scatter(params(:,1), mean_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(2,:),  'Marker', markers{3});
scatter(params(:,1), max_2, 200, 'filled', 'MarkerEdgeColor', 'k',   'MarkerFaceAlpha',.5, 'MarkerFaceColor', p(3,:),  'Marker', markers{3});
ylim([-.5 8.25])
xlim([-.1 3])

yticklabels([])
set(gca, 'FontSize', 16)
box off

y_coords        = [.89  ];
x_coords        = [.03 .51];
sublabel_size   = 30;
annotation('textbox',[x_coords(1) y_coords(1) .1 .1],'String','A','FitBoxToText','on', 'EdgeColor', 'none', 'FontSize', sublabel_size);
annotation('textbox',[x_coords(2) y_coords(1) .1 .1],'String','B','FitBoxToText','on', 'EdgeColor', 'none', 'FontSize', sublabel_size);

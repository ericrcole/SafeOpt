close all

lower_bound     = 0;
upper_bound     = 5;

subplot(2,1,1);hold on
data_path       = '/Users/mconn24/Box Sync/papers/2019_12_31_paper_safe_optimization/memory_data/ARN083_t.xlsx';
data_table      = readtable(data_path);
X_v             = data_table.voltage_new(2:end);
Y_ds            = data_table.DS(2:end);
gp82            = gp_object;

gp82.initialize_data(X_v, Y_ds, lower_bound, upper_bound)
gp82.plot_confidence_interval

gp82.plot_mean
plot([0 5], [0 0], '--', 'LineWidth', 2, 'color', 'r')
ylim([-1 1])
set(gca, 'FontSize', 14)
ylabel('Discriminant Score')
title('High Threshold Subject')

subplot(2,1,2); hold on
data_path       = '/Users/mconn24/Box Sync/papers/2019_12_31_paper_safe_optimization/memory_data/ARN082_t.xlsx';
data_table      = readtable(data_path);
X_v             = data_table.voltage_new;
Y_ds            = data_table.DS;
gp82            = gp_object;

gp82.initialize_data(X_v, Y_ds, lower_bound, upper_bound)
gp82.plot_confidence_interval
gp82.plot_mean
plot([0 5], [0 0], '--', 'LineWidth', 2, 'color', 'r')
ylim([-1 1])
set(gca, 'FontSize', 14)
title('Low Threshold Subject')

xlabel('Voltage')
ylabel('Discriminant Score')

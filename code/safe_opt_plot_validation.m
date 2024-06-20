%safe_opt_plot_validation.m

data_path       = 'STV001_v.xlsx';
% data_path       = 'memory_project/data/ARN082_t.xlsx';
data_table      = readtable(data_path);

V = data_table.voltage_new;
DS = data_table.DS;

figure
subplot(2,1,1)
plot(V,DS,'o')
title(sprintf('%s: Validation Trials',data_path(1:6)))
ylabel('DS')
xlim([-.5 3])
ylim([-1 1.05])
subplot(2,1,2)
plot(V,V.*DS,'o')
xlabel('Voltage')
ylabel('DA')
xlim([-1 3])
ylim([-1.25 1.05])



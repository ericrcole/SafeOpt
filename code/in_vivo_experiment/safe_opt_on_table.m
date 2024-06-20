
data_path       = 'STV001_t.xlsx';
% data_path       = 'memory_project/data/ARN082_t.xlsx';
data_table      = readtable(data_path);

safe_samples    = [0 .5 1]';
lower_bound     = 0;
upper_bound     = 7;
input_space     = (lower_bound:.05:upper_bound)';

safe_set        = ones(size(input_space));
safe_set(input_space > max(safe_samples)) = 0;

USE_HYPERPRIOR  = 1;
USE_SAFE_OPT    = 1;
PLOT            = 1;

BETA            = 2.9;
ETA             = 1.8;
alpha           = 1.27;

X_v             = data_table.voltage_new;
Y_ds            = data_table.DS;

nan_idx         = isnan(Y_ds);

X_v             = X_v(~nan_idx);
Y_ds            = Y_ds(~nan_idx);

[v_new, v_opt, area_opt, S, ucb] = safe_opt_update_memory(X_v, Y_ds, BETA, ETA, alpha, ...
    safe_set, 0, input_space, USE_HYPERPRIOR, USE_SAFE_OPT, PLOT);

% (X_v, Y_ds, beta, eta, alpha, safe_set, threshold, input_space, USE_HYPERPRIOR, USE_SAFE, PLOT)
fprintf('New V: %.2f\n',v_new);
fprintf('Estimated optimal V: %.2f\n',v_opt);

suptitle(sprintf('New V: %.2f, Opt V: %.2f',v_new,v_opt));

N_tot = size(data_table,1);
vec_vopt = zeros(N_tot-2,1);
vec_vnew = zeros(N_tot-2,1);

for k = 3:N_tot
    X_v             = data_table.voltage_new(1:k);
    Y_ds            = data_table.DS(1:k);

    [vec_vnew(k-2), vec_vopt(k-2), area_opt, S, ucb, objective_model] = safe_opt_update_memory(X_v, Y_ds, BETA, ETA, alpha, ...
    safe_set, 0, input_space, USE_HYPERPRIOR, USE_SAFE_OPT, PLOT);

end

figure
subplot(2,1,1)
hold on
plot([NaN; NaN; NaN; vec_vopt],'b-x');
plot([0; .5; 1; vec_vnew],'r--o');

xlim([0 N_tot+1])
ylim([0 3])
xlabel('Samples')
ylabel('Voltage')
title(sprintf('Safe-Opt Convergence: %s',data_path(1:6)))

legend({'Opt Voltage','New Voltage'},'Location','Northeast');

subplot(2,1,2)
plot([Y_ds],'b--o')
xlim([0 N_tot+1])
ylim([-1 1.05])
ylabel('DS')


fprintf('Test: %.2f V, Est DS: %.2f\n',vec_vopt(end)+1,objective_model.predict(vec_vopt(end)+1))



















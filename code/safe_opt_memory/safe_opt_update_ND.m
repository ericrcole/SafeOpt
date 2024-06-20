function [x_sample, x_opt_est, y_opt_est, safe_set, safe_ucb, objective_model] = safe_opt_update_ND(X_v, Y_ds, beta, eta, alpha, safe_set, threshold, input_space, USE_HYPERPRIOR, USE_SAFE, PLOT)
  
% Construct DS model
%objective_model = construct_ds_model(X_v, Y_ds, USE_HYPERPRIOR, alpha);
objective_model = gp_object();

objective_model.initialize_data(X_v, Y_ds, zeros(1,size(input_space,2)), 7*ones(1,size(input_space,2)));

% Resample DS model to get area
[ds_mean_est, ~, ~, ds_ci_est]     = objective_model.predict(input_space);

safety_mean                 = ds_mean_est;   % These two DS or DA
safety_uncertainty          = ds_ci_est;     

acquisition_mean            = ds_mean_est;   % This is static
acquisition_uncertainty     = ds_ci_est;     % DS or DA 

da_mean_est                 = ds_mean_est;

if USE_SAFE
    % Calculate uncertainties
    Q_low                	= safety_mean - beta*safety_uncertainty;
    Q_high                  = safety_mean + beta*safety_uncertainty;

    % Update the safe-set
    safe_set                = any([safe_set Q_low > threshold], 2);

end

t                           = size(X_v,1);
safe_input                  = input_space(safe_set,:);
safe_af_mean                = acquisition_mean(safe_set); % af = acquisition function
safe_af_uncertainty         = acquisition_uncertainty(safe_set);

safe_ucb                    = upper_confidence_bound(safe_af_mean, safe_af_uncertainty, eta, t);
[~, x_sample_idx]           = max(safe_ucb);                    
x_sample                    = safe_input(x_sample_idx,:);

[y_opt_est, x_opt_idx]      = max(safe_af_mean);    
x_opt_est                   = safe_input(x_opt_idx,:);

if 0
    subplot(3,1,1); 
    cla
%     objective_model.
    objective_model.plot_mean
    hold on
    objective_model.plot_confidence_interval
    objective_model.plot_data
    xticklabels({})
    ylabel('Discriminant Score (DS)');
    set(gca,'FontSize', 14);
    
    subplot(3,1,2); hold off
    plot(input_space,da_mean_est, 'k-', 'LineWidth', 3)
    hold on
    plot(input_space,da_mean_est + ds_ci_est, 'k:', 'LineWidth', 3)
    plot(input_space,da_mean_est - ds_ci_est, 'k:', 'LineWidth', 3)
    plot(input_space,Q_low, 'k--', 'LineWidth', 3)
    plot(input_space,Q_high, 'k--', 'LineWidth', 3)
    xticklabels({})
    ylabel('Discriminant Area (DA)');

    set(gca,'FontSize', 14);
    subplot(3,1,3)
    plot(safe_input, safe_ucb, 'k-', 'LineWidth', 3)
    xlim([0 4])
    xlabel('Stimulation Amplitude (V)')
    ylabel('Upper Confididence Bound (a.u.)')
    xlim([min(input_space) max(input_space)])
    drawnow
    set(gca,'FontSize', 14);
end
end



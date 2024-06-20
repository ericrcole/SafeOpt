function simulation_results = analyze_configuration_sweep(simulation_data) 
% data_dir    = 'memory_project/data/simulation_data/configuration_sweep/';        
% data_path   = [data_dir '2020_02_03_simulation_data_ucb2'];

% load(data_path)
input_space                     = linspace(0, 7, 100)';

for c1 = 1:size(simulation_data,2)
    ds_model                    = simulation_data(c1).ds_model;
    X_opt                       = simulation_data(c1).X_opt;
    X_sample                    = simulation_data(c1).X_sample;
    
    Y_ds_gt                     = ds_model.predict(input_space);
    Y_da_gt                     = Y_ds_gt .* input_space;
    [Y_max_gt, y_max_gt_idx]   	= max(Y_da_gt);
    
    X_max_gt                    = input_space(y_max_gt_idx);
    
    % Takes the algo estimate of optimum and apply to GT model
    X_opt_r                     = reshape(X_opt, [], 1, 1);
    Y_opt_gt_r                 	= ds_model.predict(X_opt_r) .* X_opt_r;
    Y_opt_gt                    = reshape(Y_opt_gt_r, size(X_opt));
        
    Y_residual                  = Y_opt_gt - Y_max_gt;
    Y_error                     = abs(Y_residual);
    Y_error_end                 = squeeze(Y_error(end,:,:));
    Y_error_norm                = Y_error_end / Y_max_gt;
    
    max_sample                  = squeeze(max(X_sample,[],1));
    overshoot                   = max_sample - X_max_gt;
    overshoot_norm              = (max_sample - X_max_gt)/X_max_gt;
    
    convergence_rate            = convergence_rate_helper(Y_error);
    
    simulation_results(c1).Y_error              = Y_error;
    simulation_results(c1).Y_error_end          = Y_error_end;
    simulation_results(c1).Y_error_norm         = Y_error_norm;
    
    simulation_results(c1).overshoot            = overshoot;
    simulation_results(c1).overshoot_norm       = overshoot_norm;
    simulation_results(c1).convergence_rate     = convergence_rate;
end

end



function convergence_rate = convergence_rate_helper(y_error)

sample_number =  (4:size(y_error, 1))';

for c1 = 1:size(y_error,3)
    y_param                 = squeeze(y_error(4:end,:,c1));
    convergence_rate(:,c1)    = error_convergence_rate(sample_number, y_param);
end

end







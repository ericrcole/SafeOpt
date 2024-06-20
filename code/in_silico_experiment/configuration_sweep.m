clear
rng(1)

n_params        = 100;
beta            = uniform_range(0, 5, n_params);
eta             = uniform_range(0, 5, n_params);
alpha           = uniform_range(1, 5, n_params);
params          = [beta eta alpha];

% params  = [3 1 2];

safe_samples    = [0 .5 1]';
lower_bound     = 0;
upper_bound     = 7;
input_space     = (lower_bound:.05:upper_bound)';

% [ds_lower safety_lower; ds_upper safety_upper];
y_bounds        = [-1 -1; 1 1];
n_samples       = 15;
n_trials        = 30;

USE_HYPERPRIOR  = 1;
USE_SAFE_OPT    = 1;
PLOT            = 1;

threshold       = 0;

load('memory_project/data/modeled_data/ds_models_2020_02_02.mat');

for c1 = 1:size(ds_models,2)
    ds_model = ds_models(c1);
    fprintf('Subject: %d\n', c1)
    
    for c2 = 1:size(params,1)
        fprintf('\tParameter set: %d\n', c2);
    
        BETA            = params(c2,1);
        ETA             = params(c2,2);
        ALPHA           = params(c2,3);
       
        tic 
        [X_opt(:,:,c2), Y_opt(:,:,c2), X_sample(:,:,c2), Y_sample(:,:,c2), Y_safety(:,:,c2)] = safe_opt_loop_memory(ds_model, ds_model,...
            threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);
        toc
    end 
    
    simulation_data(c1).X_opt      = X_opt;
    simulation_data(c1).Y_opt      = Y_opt;
    simulation_data(c1).X_sample   = X_sample;
    simulation_data(c1).Y_sample   = Y_sample;
    simulation_data(c1).Y_safety   = Y_safety;
    simulation_data(c1).ds_model   = ds_model;
    simulation_data(c1).params     = params;
end
%%

% simulation_results = analyze_configuration_sweep(simulation_data)
% plot_configuration_sweep_2
% simulation_data_dir         = 'memory_project/data/simulation_data/configuration_sweep/';
% sim_data_file_name          = sprintf('2020_02_03_simulation_data.mat');
% simulation_data_path        = [simulation_data_dir sim_data_file_name];
% 
% save(simulation_data_path, 'results_data');










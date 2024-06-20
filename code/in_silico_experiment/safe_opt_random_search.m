clc; clear; 
objective_model = construct_ds_model_subject(52, 1);

% alpha           = [.25 .5 1 2 3];
% beta            = [1 2 3 4 5];
% eta             = [.001 .01 .1 1];

alpha           = 1;
beta            = -1;
eta             = .1;

params          = combvec(beta, eta, alpha)';
lower_bound     = 0;
upper_bound     = 4;
safe_seed       = [0 .5 1]';
threshold       = 0;
n_trials        = 50;

USE_HYPERPRIOR  = 1;
USE_SAFE_OPT    = 1;
PLOT            = 0;

for c1 = 1:size(params,1)
    fprintf('Parameter set: %d\n', c1);
    
    [X_opt(c1,:,:), Y_opt(c1,:,:), X_sample(c1,:,:), Y_sample(c1,:,:)] ...
        = safe_opt_loop(objective_model, params(c1, 1), params(c1, 2), ...
        params(c1, 3), PLOT, lower_bound, upper_bound, safe_seed, ...
        threshold, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);

end
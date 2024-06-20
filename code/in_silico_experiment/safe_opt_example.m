clc; clear; 
objective_model = construct_ds_model_subject(56, 1);

alpha           = .5;
beta            = 3;
eta             = .001;

lower_bound     = 0;
upper_bound     = 4;
safe_seed       = [0 .5 1]';
threshold       = 0;
n_trials        = 50;

USE_HYPERPRIOR  = 1;
USE_SAFE_OPT    = 1;
PLOT            = 0;

tic
[X_opt, Y_opt, X_sample, Y_sample] = safe_opt_loop(objective_model, ...
    beta, eta, alpha, PLOT, lower_bound, upper_bound, safe_seed, threshold, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials);
toc

function [X_opt, Y_opt, X_sample, Y_sample, Y_safety] = safe_opt_loop_ND(ds_model, safety_model,...
            threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials)

X_opt = cell(n_trials,1);
Y_opt = cell(n_trials,1);
X_sample = cell(n_trials,1);
Y_sample = cell(n_trials,1);
Y_safety = cell(n_trials,1);
        
for c1 = 1:n_trials
    fprintf('Starting trial %d\n', c1)
    tic
    [X_opt{c1}, Y_opt{c1}, X_sample{c1}, Y_sample{c1}, Y_safety{c1}] = safe_opt_on_model_ND(ds_model, safety_model,...
                threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT);
    toc
end

% X_opt = cell2mat(X_opt);
% Y_opt = cell2mat(Y_opt);
% X_sample = cell2mat(X_sample);
% Y_sample = cell2mat(Y_sample);
% Y_safety = cell2mat(Y_safety);

end


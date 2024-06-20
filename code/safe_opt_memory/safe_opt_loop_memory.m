function [X_opt, Y_opt, X_sample, Y_sample, Y_safety] = safe_opt_loop_memory(ds_model, safety_model,...
            threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT, n_trials)

        
for c1 = 1:n_trials
    [X_opt(:,c1), Y_opt(:,c1), X_sample(:,c1), Y_sample(:,c1), Y_safety(:,c1)] = safe_opt_on_model_memory(ds_model, safety_model,...
                threshold, BETA, ETA, ALPHA, PLOT, input_space, y_bounds, safe_samples, n_samples, USE_HYPERPRIOR, USE_SAFE_OPT);
end
end

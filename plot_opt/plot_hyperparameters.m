function plot_hyperparameters 
close all; clc
PLOT                    = 1;
E_RATE                  = 0;

simulation_data_dir     = 'memory_project/data/simulation_data/configuration_sweep/';
subject_idx             = [52 55 56];

for c1 = 1:size(subject_idx,2)
    
    % Load simulation data 
    subject_file_name 	= sprintf('ARN0%d_simulation_data.mat', subject_idx(c1));
    data_path           = [simulation_data_dir subject_file_name];
    load(data_path);

    % Create model to get ground truth optimum (should save at simulation
    % to ensure nothing changes
    ds_model                            = model_fit_hippocampal_admes(subject_idx(c1));
    x_v                                 = linspace(ds_model.lower_bound, ds_model.upper_bound,100)';
    y_ds                                = ds_model.predict(x_v);
    y_area                              = x_v .* y_ds;

    [gt_area_optimal, y_area_max_idx]   = max(y_area);
    gt_v_optimal                        = x_v(y_area_max_idx);
    
    % Get mean of each parameter set
    est_v_optimal_end                   = squeeze(estimated_v_optimal(:,end,:));
    est_v_optimal_mean                  = mean(est_v_optimal_end,2);

    % Set up parameter space (again, should be saved at experiment time)
    beta                = linspace(0, 3, 20);
    eta                 = linspace(0, 2, 20); 
    params              = combvec(beta, eta)';
    
    % Calculate error for each param
    
    v_error             = abs(est_v_optimal_mean - gt_v_optimal);

    % Caclulate convergence rate for each param   
    if E_RATE
        sample_number       = (1:size(sample_v,2))';
        for c2 = 1:size(params,1)
            for c3 = 1:size(estimated_area_optimal,3)
                e_rate(c2,c3)              = error_convergence_rate(sample_number, squeeze(estimated_area_optimal(c2,:,c3))', gt_area_optimal);
            end
            fprintf('%d\n', c2);
        end
        save(sprintf('memory_project/results/parameter_sweep/ARN0%d_convergence_rate.mat', subject_idx(c1)), 'e_rate')
    else
        load(sprintf('memory_project/results/parameter_sweep/ARN0%d_convergence_rate.mat', subject_idx(c1)), 'e_rate')
    end
    
    % Calculate lowest error based on three methods
    [~, y_r_idx]        = min(v_error);
    x_r(c1,:)           = params(y_r_idx, :);

    % Calculate max sample for each param
    [~, min_idx] = min(abs(y_area(2:end)));
    x_v(min_idx+1)
    max_sample          = max(max(sample_v,[],2),[],3) ;
%     max_sample          = max(max(sample_v,[],2),[],3) - gt_v_optimal ;
%     max_sample          = max(max(sample_v,[],2),[],3) - x_v(min_idx+1);
    
    if PLOT
        figure;
        
        subplot(2,3,1)    
%         subplot(2,1,1)    
        hold on
        ds_model.plot_standard_deviation
        ds_model.plot_mean
        ylabel('DS')
        set(gca, 'FontSize', 16);
        
        subplot(2,3,4)
%         subplot(2,1,2)
        hold on
        area_model = gp_object();
        area_model.initialize_data(ds_model.x_data, ds_model.y_data .* ds_model.x_data);
%         area_model.minimize(10)
        area_model.plot_confidence_interval();
        area_model.plot_mean
        ylabel('Area')
        xlabel('Voltage')
        set(gca, 'FontSize', 16);
        ylim([-1 1.5])
        
        x_plot          = reshape(params(:,1), 20, 20);
        y_plot          = reshape(params(:,2), 20, 20);
        z_plot          = reshape(v_error, 20, 20);
        
        subplot(2,3,2)

        performance_model         = gp_object();
        performance_model.initialize_data(params, v_error);
        performance_model.minimize(10);
        performance_model.plot_mean
        view(0,90)
        
        zlabel('Distance from Optimum');
        title('Distance from Optimum');
        performance_model.plot_mean
%         xlabel('Beta')
%         ylabel('Eta')
% zlim([-2.5 2.5])
%         caxis([-2.5 2.5])
        set(gca, 'FontSize', 16);
            
        [~, ~, x_h(c1,:), y_h]    = performance_model.discrete_extrema(2);

        
        subplot(2,3,3)
        
        performance_model         = gp_object();
        performance_model.initialize_data(params, mean(e_rate,2));
        performance_model.minimize(10);
        performance_model.plot_mean
        view(0,90)
        
        zlabel('Convergence Rate');
        title('Convergence Rate');
        performance_model.plot_mean
%         xlabel('Beta')
%         ylabel('Eta')
        set(gca, 'FontSize', 16);
        
        
        subplot(2,3,5)
        
        performance_model         = gp_object();
        performance_model.initialize_data(params, max_sample);
        performance_model.minimize(10);
        performance_model.plot_mean
        view(0,90)
        
        zlabel('Max V Sampled');
        title('Max V Sampled');
        performance_model.plot_mean
        xlabel('Beta')
        ylabel('Eta')
        set(gca, 'FontSize', 16);
%         zlim([-2.5 2.5])
%         caxis([-2.5 2.5])

        subplot(2,3,6)
        
        performance_model         = gp_object();
%         performance_model.initialize_data([v_error mean(e_rate,2)],  max_sample);
        performance_model.initialize_data([v_error],  max_sample);
        performance_model.minimize(10);
        performance_model.plot_mean
        xlabel('Distance from Optimum');
%         ylabel('Convergence Rate');
        ylabel('Max V Sampled');
        
        set(gca, 'FontSize', 16);
    end
end

% 
% subplot(2,1,1)
% hold on
% plot(x_r(:,1))
% plot(x_h(:,1))
% plot(x_m(:,1))
% 
% subplot(2,1,2)
% hold on
% plot(x_r(:,2))
% plot(x_h(:,2))
% plot(x_m(:,2))

end
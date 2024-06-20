classdef gpz_model < handle
    %heteroscedastic model fitting via GPz toolbox
    
    properties
        
        mean_function
        hyperparameters
        covariance_function
        liklihood_function
        inference_method
        
        x_data
        y_data
        n_vars
        
        x0
        lower_bound
        upper_bound
        
        normalization_m_y
        normalization_b_y
        normalization_m_x
        normalization_b_x
        
        acquisition_function
        hedge_order
        regret_gain
        
        t1
        t2
        t
        
        
    end
    methods
        %%
        function initialize_data(obj, x_data, y_data, lower, upper)
            obj.normalization_m_y       = max(y_data) - min(y_data);
            obj.normalization_b_y       = min(y_data);
            
            obj.normalization_m_x       = max(x_data) - min(x_data);
            obj.normalization_b_x       = min(x_data);
            
            if nargin == 5
                obj.lower_bound             = lower;
                obj.upper_bound             = upper;
            end
            
            obj.x_data                  = x_data;
            obj.y_data                  = y_data;
            
            obj.covariance_function     = {@covSEard};
            obj.liklihood_function      = @likGauss;
            obj.inference_method        = @infExact;
            
            length_scale                = std(x_data)';
            standard_deviation          = std(y_data)/sqrt(2);
            sn                          = std(y_data)/sqrt(2);
            
            obj.mean_function           = {@meanConst};
            obj.hyperparameters.mean    = mean(y_data);
            
            obj.hyperparameters.cov     = log([ length_scale; standard_deviation]);
            obj.hyperparameters.lik     = log(sn);
            
            obj.n_vars                  = size(x_data,2);
            obj.x0                      = zeros(1,obj.n_vars);
            
            if nargin == 5
                if obj.n_vars == 1
                    obj.t = linspace(obj.lower_bound(1),obj.upper_bound(1),200)';
                    
                elseif obj.n_vars == 2
                    obj.t1 = linspace(obj.lower_bound(1),obj.upper_bound(1),100);
                    obj.t2 = linspace(obj.lower_bound(2),obj.upper_bound(2),100);
                    obj.t  = combvec(obj.t1,obj.t2)';
                    obj.t1 = reshape(obj.t(:,1), 100, 100)';
                    obj.t2 = reshape(obj.t(:,2), 100, 100)';
                end
            end
        end
        
        
        
        
        function minimize(obj, n_evals)
            
            if nargin == 1
                n_evals = 1000;
            end
            
            obj.hyperparameters = minimize(obj.hyperparameters, @gp, n_evals, ...
                obj.inference_method, obj.mean_function, obj.covariance_function, ...
                obj.liklihood_function, obj.x_data, obj.y_data);
            
        end
        
        
        
        function [y_prediction, y_standard_deviation, fmu, fs2 ] = predict(obj, t)
            
            [y_prediction, y_variance, fmu, fs2 ] =            ...
                gp(obj.hyperparameters,             ...
                obj.inference_method,               ...
                obj.mean_function,                  ...
                obj.covariance_function,            ...
                obj.liklihood_function,             ...
                obj.x_data, obj.y_data, t);
            
            y_standard_deviation = y_variance.^0.5;
            fs2 = fs2.^0.5;
        end
        
        
        
        
        function plot_mean(obj, color_val)
            
            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                [yp, ys]    = obj.predict(obj.t);
                yp          = reshape(yp, 100, 100)';
                
                surf(obj.t1, obj.t2, yp, 'linestyle', 'none', 'FaceAlpha', .4);
                hold on;
                
                plot3(obj.x_data(:,1), obj.x_data(:,2), obj.y_data, 'k.', 'MarkerSize', 16)
            elseif obj.n_vars == 1
                yp = obj.predict(obj.t);
                plot(obj.t, yp, 'color', color_val, 'LineWidth', 2);
                %                 plot(obj.x_data, obj.y_data, 'b.', 'MarkerSize', 16)
                
            end
        end
        
        
        
        function plot_confidence_interval(obj, color_val)
            
            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                [yp, ys, fmu, fs]    = obj.predict(obj.t);
                yp         = reshape(yp, 100, 100)';
                fs         = 2*reshape(fs, 100, 100)';
                
                surf(obj.t1, obj.t2, yp+fs, 'linestyle', 'none','FaceAlpha', .7);
                hold on;
                surf(obj.t1, obj.t2, yp-fs, 'linestyle', 'none','FaceAlpha', .7);
                hold off;
                
            elseif obj.n_vars == 1
                
                [yp, ys, fmu, fs]    = obj.predict(obj.t);
                tt = [obj.t; flip(obj.t)];
                yy = [yp-fs; flip(yp+fs)];
                patch(tt,yy, color_val, 'EdgeColor', color_val, 'FaceAlpha', .2, 'Linewidth', 2)
            end
        end
        
        
        function plot_standard_deviation(obj, color_val)
            
            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                [yp, ys]    = obj.predict(obj.t);
                yp         = reshape(yp, 100, 100)';
                ys         = reshape(ys, 100, 100)';
                
                surf(obj.t1, obj.t2, yp+ys, 'linestyle', 'none');
                hold on;
                surf(obj.t1, obj.t2, yp-ys, 'linestyle', 'none');
                hold off;
                
            elseif obj.n_vars == 1
                [yp, ys, fmu, fs]    = obj.predict(obj.t);
                tt = [obj.t; flip(obj.t)];
                yy = [yp-ys; flip(yp+ys)];
                patch(tt,yy, color_val, 'EdgeColor', color_val, 'FaceAlpha', .2, 'Linewidth', 2)
                
            end
        end
        
        
        function plot_confidence_magnitude(obj)
            
            [~, ~, ~, fs]   = obj.predict(obj.t);
            fs              = 2*reshape(fs, 100, 100)';
            
            surf(obj.t1, obj.t2, fs, 'linestyle', 'none');
            
        end
        
        
        function plot_expected_improvement(obj)
            
            [~, f_max]  = obj.discrete_extrema(2);
            ei          = obj.expected_improvement(obj.t, obj, f_max);
            ei          = reshape(ei, 100, 100)';
            
            surf(obj.t1, obj.t2, ei, 'linestyle', 'none');
            
        end
    end
end

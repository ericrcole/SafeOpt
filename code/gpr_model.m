classdef gpr_model < handle
    %GP_MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
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
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function initialize_default(obj, n_vars)
            obj.mean_function           = []; %{@meanConst};
            obj.covariance_function     = {@covMaternARD};
            obj.liklihood_function      = @likGauss;
            obj.inference_method        = @infExact;

            
            length_scale                = 1;
            standard_deviation          = .1;
            sn                          = 10;
            
            obj.hyperparameters.mean    = []; %.1;
            obj.hyperparameters.cov     = log([ length_scale*ones(n_vars,1); standard_deviation]);
            obj.hyperparameters.cov     = log([ 1 ;133; standard_deviation]);
            obj.hyperparameters.lik     = log(sn);

            obj.n_vars                  = n_vars;
            obj.x0                      = zeros(1,n_vars);
            
            obj.t1 = linspace(obj.lower_bound(1),obj.upper_bound(1),100);
            obj.t2 = linspace(obj.lower_bound(2),obj.upper_bound(2),100);
            obj.t  = combvec(obj.t1,obj.t2)';
            obj.t1 = reshape(obj.t(:,1), 100, 100)';
            obj.t2 = reshape(obj.t(:,2), 100, 100)';
            
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function initialize_data(obj, x_data, y_data, lower, upper)
            
            
            obj.normalization_m_y       = max(y_data) - min(y_data);
            obj.normalization_b_y       = min(y_data);
            
            obj.normalization_m_x       = max(x_data) - min(x_data);
            obj.normalization_b_x       = min(x_data);
            
            if nargin == 3
                lower = min(x_data);
                upper = max(x_data);
            end
            
            obj.lower_bound             = lower;
            obj.upper_bound             = upper;
                       
            obj.x_data                  = x_data;
            obj.y_data                  = y_data;
            
            obj.covariance_function     = {@covMaternard, 3};
            obj.liklihood_function      = @likGauss;
            obj.inference_method        = @infExact;
            
            length_scale                = std(x_data)';
            standard_deviation          = std(y_data)/sqrt(2);
            sn                          = std(y_data)/sqrt(2);
            
            obj.mean_function           = {@meanConst};
            obj.hyperparameters.mean    = mean(y_data);
         
            obj.hyperparameters.cov     = log([length_scale; standard_deviation]);
            obj.hyperparameters.lik     = log(sn);

            obj.n_vars                  = size(x_data,2);
            obj.x0                      = zeros(1,obj.n_vars);
            
            if nargin >= 3
                if obj.n_vars == 1
                    obj.t = linspace(obj.lower_bound(1),obj.upper_bound(1),200)';
                    
                elseif obj.n_vars == 2 
                    obj.t1 = linspace(obj.lower_bound(1),obj.upper_bound(1),100);
                    obj.t2 = linspace(obj.lower_bound(2),obj.upper_bound(2),50);
                    
                    obj.t  = combvec(obj.t1,obj.t2)';
                    obj.t1 = reshape(obj.t(:,1), 100, 50);
                    obj.t2 = reshape(obj.t(:,2), 100, 50);
                end
            end
        end
        
        function construct_t_space(obj, t1, t2)
            t_vec  = combvec(t1,t2)';
            obj.t  = t_vec;
            
            obj.t1 = reshape(t_vec(:,1), size(t1, 2), size(t2, 2));
            obj.t2 = reshape(t_vec(:,2), size(t1, 2), size(t2, 2));
            
        end
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function n_data = normalize_data(obj,data)
            
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function d_data = denormalize_data(obj,data)
            
        end
        
        %%%%%%%%%%%%%%%
        %
        % Predict(t)
        %
        %%%%%%%%%%%%%%%
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

        
        function dy = sample(obj,x)
            [y, s]              = obj.predict(x);            
            dy                  = normrnd(y,s);
        end
        
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function h = plot_mean(obj, color_val)

            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                yp          = obj.predict(obj.t);
                yp          = reshape(yp, size(obj.t1,1), size(obj.t1,2));
                
                h = surf(obj.t1, obj.t2, yp, 'linestyle', 'none', 'FaceAlpha', .9);
                hold on;

            elseif obj.n_vars == 1
                yp = obj.predict(obj.t);   
                h = plot(obj.t, yp, 'color', color_val, 'LineWidth', 2); 
               
            end
        end
        
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function plot_data(obj)

            if obj.n_vars == 2
                plot3(obj.x_data(:,1), obj.x_data(:,2), obj.y_data, 'k.', 'MarkerSize', 16)
            
            elseif obj.n_vars == 1         
                plot(obj.x_data, obj.y_data, 'b.', 'MarkerSize', 16)
            
            end
        end
        
        
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function plot_confidence_interval(obj, color_val)
            
            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                [yp, ~, ~, fs]    = obj.predict(obj.t);
                yp         = reshape(yp, size(obj.t1,1), size(obj.t1,2));
                fs         = 2*reshape(fs, size(obj.t1,1), size(obj.t1,2));

                surf(obj.t1, obj.t2, yp+fs, 'linestyle', 'none','FaceAlpha', .7);
                hold on;
                surf(obj.t1, obj.t2, yp-fs, 'linestyle', 'none','FaceAlpha', .7);
                hold off;          
                
            elseif obj.n_vars == 1
                
                [yp, ~, ~, fs]    = obj.predict(obj.t);
                tt = [obj.t; flip(obj.t)];
                yy = [yp-fs; flip(yp+fs)];
                patch(tt,yy, color_val, 'EdgeColor', color_val, 'FaceAlpha', .2, 'Linewidth', 2)
            end
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function plot_standard_deviation(obj, color_val)
            
            if nargin == 1
                color_val = .5*ones(1,3);
            end
            
            if obj.n_vars == 2
                [yp, ys]    = obj.predict(obj.t);
                yp         = reshape(yp, 100, 100);
                ys         = reshape(ys, 100, 100);

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
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function plot_confidence_magnitude(obj)

            [~, ~, ~, fs]    = obj.predict(obj.t);
            fs              = 2*reshape(fs, 100, 100)';
            
            surf(obj.t1, obj.t2, fs, 'linestyle', 'none');        
            
        end
        
         %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function plot_expected_improvement(obj)
            
            [~, f_max]  = obj.discrete_extrema(2);
            ei          = obj.expected_improvement(obj.t, obj, f_max);
            ei          = reshape(ei, 100, 100)';

            surf(obj.t1, obj.t2, ei, 'linestyle', 'none');
            
        end
                
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function x = ga_acquisition_function(obj, param)
            
            n_vars          = obj.n_vars;
            lower_bound     = obj.lower_bound;
            upper_bound     = obj.upper_bound;

    %             f_max           = obj.predict(obj.find_max);

             switch obj.acquisition_function
                case 'PI'
                    fun = @(p) obj.predicted_improvement(p, obj, f_max, param);

                case 'EI'
                    fun = @(p) obj.expected_improvement(p, obj, f_max, param);

                case 'UCB'
                    fun = @(p) -1* obj.upper_confidence_bound(p, obj, param);

             end

            options  	= optimoptions('ga');
            options  	= optimoptions('ga','PlotFcn', @gaplotbestf);
%             options.PopulationSize = 50;
            options.MaxGenerations = 50;
            options.Display = 'none';
            options.UseParallel = true;
            x           = ga(fun,n_vars,[],[],[],[],lower_bound,upper_bound,[],options);
            
        end

        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function x_min = discrete_aquisition_function(obj, param, sample_points)
            
            dimension = size(obj.lower_bound,2);
            
            if exist('sample_points', 'var')
                
                xx = sample_points;
                [~, f_max]          = obj.discrete_extrema(xx);
            else
                
                for c1 = 1:dimension
                   tt(c1,:) = linspace(obj.lower_bound(c1), obj.upper_bound(c1), 10^order); 
                end

                xx = tt(1,:);
                for c1 = 2:dimension
                    xx = combvec(xx, tt(c1,:));
                end

                [~, f_max]          = obj.discrete_extrema(2);
                xx                  = xx';
            end
            
            
            switch obj.acquisition_function
                case 'PI'
                    yy = obj.predicted_improvement(xx, obj, f_max, param);
                    [~, y_min_idx]      = min(yy);
                    
                case 'EI'
                    yy                  = obj.expected_improvement(xx, obj, f_max, param);
                    [~, y_min_idx]      = min(yy);
                    
                case 'UCB'
                    yy                  = obj.upper_confidence_bound(xx, obj, param);
                    [~, y_min_idx]      = min(yy);
                    
                case 'hedge'
                    eta = 1;
                    
                    % Update regret
                    candidate_idx = obj.hedge(xx, obj, f_max);
                    
                    obj.regret_gain = obj.regret_gain + obj.predict(xx(candidate_idx,:));
                    p = exp(eta * obj.regret_gain) / sum(exp(eta * obj.regret_gain));
                    
                    r = find(rand <= cumsum(p), 1);
                    y_min_idx = candidate_idx(r);
%                     yy = obj.hedge(xx, obj, f_max);
            end
            
            x_min               = xx(y_min_idx,:);
            
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function x = ga_find_max(obj)
            
            n_vars          = obj.n_vars;
            lower_bound     = obj.lower_bound;
            upper_bound     = obj.upper_bound;

            fun = @(p) -1*obj.predict(p);

            options                 = optimoptions('ga');
%             options  	= optimoptions('ga','PlotFcn', @gaplotbestf);
%             options.PopulationSize  = 50;
            options.MaxGenerations  = 25;
            options.Display         = 'none';
        	options.UseParallel = true;

            x           = ga(fun,n_vars,[],[],[],[],lower_bound,upper_bound,[],options);
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function [x, y] = find_min(obj)
            
            lb      = obj.lower_bound;
            ub      = obj.upper_bound;
            
            options.TolFun = 1e-2;
            
            x = simulannealbnd(@(p) obj.predict(p),obj.x0,double(lb),double(ub),options);
            y = obj.predict(x);
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function outliers_removed = remove_outliers(obj)
            
            [m, ~, ~, fs] = obj.predict(obj.x_data);
            ci                          = m + 2*sqrt(fs);
            outlier_idx                 = find(abs(obj.y_data) > ci);
            obj.x_data(outlier_idx,:)   = [];
            obj.y_data(outlier_idx,:)   = [];
            
            obj.initialize_data(obj.x_data, obj.y_data, [1 1], [120 4] );
            
            outliers_removed            = ~isempty(outlier_idx);
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function [x_max, y_max, x_min, y_min] = discrete_extrema(obj, xx)
            
%             xx                  = obj.get_discrete_grid(order);
            yy                  = obj.predict(xx);
            
            [y_max, y_max_idx]  = max(yy);
            x_max               = xx(y_max_idx,:);
            
            [y_min, y_min_idx]  = min(yy);
            x_min               = xx(y_min_idx,:);
        end
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function xx = get_discrete_grid(obj, order)
            dimension = size(obj.lower_bound,2);
            
            for c1 = 1:dimension
               tt(c1,:) = linspace(obj.lower_bound(c1), obj.upper_bound(c1), 10^order); 
            end
            
            cc = tt(1,:);
            for c1 = 2:dimension
                cc = combvec(cc, tt(c1,:));
            end
            
            xx                  = cc';
        end
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function minimize(obj, n_evals)
            
            if nargin == 1
                n_evals = 1000;
            end            
            
            obj.hyperparameters = minimize(obj.hyperparameters, @gp, n_evals, ...
                obj.inference_method, obj.mean_function, obj.covariance_function, ...
                obj.liklihood_function, obj.x_data, obj.y_data);

        end
        
    end
    
    methods(Static)
        
        %%%%%%%%%%%%%%%
        %
        % 
        %
        %%%%%%%%%%%%%%%
        function pi = predicted_improvement(P, gp_object, f_max, ksi)
            [ypred, ~, ~, fs] = gp_object.predict(P);
            
            ksi         = ksi  * std(gp_object.y_data);
            z           = (ypred - f_max - ksi)./fs;
            
            pi          = normcdf(z);
            
            pi          = -1*pi;
            pi(pi == 0) = 100;
           
        end
        
        %%%%%%%%%%%%%%%
        %
        % 
        %
        %%%%%%%%%%%%%%%
        function ei = expected_improvement(P, gp_object, f_max, ksi)
            [ypred, ~, ~, fs] = gp_object.predict(P);
            
            ksi         = ksi  * std(gp_object.y_data);
            z           = (ypred - f_max - ksi)./fs;
            
            ei          = (ypred - f_max - ksi).*normcdf(z) + fs.*normpdf(z);
            
            ei          = -1*ei;
            ei(ei == 0) = 100;
           
        end
        
        %%%%%%%%%%%%%%%
        %
        % 
        %
        %%%%%%%%%%%%%%%
        function ucb = upper_confidence_bound(P, gp_object, nu)
            [y_pred, ~, ~, fs] = gp_object.predict(P);
            
            t = size(gp_object.x_data,1);
%             t = 100
            beta = 2 * log(t.^2*pi^2/(6));
            
            ucb = y_pred + sqrt(nu*beta) * fs;
        end
        
        %%%%%%%%%%%%%%%
        %
        % 
        %
        %%%%%%%%%%%%%%%
        function candidate_idx = hedge(P, gp_object, f_max)
            
            if gp_object.hedge_order == 3
                
                pi  = gp_object.predicted_improvement(P, gp_object, f_max, .01);
                ei  = gp_object.expected_improvement(P, gp_object, f_max, .01);
                ucb = gp_object.upper_confidence_bound(P, gp_object, f_max, .2);
                
                [~, candidate_idx] = min([pi ei ucb]);
                
            elseif gp_object.hedge_order == 9
                
                pi_1  = gp_object.predicted_improvement(P, gp_object, f_max, .01);
                pi_2  = gp_object.predicted_improvement(P, gp_object, f_max, .1);
                pi_3  = gp_object.predicted_improvement(P, gp_object, f_max, 1);

                ei_1  = gp_object.expected_improvement(P, gp_object, f_max, .01);
                ei_2  = gp_object.expected_improvement(P, gp_object, f_max, .1);
                ei_3  = gp_object.expected_improvement(P, gp_object, f_max, 1);

                ucb_1 = gp_object.upper_confidence_bound(P, gp_object, .1);
                ucb_2 = gp_object.upper_confidence_bound(P, gp_object, .2);
                ucb_3 = gp_object.upper_confidence_bound(P, gp_object, 1);
                            
                [~, candidate_idx] = min([pi_1 pi_2 pi_3 ei_1 ei_2 ei_3 ucb_1 ucb_2 ucb_3]);

            end
        end
    end
end

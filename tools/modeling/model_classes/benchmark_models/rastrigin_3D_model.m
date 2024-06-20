classdef rastrigin_3D_model < handle
    %GP_MODEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        noise_sigma
        lower_bound
        upper_bound
    end
    
    methods
        
        
        %%%%%%%%%%%%%%%
        %
        % Constructor
        %
        %%%%%%%%%%%%%%%
        function obj = rastrigin_3D_model()
         
        end
        
        
        %%%%%%%%%%%%%%%
        %
        % predict(t)
        %
        %%%%%%%%%%%%%%%
        function [y_prediction, noise_sigma] = predict(obj, t)
            
            t1              = t(:,1);
            t2              = t(:,2);
            t3              = t(:,3);
            
            e1              = 10 + t1.^2 - 10 * cos(2*pi*t1);
            e2              = 10 + t2.^2 - 10 * cos(2*pi*t2);
            e3              = 10 + t3.^2 - 10 * cos(2*pi*t3);
            
            y_prediction    = -1*(e1 + e2 + e3);

            noise_sigma     = obj.noise_sigma;
            
        end
        
        
        %%%%%%%%%%%%%%%
        %
        % sample(t)
        %
        %%%%%%%%%%%%%%%
        function y_sample = sample(obj,t)
            [yp, ns]        = obj.predict(t);
            y_sample        = normrnd(yp, ns);
        
        end
        
        
        %%%%%%%%%%%%%%%
        %
        %
        %
        %%%%%%%%%%%%%%%
        function [x_max, y_max, x_min, y_min] = discrete_extrema(obj, input_space)
            
            Y_expectation       = obj.predict(input_space);
            
            [y_max, y_max_idx]  = max(Y_expectation);
            x_max               = input_space(y_max_idx,:);
            
            [y_min, y_min_idx]  = min(Y_expectation);
            x_min               = input_space(y_min_idx,:);
        end
        
    end
    

end 
classdef sphere_3D_model < handle
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
        function obj = sphere_3D_model()
            obj.lower_bound = 0;
            obj.upper_bound = 1;
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
            
            y_prediction    = -1*(t1.^2 + t2.^2 + t3.^2);
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
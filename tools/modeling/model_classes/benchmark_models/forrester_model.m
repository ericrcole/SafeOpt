classdef forrester_model < handle
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
        % Predict(t)
        %
        %%%%%%%%%%%%%%%
        function obj = forrester_model()
            obj.lower_bound = 0;
            obj.upper_bound = 1;
        end
        
       
        function [y_prediction, noise_sigma] = predict(obj, t)
            fact1           = (6.*t - 2).^2;
            fact2           = sin(12.*t - 4);

            y_prediction    = fact1 .* fact2 * -1;

            if isempty(obj.noise_sigma)
                noise_sigma = 0;
            else
                noise_sigma	= obj.noise_sigma;
            end
        end
        
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
    
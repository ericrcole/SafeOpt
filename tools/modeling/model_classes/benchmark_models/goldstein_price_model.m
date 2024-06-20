classdef goldstein_price_model < handle
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
        function obj = goldstein_price_model()
            obj.lower_bound = 0;
            obj.upper_bound = 1;
        end
        

        
       
        
        function [y_prediction, noise_sigma] = predict(obj, t)
            
            
            t1 = t(:,1);
            t2 = t(:,2);
            fact1a = (t1 + t2 + 1).^2;
            fact1b = 19 - 14.*t1 + 3.*t1.^2 - 14.*t2 + 6.*t1.*t2 + 3.*t2.^2;
            fact1 = 1 + fact1a.*fact1b;
            
            fact2a = (2.*t1 - 3.*t2).^2;
            fact2b = 18 - 32.*t1 + 12.*t1.^2 + 48.*t2 - 36.*t1.*t2 + 27.*t2.^2;
            fact2 = 30 + fact2a.*fact2b;
            
            y_prediction = fact1.*fact2;
            noise_sigma  = obj.noise_sigma;
            
        end
        
        function y_sample = sample(obj,t)
            [yp, ns]        = obj.predict(t);
            y_sample        = normrnd(yp, ns);
        end
        
        plot(y_prediction,t);
        
        
        
    end
    
end


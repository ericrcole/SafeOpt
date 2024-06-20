classdef hartmann_model < handle
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
        function obj = hartmann_model()
            obj.lower_bound = 0;
            obj.upper_bound = 1;
        end
        
        
        
        function [y_prediction, noise_sigma] = predict(obj, t)
            
            t1 = t(:,1);
            t2 = t(:,2);
            t3 = t(:,3);
            
            alpha = [1.0, 1.2, 3.0, 3.2]';
            A = [3.0, 10, 30;
                0.1, 10, 35;
                3.0, 10, 30;
                0.1, 10, 35];
            P = 10^(-4) * [3689, 1170, 2673;
                4699, 4387, 7470;
                1091, 8732, 5547;
                381, 5743, 8828];
            
            outer = 0;
            for ii = 1:4
                inner = 0;
                for jj = 1:3
                    xj = t(:,jj);
                    Aij = A(ii, jj);
                    Pij = P(ii, jj);
                    inner = inner + Aij.*(xj-Pij).^2;
                end
                new = alpha(ii) .* exp(-inner);
                outer = outer + new;
            end
            
            y_prediction = -outer;
            noise_sigma = obj.noise_sigma;
            
        end
        function y_sample = sample(obj,t)
            [yp, ns]        = obj.predict(t);
            y_sample        = normrnd(yp, ns);
            
            
            
        end
    end
    

end 
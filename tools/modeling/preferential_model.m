classdef preferential_model < handle
    %PREFERENTIAL_MDOEL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        % A Gaussian process model for the unknown function g(x)
        g_model 
    end
    
    methods
        function obj = preferential_model(x_data,y_data)
            g_model = gpr_model();
            g_model.initialize_data(x_data, y_data)
            
            obj.g_model = g_model();
        end
        
        function y_binary = predict(obj,x1, x2)
            y1          = obj.g_model.predict(x1);
            y2          = obj.g_model.predict(x2);
            
            y_binary    = binary_outcome(obj, y1, y2);
            
        end
        
        function y_binary = sample(obj,x1, x2)
            y1          = obj.g_model.sample(x1);
            y2          = obj.g_model.sample(x2);
            
            y_binary    = binary_outcome(obj, y1, y2);
            
        end
        
        function y_binary = binary_outcome(obj, y1, y2)
            
            for c1 = 1:size(y1,1)
                if y1(c1) > y2(c1)
                    y_binary(c1,1) = 1;
                elseif y1(c1) < y2(c1)
                    y_binary(c1,1) = -1;
                else
                    y_binary(c1,1) = 0;
                end
            end
        end
        
        function plot_mean(obj)
            obj.g_model.plot_mean();
        end
        
        function plot_standard_deviation(obj)
            obj.g_model.plot_standard_deviation();
        end
    end
end


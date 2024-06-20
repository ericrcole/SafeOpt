classdef simulation_gp < handle
    %SIMULATION_GP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        gp_model
        current_state
        
        min_state
        max_state
        
        lower_bound
        upper_bound
        
        state_list
        state_idx       
        state_mode
    end
    
    methods
        
        %
        %
        %        
        function initialize_data(obj, x0_data, u1_data, x1_data, lower_bound, upper_bound)
            
            input_data      = [x0_data u1_data];
            obj.gp_model    = gp_object;
            
            obj.gp_model.initialize_data(input_data, x1_data, min(input_data), max(input_data))
            
            obj.min_state   = min([x0_data; x1_data]);
            obj.max_state   = max([x0_data; x1_data]);
            
            if nargin == 3
                lower_bound = min(u1_data);
                upper_bound = max(u1_data);
            end
            
            obj.lower_bound = lower_bound;
            obj.upper_bound = upper_bound;
            
            obj.state_mode  = 'dynamic';
        end
        
        %
        %
        %
        function initialize_data_nonstationary(obj, ...
                x0_data, u1_data, x1_data, lower_bound, upper_bound, state_list)
            
            obj.initialize_data(x0_data, u1_data, x1_data, lower_bound, upper_bound)
            obj.state_mode      = 'nonstationary';
            obj.state_list      = state_list;
            obj.state_idx       = 2;
            
            obj.current_state   = state_list(1);
        end
        
        %
        %
        %
        function initialize(obj, gp_model)
            
            obj.gp_model            = gp_model;           
            obj.set_initial_state();

            obj.lower_bound         = min(gp_model.x_data(:,2:end));
            obj.upper_bound         = max(gp_model.x_data(:,2:end));
            
            obj.min_state           = min(gp_model.x_data(:,1));
            obj.max_state           = max(gp_model.x_data(:,1));
        end

        %
        %
        %
        function set_initial_state(obj)
            [y_mean, y_std, mu_ci]  = normfit(obj.gp_model.x_data(:,1));            
            obj.current_state       = normrnd(y_mean, y_std/2);
        end
        
        %
        %
        %
        function set_state(obj, new_state)
            new_state           = max(new_state, obj.min_state);
            new_state           = min(new_state, obj.max_state);
            obj.current_state   = new_state;
        end
        
        %
        %
        %
        function stim_state = sample(obj, stim_params)
            
            stim_state               = obj.gp_model.sample([obj.current_state stim_params]);            
            stim_state               = max(stim_state, obj.min_state);
            stim_state               = min(stim_state, obj.max_state);
            
            switch obj.state_mode
                
                case 'dynamic'
                    obj.current_state       = stim_state;
                case 'nonstationary'
                    obj.current_state       = obj.state_list(obj.state_idx);
                    obj.state_idx           = mod(obj.state_idx, size(obj.state_list,2))+1;
            end
        end
        
        
        %
        %
        %       
        function state_est = predict_state(obj, stim_params)
            current_state_arr       = repmat(obj.current_state,size(stim_params,1),1);
           
            delta_state             = obj.gp_model.predict([current_state_arr stim_params]);
            new_state               = obj.current_state + delta_state;
            state_est               = max(new_state, obj.min_state);
        end
        
        %
        %
        %        
        function optimal_stim = state_aquisition(obj, current_state, acquisition_function, param)
            t1 = linspace(obj.lower_bound(1),obj.upper_bound(1),100);
            t2 = linspace(obj.lower_bound(2),obj.upper_bound(2),100);
            t  = combvec(t1,t2)';

            [~, f_max]      = state_extrema(obj, current_state);
            current_state   = repmat(current_state,size(t,1),1);
            
            aq_input        = [current_state t];
            switch acquisition_function
                case 'UCB'
                    y_acquisition   = obj.gp_model.upper_confidence_bound(aq_input,obj.gp_model, param);
                case 'PI'
                    y_acquisition   = obj.gp_model.predicted_improvement(aq_input,obj.gp_model, f_max, param);
                case 'EI'
                    y_acquisition   = obj.gp_model.expected_improvement(aq_input,obj.gp_model, f_max, param);
            end
                      
            [~, max_aq_idx]     = min(y_acquisition);
            optimal_stim        = t(max_aq_idx,:);
        end
        
        %
        %
        %       
        function [max_stim, max_state] = state_extrema(obj, current_state)
            t1 = linspace(obj.lower_bound(1),obj.upper_bound(1),100);
            t2 = linspace(obj.lower_bound(2),obj.upper_bound(2),100);
            t  = combvec(t1,t2)';
            
            current_state           = repmat(current_state,size(t,1),1);

            
            [y_prediction, y_standard_deviation, fmu, fs2] = obj.gp_model.predict([current_state t]);
            
            [max_state, max_yp_idx] = max(y_prediction);
            max_stim                = t(max_yp_idx,:);
        end
    end
    
end


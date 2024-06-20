function [gp_model, x, fval, exitflag, output, population, scores] = fit_gp_model_ga(X, Y)
% FIT_GP_MODEL fits the hyperparameters of Gaussian process (GP) model by using
% a genetic algorithm (GA) to minimize the cross-validation normalizized mean
% squared error
%
% Inputs:
%   X - NxM matrix where each row(n) is an observation and each column (m)
%       is feature input space for the GP model
%   Y - Nx1 output/response values corresponding to the observations in X
%
% Outputs:
%   gp_model - a gp_object object populated with data and hyperparamters
%              set based on the results from the GA


sample_fig_gen;

X                 = X';
Y                 = Y';

nvars   = size(X,2) + 1;

ls      = log(std(X));
sd      = log(std(Y)/sqrt(2));

LB      = [ls*.5 sd*2];
UB      = [ls*2 sd*.5];

opt     = optimoptions('ga', 'PopulationSize', 50,  ...
            'Display','iter',                       ...
            'MaxGenerations',200);

% [x,fval,exitflag,output,population,scores] =            ...
%     ga(@(P) gp_crossval_cost(P, X, Y), nvars,    ...
%     [],[],[],[],LB,UB,[],[],opt);

[x,fval,exitflag,output,population,scores] =            ...
    ga(@(P) gp_crossval_cost(P, X, Y), nvars,opt);


gp_model = gp_object();
gp_model.initialize_data(X, Y, min(X), max(X));
gp_model.hyperparameters.cov = x(1:2)';
gp_model.hyperparameters.cov = x';

end


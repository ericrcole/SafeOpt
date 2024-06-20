function gp_model = construct_hyperprior_model(x, y, hyp, alpha)

if nargin < 4
    alpha = 1;
end

gp_model = gp_object;
gp_model.initialize_data(x, y, 0, 7);
gp_model.covariance_function = {@covSEard};

if nargin >= 3
    p_mean      = {@priorGauss,hyp.mean.mu,hyp.mean.s2 * alpha}; % Gaussian prior
    p_cov1      = {@priorGauss,hyp.cov1.mu,hyp.cov1.s2 * alpha}; % Gaussian prior
    p_cov2      = {@priorGauss,hyp.cov2.mu,hyp.cov2.s2 * alpha}; % Gaussian prior
    p_lik       = {@priorGauss,hyp.lik.mu,hyp.lik.s2 * alpha}; % Gaussian prior

    prior.mean  = {p_mean};
    prior.cov   = {p_cov1; p_cov2};
    prior.lik   = {p_lik};

    inf_method               	= {@infPrior,@infGaussLik,prior};
    gp_model.inference_method  	= inf_method;

end

gp_model.minimize(10);
end
load('memory_project/data/modeled_data/ds_models_2020_02_02.mat');

for c1 = 1:size(ds_models,2)    
        ds_model            = ds_models(c1);
        h_mean(c1)      	= ds_model.hyperparameters.mean;
        h_cov(c1,:)     	= ds_model.hyperparameters.cov;
        h_lik(c1)       	= ds_model.hyperparameters.lik;
end

hyp.mean.mu     = mean(reshape(h_mean,1,[]));
hyp.mean.s2     = var(reshape(h_mean,1,[]));

hyp.cov1.mu     = mean(reshape(h_cov(:,1), [], 1));
hyp.cov1.s2     = var(reshape(h_cov(:,1), [], 1));

hyp.cov2.mu     = mean(reshape(h_cov(:,2), [], 1));
hyp.cov2.s2     = var(reshape(h_cov(:,2), [], 1));

hyp.lik.mu      = mean(reshape(h_lik,1,[]));
hyp.lik.s2      = var(reshape(h_lik,1,[]));

save('memory_project/results/hyperprior/ds_hyp_data_2020_02_02.mat', 'hyp');
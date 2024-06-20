rng(1); % fix random seed

clear; close all; clc
%%%%%%%%%%%%%% Model options %%%%%%%%%%%%%%%%

gamma_path      = 'optogenetic_optimization_project/data/in_silico_data/modeled_data/gamma_3D/R1_gamma_3D.mat';
close all
load(gamma_path)

gamma_1D        = gp_object;
x_idx           = gp_model.x_data(:,1) == 50;

X          = gp_model.x_data(x_idx,2);
Y         = gp_model.y_data(x_idx);

 
m = 10;                                % number of basis functions to use [required]
 
method = 'GC';                          % select a method, options = GL, VL, GD, VD, GC and VC [required]
 
heteroscedastic = true;                 % learn a heteroscedastic noise process, set to false if only interested in point estimates [default=true]
 
normalize = true;                       % pre-process the input by subtracting the means and dividing by the standard deviations [default=true]

maxIter = 500;                          % maximum number of iterations [default=200]
maxAttempts = 50;                       % maximum iterations to attempt if there is no progress on the validation set [default=infinity]
 
 
trainSplit = 0.7;                       % percentage of data to use for training
validSplit = 0.15;                       % percentage of data to use for validation
testSplit  = 0.15;                       % percentage of data to use for testing

inputNoise = true;                      % false = use mag errors as additional inputs, true = use mag errors as additional input noise






    Psi = [];

% model_fit_example_homoscedastic
n = size(X,1);
X = X(:,1);
% split data into training, validation and testing
[training,validation,testing] = sample(n,trainSplit,validSplit,testSplit); 

%%%%%%%%%%%%%% Fit the model %%%%%%%%%%%%%%

% initialize the model
model = init(X,Y,method,m,'normalize',normalize,'heteroscedastic',heteroscedastic,'training',training,'Psi',Psi);

% train the model
model = train(model,X,Y,'maxIter',maxIter,'maxAttempt',maxAttempts,'training',training,'validation',validation,'Psi',Psi);

%%%%%%%%%%%%%% Display %%%%%%%%%%%%%%
%
Xs = linspace(0,45,1000)';

[mu,sigma,nu,beta_i,gamma,PHI,w,iSigma_w] = predict(Xs,model); % generate predictions, note that this will use the model with the best score on the validation set
% [mu,sigma,nu,beta_i,gamma,PHI,w,iSigma_w] = predict(Xs,model,'whichSet','last'); % this will use the model with the best score on the training set

hold on;

% f = [mu+2*sqrt(sigma); flip(mu-2*sqrt(sigma))];
% h1 = fill([Xs; flip(Xs)], f, [0.85 0.85 0.85]);
% 
% f = [mu+2*sqrt(nu); flip(mu-2*sqrt(nu))];
% h1 = fill([Xs; flip(Xs)], f, [0.85 0.85 0.85]);

f = [mu+sqrt(beta_i); flip(mu-sqrt(beta_i))];
h1 = fill([Xs; flip(Xs)], f, [0.85 0.85 0.85]);
plot(Xs, mu)
plot(X,Y,'b.');
box off
xlabel('Frequency')
ylabel('Normalized Gamma Power (a.u.)')
set(gca, 'FontSize', 16)


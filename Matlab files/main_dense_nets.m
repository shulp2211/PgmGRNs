
% Main file for the implementation of dense newtork performance
% Handles both Ecoli SOS response network , and Acid Resistance (AR)
% regulatory network.
% Can be adapted to any GRN given gene expression data.
% Project: " A PGM for system-wide analysis of GRNs"
% by S. Kotiang and A. Eslami

clear all;
clc;
warning off

prompt = 'Type 1 for SOS and 2 for AR -> ';
net =  sscanf(input(prompt, 's'), '%d');
fprintf('\n');

prompt = 'Select the number of clusters (2 or 3) k -> ';
k =  sscanf(input(prompt, 's'), '%d');
fprintf('\n');


% Network structure and Factor Graph
[Ecoli_dag, genes, exp_data] = gnetwork(net); % create the GRN interaction matrix
% full_daG = Ecoli_dag + eye(size(Ecoli_dag)); % full network matrix
[data_len, N] = size(exp_data);

[dEcoli, class_proportions] = discretization(exp_data,k, net); % discretization of the expression data
X = class_proportions(:);
rng ('default')

switch net
    case 1
        add_edges= 5:5:30;
    case 2
        add_edges= 5:5:40;
    otherwise
        error('invalid input'); 
end

len_add = length(add_edges);
corr_r = []; % store the correlations
rand_attempts = 100;
diag_idx = find(eye(size(Ecoli_dag))); % indices of the diagonal elements

for p = 1:len_add   % looping for sparse networks
    
    coeffs = zeros(1,rand_attempts);
    for j = 1:rand_attempts
        
        % Create Dense network
        new_dag = dense_net(Ecoli_dag, add_edges(p), diag_idx);
        
        marginals = prob_fgn_model(dEcoli,new_dag,k); % message update
        
        % Keep track of correlation coefficients
        beliefs = cell2mat(marginals);
        Y = beliefs(:);
        r = corrcoef(X,Y,'alpha',0.01);
        coeffs(j) = r(1,2);
    end
    corr_r = [corr_r; mean(coeffs)];
end

% Correlation box plots

figure(2);
datacursormode on
axis square;
axis([0 1 0 1]);
plot(add_edges, corr_r)
% plot(del_edges, corr_r)
ylabel('Correlation coeff., \rho ')
xlabel('deleted edges')





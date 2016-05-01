function [J,grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

for i = 1:m
    y_label = zeros(num_labels, 1);
    y_label(y(i)) = 1;
    
    % feedforward algorithm
    a1 = X(i, :)';
    a1 = [1; a1];

    z2 = Theta1 * a1;
    a2 = sigmoid(z2);
    a2 = [1; a2];

    z3 = Theta2 * a2;
    a3 = sigmoid(z3);
    
    % add to cost function
    J = J + sum(-y_label .* log(a3) - (1 - y_label) .* log(1 - a3));

    % feedbackward algorithm
    delta3 = a3 - y_label;
    tmp_delta2 = Theta2' * delta3;
    delta2 = tmp_delta2(2:end, :) .* sigmoidGradient(z2);
    
    Theta1_grad = Theta1_grad + (delta2 * a1');
    Theta2_grad = Theta2_grad + (delta3 * a2');
end

J = J / m;
Theta1_grad = Theta1_grad / m;
Theta2_grad = Theta2_grad / m;


% J regulization
reg_theta1 = Theta1(:, 2:end);
reg_theta2 = Theta2(:, 2:end);

J = J + (lambda / (2 * m)) * (sum(sum(reg_theta1 .^ 2)) + ...
    sum(sum(reg_theta2 .^ 2)));

% gradient regulization
Theta1_grad(:, 2:end) = Theta1_grad(:, 2:end) + (lambda / m) ...
           .* Theta1(:, 2:end);
Theta2_grad(:, 2:end) = Theta2_grad(:, 2:end) + (lambda / m) ...
           .* Theta2(:, 2:end);

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
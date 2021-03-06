function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


%%% Part 1

%lets calcualte activation for each layer
%a1 = X
%z2 = theta1*a1
%a2 = sigmoid(z2)  -->add extra column for bias
%z3 = theta2*a2
%a3 = sigmoid(z3) --> since there are only one hidden layer a3 = htheta(x)
%or output

%forward propagation
a1 = [ones(m,1) X];  %dimension 5000x401
z2 = a1 * Theta1';  %dimension 5000 X 25
a2 = sigmoid(z2);
a2 = [ones(size(a2,1),1) a2]; %adding bias unit as all ones, dimension 5000X26
z3 = a2 * Theta2';  %dimension 5000X10
%output
a3 = sigmoid(z3);

h_thetaX = a3;

 
%computing cost function 
%we need number of labels, number of samples, output y vector and h_thetaX
%predicted output

%since our predicted vector's dimension is 5000X10 lets make y vector
%5000X10, where number the output number is indicated by index
%lets create a matrix of size 5000X10 with all zeros and input 1 at the
%index which represents digit number

yVector = zeros(m,num_labels);

%lets find a logic that replaces zeros with 1 on the index number same as
%the number in the y vector
%if we iterate through all the training samples, we can replace our yVector
%zeros values at the position whchi is basically the digit number

%there might be a better way to do this
for i = 1:m
    yVector(i,y(i)) = 1;
end

%now we have everythign we need to compute cost function
%vectorising everything makes it possible to avoid loops for this
%calculation
J = (-1/m) * (sum(sum(yVector .* log(h_thetaX) + (1-yVector).*log(1-h_thetaX))));
%we also need the regularisation term with lambda given in ex4.pdf

reg = lambda/2 * (sum(sum(Theta1.^2)) + sum(sum(Theta2.^2)));
% so final J is

J = J + reg; %if lambda is zero then, regulatisation term is zero

%%%part 2
%gradient computation using backpropagation algorithm

%we go through each training example and calculate update the gradient with
%the aim to minimise the cost function 

%running through 5000 training sets
for i = 1:m
    %input layer
    a1 = [1; X(i,:)']; %gives each row of the training example as a column vector and add 1 bias unit
                        %dimension 401 X 1
    %hidden layer
    z2 = Theta1 * a1; %z2 dimension is 25 x 1
    
    a2 = [1; sigmoid(z2)]; %also adding a bias unit so dimension is 26X1
    
    z3 = Theta2 * a2;
    
    a3 = sigmoid(z3); %no need to add bias as this is output 

    %using this option to change the correspondign index to 1 as per the ouput
    %i.e.if ouput at certain index is 5, we change the output vector with
    %10 elements, 5th index to 1, which means it classifies the ouput to be
    %5. 
    %%%===========================================
    %[1:10] == y(100)

    %ans =

     %0   0   0   0   0   0   0   0   0   1
    %%%========================================
    outputVector = ([1:num_labels] == y(i));
    
    %Now can calculate the errors, small deltas which acculmulates to a big
    %delta
    %prediction - actual value
    %backpropagation goes from last layer to the first
    delta_3 = a3 - outputVector';
    %delta_2 = (Theta2'*delta_3) .* 
    delta_2 = a3 .* (1 - a3);
    
    delta_2 = delta_2(2:end); %gettign rid of the bias unit
    
    %delta 1 is input so it is not associated with errors
    
    %updating big delta which is basically an accumulation of small deltas
    
    
    Theta1_grad = Theta1_grad + delta_2 * a1';
    Theta2_grad = Theta2_grad + delta_3 * a2';    
end

% now that we have big deltas calculated, lets compute gradient

Theta1_grad = (1/m)*(Theta1_grad) + (lambda/m) * [zeros(size(Theta1, 1),1) Theta1(:,2:end)];
Theta2_grad = (1/m)*(Theta2_grad) + (lambda/m) * [zeros(size(Theta2, 1),1) Theta2(:,2:end)];






% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end

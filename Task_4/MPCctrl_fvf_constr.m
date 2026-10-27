function controlAction = MPCctrl_fvf_constr(signal,predictedHorizon,...
                                           predictionData,nInput)

% Controller inputs
reference = signal(1)*ones(predictedHorizon,1); % Reference ln(INR)
currentState = signal(2);                       % Current ln(INR)

%% Previous state and input

persistent previousState previousInput

if isempty(previousState)
    previousState = currentState;
end

if isempty(previousInput)
    previousInput = zeros(nInput,1);
end

%% Augmented state

stateIncrement = currentState - previousState;

augmentedState = [stateIncrement;
                  currentState];

%% Quadratic cost matrices

hessianMatrix = predictionData.inputPrediction' * ...
                predictionData.outputWeight * ...
                predictionData.inputPrediction + ...
                predictionData.inputWeight;

gradientVector = predictionData.inputPrediction' * ...
                 predictionData.outputWeight * ...
                 (predictionData.statePrediction*augmentedState - reference);

%% Constrained optimization

% Full-increment velocity form:
% U_pred = u(k-1) + cumulative_sum(DeltaU), constrained as U_pred >= 0.
cumulativeIncrementMatrix = kron(tril(ones(predictedHorizon)), eye(nInput));
constraintMatrix = -cumulativeIncrementMatrix;
constraintBound = repmat(previousInput(:), predictedHorizon, 1);

options = optimset('Display', 'off', 'Algorithm', 'interior-point-convex');

optimalIncrementSequence = quadprog((hessianMatrix+hessianMatrix')/2, ...
    gradientVector, constraintMatrix, constraintBound, [], [], [], [], [], options);

% Reshape optimal increment sequence
optimalIncrementSequence = reshape(optimalIncrementSequence,...
    nInput,length(optimalIncrementSequence)/nInput);

% Apply only the first input increment
controlIncrement = optimalIncrementSequence(:,1);

% Recover actual constrained control input
controlAction = previousInput + controlIncrement;

%% Update memory

previousState = currentState;
previousInput = controlAction;

end

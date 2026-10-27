function controlAction = MPCcontroller(signal,predictedHorizon,predictionData,nInput)

% Controller inputs
reference = signal(1)*ones(predictedHorizon,1); % Reference ln(INR)
currentState = signal(2);         % Current state

% Quadratic cost matrices
hessianMatrix = predictionData.inputPrediction' * ...
                predictionData.outputWeight * ...
                predictionData.inputPrediction + ...
                predictionData.inputWeight;

gradientVector = predictionData.inputPrediction' * ...
                 predictionData.outputWeight * ...
                 (predictionData.statePrediction*currentState - reference);

options = optimset('Display','off','Algorithm','interior-point-convex');

% Solve the quadratic optimization problem
optimalSequence = quadprog((hessianMatrix + hessianMatrix')/2, ...
    gradientVector, predictionData.constraintMatrix,predictionData.constraintBound, ...
    [],[],[],[],[], options);

% Reshape the optimal control sequence
optimalSequence = reshape(optimalSequence, nInput, length(optimalSequence)/nInput);

% Apply only the first control action
controlAction = optimalSequence(:,1);

end
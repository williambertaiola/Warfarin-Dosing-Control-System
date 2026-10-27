function controlAction = MPCctrl_fvf(signal,predictedHorizon,...
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
    previousInput = 0;
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

%% Unconstrained optimization

optimalIncrementSequence = -hessianMatrix \ gradientVector;

% Reshape optimal increment sequence
optimalIncrementSequence = reshape(optimalIncrementSequence,...
    nInput,length(optimalIncrementSequence)/nInput);

% Apply only the first input increment
controlIncrement = optimalIncrementSequence(:,1);

% Recover actual control input
controlAction = previousInput + controlIncrement;

%% Update memory

previousState = currentState;
previousInput = controlAction;

end
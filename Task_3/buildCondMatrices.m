function predictionData = buildCondMatrices(A,B,C,Q,R,F,f,predictedHorizon)

% Dimensions
nOutput = size(C,1);
nInput = size(B,2);

% Weight matrices over the prediction horizon
predictionData.outputWeight = kron(eye(predictedHorizon),Q);
predictionData.inputWeight = kron(eye(predictedHorizon),R);

% Constraint matrices over the prediction horizon
predictionData.constraintMatrix = kron(eye(predictedHorizon),F);
predictionData.constraintBound = repmat(f,predictedHorizon,1);

% Initialization of prediction matrices
statePrediction = zeros(predictedHorizon*nOutput,size(A,1));
inputPrediction = zeros(predictedHorizon*nOutput,predictedHorizon*nInput);

% Prediction matrices
for predictionStep = 1:predictedHorizon

    rowIndex = (predictionStep-1)*nOutput + (1:nOutput);

    % Contribution of the current state
    statePrediction(rowIndex,:) = C*A^predictionStep;

    % Contribution of future control inputs
    for controlStep = 1:predictionStep

        columnIndex = (controlStep-1)*nInput + (1:nInput);

        inputPrediction(rowIndex,columnIndex) = C*A^(predictionStep-controlStep)*B;

    end
end

% Store prediction matrices
predictionData.statePrediction = statePrediction;
predictionData.inputPrediction = inputPrediction;

end
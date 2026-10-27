function nextState = linearModel(signal)

% Model inputs
currentState = signal(1); % Current state: ln(INR)
dose = signal(2); % Warfarin dose [mg]

% Linear model parameters
a = 0.84;
b = 0.05;

% State update
nextState = a*currentState + b*dose;

end
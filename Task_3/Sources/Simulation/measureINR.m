function y = measureINR(x,patientParamters)

% -- Parameters -----------------------------------------------------------
BASE = patientParamters.BASE; 
INRmax = patientParamters.INRmax; 

% -- Outputs --------------------------------------------------------------
INR = BASE + INRmax*(1-(x(4) + x(7))/2);
y = INR;
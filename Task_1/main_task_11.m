%% Task 1.1 - PID control of patient#001
% Author: William Bertaiola - 2163485

clear; close all; clc;

addpath(genpath('Sources'))

%% Set Parameters
% Simulation Parameters
simulationParameters = loadSimulationParameter;   

% Select one patient: patient#001, patient#002, ..., patient#100    
patientParameters = loadPatientParameter('patient#001');        

%% PID Controller tuning
Kp = 15;  % Proportional gain
Kd = 30;  % Derivative gain
Ki = 0.1; % Integral gain

T = simulationParameters.Ts; % Sampling time of the discrete time contoller 

%% Simulate 
sim('simulink_scheme_task_11.slx', [0, simulationParameters.T_sim])
    
%% Plots
figure
    
% Plot plant output: ln(INR)
ax(1) = subplot(211);
hold on 
% Plot INR reference signal
h(1) = stairs(ln_INR_r.time, ln_INR_r.signals.values, '--k','Linewidth', 1.5);     
% Plot measured INR response
h(2) = stairs(ln_INR.time, ln_INR.signals.values, 'Linewidth', 1);
% Plot therapeutic INR limits in logarithmic scale
plot([ln_INR.time(1) ln_INR.time(end)],[log(2) log(2)],'k-')
plot([ln_INR.time(1) ln_INR.time(end)],[log(3) log(3)],'k-')

% Plot settings
ylim([-0.5 1.5])
grid on
legend(h,{'Reference ln(INR)','measured ln(INR)'},'Location','SE')
ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')
title('PID control patient #001')
    
% Plot control input: warfarin dose
ax(2) = subplot(212);
% Plot warfarin dose
stairs(warfarin_dose.time, warfarin_dose.signals.values, 'Linewidth', 1.5)
    
% Plot settings
grid on
ylabel('Dose[mg]')
xlabel('Time [Hours]')
legend('Warfarin Dose','Location','NE')
title('Control action')
linkaxes(ax, 'x')
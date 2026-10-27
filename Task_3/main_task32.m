%% Task 3.2 - MPC control of nonlinear patient #001
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Simulation parameters
simulationParameters = loadSimulationParameter;

Ts = simulationParameters.Ts;

%% Patient parameters
patientParameters = loadPatientParameter('patient#001');

%% Linear model used by the MPC
A = 0.84;
B = 0.05;
C = 1;

nInput = size(B,2);

%% MPC parameters
% Prediction horizon
predictedHorizon = 100;

% Cost weights
Q = 10;
R = 0.01;

%% Input constraints
uMin = 0;
uMax = 50;

F = [-1;1];
f = [-uMin;uMax];

%% Build condensed MPC matrices
predictionData = buildCondMatrices(A,B,C,Q,R,F,f,predictedHorizon);

%% Simulation
sim('simulink_scheme_task32.slx',[0 simulationParameters.T_sim]);

%% Figure
figure

% Patient output: ln(INR)
ax(1) = subplot(2,1,1);

hold on
grid on

% Reference
h(1) = stairs(lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

% Nonlinear patient response
h(2) = stairs(lnINR_L.time,lnINR_L.signals.values,'LineWidth',1.5);

% Therapeutic range
plot([lnINR_L.time(1) lnINR_L.time(end)],[log(2) log(2)],'k-');

plot([lnINR_L.time(1) lnINR_L.time(end)],[log(3) log(3)],'k-');

ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')

title('MPC control - nonlinear patient #001')

legend(h,{'Reference ln(INR)','Measured ln(INR)'},'Location','NE')

ylim([0.5 1.5])

%% Control input: Warfarin
ax(2) = subplot(2,1,2);

stairs(warfarin_dose.time,warfarin_dose.signals.values,'LineWidth',1.5);

grid on

ylabel('Dose [mg]')
xlabel('Time [Hours]')

title('Control action')

legend('Warfarin dose','Location','NE')

ylim([0 20])

linkaxes(ax,'x')
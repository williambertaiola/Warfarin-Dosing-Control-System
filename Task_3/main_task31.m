%% Task 3.1 - MPC control of the linear patient model
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Simulation parameters
simulationParameters = loadSimulationParameter;

%% Linear patient model
A = 0.84;
B = 0.05;
C = 1;

nInput = size(B,2);

m_input = nInput;
u0 = 0;

%% MPC parameters
% Prediction horizon
predictedHorizon = 100;

% Cost weights
Q = 10;       % Output tracking penalty
R = 0.01;     % Control input penalty

%% Input constraints
uMin = 0;     % Minimum warfarin dose [mg]
uMax = 50;    % Maximum warfarin dose [mg]

F = [-1;1];
f = [-uMin;uMax];

%% Build condensed MPC matrices
predictionData = buildCondMatrices(A,B,C,Q,R,F,f,predictedHorizon);

%% Simulation
sim('simulink_scheme_task31.slx', [0, simulationParameters.T_sim])

%% Figure
figure

% Plant Output: ln(INR)
ax(1) = subplot(2,1,1);

hold on
grid on

% Reference
h(1) = stairs(lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

% Linear patient response
h(2) = stairs(lnINR_L.time,lnINR_L.signals.values,'LineWidth',1.5);

% Therapeutic range
plot([lnINR_L.time(1) lnINR_L.time(end)],[log(2) log(2)],'k-');

plot([lnINR_L.time(1) lnINR_L.time(end)],[log(3) log(3)],'k-');

ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')

title('MPC control - linear patient model')

legend(h,{'Reference ln(INR)','Measured ln(INR)'},'Location','NW')

ylim([0.5 1.5])

%% Control Input: Warfarin
ax(2) = subplot(2,1,2);

stairs(warfarin_dose.time,warfarin_dose.signals.values,'LineWidth',1.5);

grid on

ylabel('Dose [mg]')
xlabel('Time [Hours]')

title('Control action')

legend('Warfarin dose','Location','NE')

ylim([0 20])

linkaxes(ax,'x')
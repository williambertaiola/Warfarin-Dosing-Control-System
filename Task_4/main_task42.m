%% Task 4.2 - MPC with Integral Action, with constraints
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Set Parameters
% Simulation parameters
simulationParameters = loadSimulationParameter;

patientParameters = loadPatientParameter('patient#001');

%% Linear Model
A = 0.84;
B = 0.05;
C = 1;

% System dimensions
nState  = size(A,1);
nOutput = size(C,1);
nInput  = size(B,2);

%% Full Increment Velocity Form
A_aug = [A, zeros(nState,nOutput);C*A, eye(nOutput)];

B_aug = [B;C*B];

C_aug = [zeros(nOutput,nState), eye(nOutput)];

%% MPC Controller Tuning
% Prediction horizon
predictedHorizon = 100;

% Output tracking weight
Q = 10;

% Control increment weight
R = 0.2;

%% Condensed Prediction Matrices
predictionData = buildCondMatrices(A_aug,B_aug,C_aug,Q,R,predictedHorizon);

%% Patient#001 Simulation
clear MPCctrl_fvf_constr % Initialization MPC controller

% Simulate nonlinear patient #001
sim('Simulink_scheme_task_42.slx',[0 simulationParameters.T_sim]);

%% Figure 
figure(1)

% ln(INR)
ax1 = subplot(2,1,1);
hold(ax1,'on')
grid(ax1,'on')

% Reference
h1 = stairs(lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

% Nonlinear patient output
h2 = stairs(ln_INR.time,ln_INR.signals.values,'LineWidth',1.2);

% Therapeutic range
plot([ln_INR.time(1) ln_INR.time(end)],[log(2) log(2)],'k-','HandleVisibility','off')

plot([ln_INR.time(1) ln_INR.time(end)],[log(3) log(3)],'k-','HandleVisibility','off')

ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')
title('Constrained Full Increment Velocity Form MPC - Patient #001')

legend([h1 h2],{'Reference ln(INR)','Measured ln(INR)'},'Location','SE')

ylim([-0.5 2])

% Warfarin dose
ax2 = subplot(2,1,2);
hold(ax2,'on')
grid(ax2,'on')

hDose = stairs(warfarin_dose.time, warfarin_dose.signals.values,'LineWidth',1.5);

ylabel('Dose [mg]')
xlabel('Time [Hours]')
title('Control Action - Patient #001')

legend(hDose,'Warfarin Dose','Location','northeast')

linkaxes([ax1 ax2],'x')

%% Population Simulation
nPatients = 100;

INR_population  = [];
dose_population = [];

figure(2)

% ln(INR) subplot
ax1 = subplot(2,1,1);
hold(ax1,'on')
grid(ax1,'on')

title(ax1,'Constrained Full Increment Velocity Form MPC - Population Response')
xlabel(ax1,'Time [Hours]')
ylabel(ax1,'ln(INR) [dimensionless]')
ylim(ax1,[-0.5 2])

% Dose subplot
ax2 = subplot(2,1,2);
hold(ax2,'on')
grid(ax2,'on')

title(ax2,'Control Action - Population')
xlabel(ax2,'Time [Hours]')
ylabel(ax2,'Dose [mg]')

%% Simulate Entire Population
for patientIndex = 1:nPatients

    % Load current patient
    patientParameters = loadPatientParameter(sprintf('patient#%03d',patientIndex));

    % Reset previous state and previous input stored
    clear MPCctrl_fvf_constr

    % Simulate
    sim('Simulink_scheme_task_42.slx',[0 simulationParameters.T_sim]);

    % Store data
    INR_population(:,patientIndex) = ln_INR.signals.values;
    dose_population(:,patientIndex) = warfarin_dose.signals.values;

    % Plot ln(INR)
    stairs(ax1,ln_INR.time,ln_INR.signals.values,'LineWidth',0.8, ...
        'HandleVisibility','off');

    % Plot dose
    stairs(ax2,warfarin_dose.time,warfarin_dose.signals.values,'LineWidth',0.8, ...
           'HandleVisibility','off');

end

%% Complete Population Plot
% Therapeutic range
plot(ax1,[ln_INR.time(1) ln_INR.time(end)],[log(2) log(2)],'k-','LineWidth',0.5, ...
     'HandleVisibility','off')

plot(ax1,[ln_INR.time(1) ln_INR.time(end)],[log(3) log(3)],'k-','LineWidth',0.5, ...
     'HandleVisibility','off')

% Reference
hRefPopulation = stairs(ax1,lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

% Dummy handle
hPopulationINR = plot(ax1,nan,nan,'LineWidth',0.8);

legend(ax1,[hPopulationINR hRefPopulation],{'Measured ln(INR)','Reference ln(INR)'}, ...
       'Location','SE')

% Dummy handle
hPopulationDose = plot(ax2,nan,nan,'LineWidth',0.8);

legend(ax2,hPopulationDose,'Warfarin Dose','Location','NE')

linkaxes([ax1 ax2],'x')

%% Population Mean and Standard Deviation
% Mean
meanINR  = mean(INR_population,2);
meanDose = mean(dose_population,2);

% Standard deviation
stdINR  = std(INR_population,0,2);
stdDose = std(dose_population,0,2);

% Upper and lower bounds
upperINR = meanINR + stdINR;
lowerINR = meanINR - stdINR;

upperDose = meanDose + stdDose;
lowerDose = meanDose - stdDose;

%% Figure
figure(3)

ax1 = subplot(2,1,1);
hold(ax1,'on')
grid(ax1,'on')

[tINR,upperINRstairs] = stairs(ln_INR.time,upperINR);

[~,lowerINRstairs] = stairs(ln_INR.time,lowerINR);

% Mean +/- 1 std area
hStdINR = fill([tINR; flipud(tINR)],[upperINRstairs; flipud(lowerINRstairs)], ...
    [0.1 0.7 0.9],'EdgeColor','none','FaceAlpha',0.4);

stairs(ln_INR.time,upperINR,'k-','LineWidth',0.5,'HandleVisibility','off');
stairs(ln_INR.time,lowerINR,'k-','LineWidth',0.5,'HandleVisibility','off');

% Mean ln(INR)
hMeanINR = stairs(ln_INR.time,meanINR,'b-','LineWidth',2);

% Therapeutic range
plot([ln_INR.time(1) ln_INR.time(end)],[log(2) log(2)],'k-','HandleVisibility','off')

plot([ln_INR.time(1) ln_INR.time(end)],[log(3) log(3)],'k-','HandleVisibility','off')

% Reference
hRefINR = stairs(lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')
title('Population Response - Mean \pm 1 std')
ylim([-0.5 2])

legend([hStdINR hMeanINR hRefINR],{'\pm 1 std','Mean ln(INR)','Reference'}, ...
    'Location','SE')

%% Warfarin dose
ax2 = subplot(2,1,2);
hold(ax2,'on')
grid(ax2,'on')

[tDose,upperDoseStairs] = stairs(warfarin_dose.time,upperDose);

[~,lowerDoseStairs] = stairs(warfarin_dose.time,lowerDose);

% Mean +/- 1 std area
hStdDose = fill([tDose; flipud(tDose)],[upperDoseStairs; flipud(lowerDoseStairs)], ...
    [0.1 0.7 0.9],'EdgeColor','none','FaceAlpha',0.4);

stairs(warfarin_dose.time,upperDose,'k-','LineWidth',0.5,'HandleVisibility','off');
stairs(warfarin_dose.time,lowerDose,'k-','LineWidth',0.5,'HandleVisibility','off');

% Mean warfarin dose
hMeanDose = stairs(warfarin_dose.time,meanDose,'b-','LineWidth',2);

ylabel('Dose [mg]')
xlabel('Time [Hours]')
title('Population Control Action - Mean \pm 1 std')

legend([hStdDose hMeanDose],{'\pm 1 std','Mean Warfarin Dose'},'Location','NE')

linkaxes([ax1 ax2],'x')
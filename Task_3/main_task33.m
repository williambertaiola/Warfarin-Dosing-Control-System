%% Task 3.3 - MPC control of the population
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Simulation parameters
simulationParameters = loadSimulationParameter;

Ts = simulationParameters.Ts;

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

%% Population simulation
nPatients = 100;

lnINR_population = [];
dose_population = [];

figure(1)

ax(1) = subplot(2,1,1);

hold on
grid on

title('Population INR Profiles')
xlabel('Time [Hours]')
ylabel('ln(INR) [dimensionless]')

ax(2) = subplot(2,1,2);

hold on
grid on

title('Population Warfarin Dose')
xlabel('Time [Hours]')
ylabel('Dose [mg]')

for patientIndex = 1:nPatients

    patientName = sprintf('patient#%03d',patientIndex);
    patientParameters = loadPatientParameter(patientName);

    %% Simulation
    sim('simulink_scheme_task32.slx',[0 simulationParameters.T_sim]);

    if patientIndex == 1

        lnINR_population = zeros(length(lnINR_L.signals.values),nPatients);

        dose_population = zeros(length(warfarin_dose.signals.values),nPatients);

    end

    lnINR_population(:,patientIndex) = lnINR_L.signals.values;

    dose_population(:,patientIndex) = warfarin_dose.signals.values;

    hINR = stairs(ax(1),lnINR_L.time,lnINR_L.signals.values,'LineWidth',0.8);

    hDose = stairs(ax(2),warfarin_dose.time,warfarin_dose.signals.values,'LineWidth',0.8);

end

hRef = stairs(ax(1),lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.5);

plot(ax(1),[lnINR_L.time(1) lnINR_L.time(end)],[log(2) log(2)],'k-', ...
     'LineWidth',1,'HandleVisibility','off');

plot(ax(1),[lnINR_L.time(1) lnINR_L.time(end)],[log(3) log(3)],'k-', ...
     'LineWidth',1,'HandleVisibility','off');

legend(ax(1),[hINR hRef],{'Model ln(INR)','Reference ln(INR)'},'Location', ...
    'NE')

ylim(ax(1),[-0.5 2])

legend(ax(2),hDose,'Warfarin Dose','Location','NE')

ylim(ax(2),[0 15])

linkaxes(ax,'x')

meanLnINR = mean(lnINR_population,2);
stdLnINR  = std(lnINR_population,0,2);

meanDose = mean(dose_population,2);
stdDose  = std(dose_population,0,2);

figure(2)

axMean(1) = subplot(2,1,1);

hold on
grid on

% Standard deviation limits
upperLnINR = meanLnINR + stdLnINR;
lowerLnINR = meanLnINR - stdLnINR;

% Convert stair signals for shaded area
[tINR,lowerLnINRstairs] = stairs(lnINR_L.time,lowerLnINR);

[~,upperLnINRstairs] = stairs(lnINR_L.time,upperLnINR);

% Mean +/- 1 std area
fill([tINR; flipud(tINR)],[lowerLnINRstairs; flipud(upperLnINRstairs)], ...
     [0.75 0.88 0.95],'EdgeColor','none','FaceAlpha',0.7,'HandleVisibility','off');

stairs(lnINR_L.time, upperLnINR,'k-','LineWidth',0.6,'HandleVisibility','off');

stairs(lnINR_L.time,lowerLnINR,'k-','LineWidth',0.6,'HandleVisibility','off');

% Population mean
hMeanINR = stairs(lnINR_L.time,meanLnINR,'b-','LineWidth',1.5);

hRefMean = stairs(lnINR_r.time,lnINR_r.signals.values,'--k','LineWidth',1.2);

% Therapeutic range
plot([lnINR_L.time(1) lnINR_L.time(end)],[log(2) log(2)],'k-','LineWidth',1, ...
     'HandleVisibility','off');

plot([lnINR_L.time(1) lnINR_L.time(end)],[log(3) log(3)],'k-','LineWidth',1, ...
     'HandleVisibility','off');

ylabel('ln(INR) [dimensionless]')
xlabel('Time [Hours]')

title('Mean \pm 1 std Population INR Profile')

legend([hMeanINR hRefMean],{'Mean ln(INR)','Reference ln(INR)'}, ...
       'Location','NE')

ylim([-0.5 2])

%% Dose subplot

axMean(2) = subplot(2,1,2);

hold on
grid on

% Standard deviation limits
upperDose = meanDose + stdDose;
lowerDose = meanDose - stdDose;

% Convert stair signals for shaded area
[tDose,lowerDoseStairs] = stairs(warfarin_dose.time,lowerDose);

[~,upperDoseStairs] = stairs(warfarin_dose.time,upperDose);

% Mean +/- 1 std area
hDoseArea = fill([tDose; flipud(tDose)],[lowerDoseStairs; flipud(upperDoseStairs)], ...
    [0.75 0.88 0.95],'EdgeColor','none','FaceAlpha',0.7);

stairs(warfarin_dose.time,upperDose,'k-','LineWidth',0.6,'HandleVisibility','off');

stairs(warfarin_dose.time,lowerDose,'k-','LineWidth',0.6,'HandleVisibility','off');

% Mean dose
stairs(warfarin_dose.time,meanDose,'b-','LineWidth',1.5,'HandleVisibility','off');

ylabel('Dose [mg]')
xlabel('Time [Hours]')

title('Mean Population Warfarin Dose')

legend(hDoseArea, ...
       'Warfarin Dose', ...
       'Location','NE')

ylim([0 15])

linkaxes(axMean,'x')
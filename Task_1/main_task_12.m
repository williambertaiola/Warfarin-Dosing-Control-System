%% Task 1.2 - PID control of the population
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Set Parameters
% Simulation parameters
simulationParameters = loadSimulationParameter;

%% PID Controller tuning
Kp = 15;
Kd = 30;
Ki = 0.1;

T = simulationParameters.Ts;

%% Figure 1 - Entire population
nPatients = 100;

figure(1)

% Plant Output: ln(INR)
ax1 = subplot(2,1,1);
hold(ax1,'on')
grid(ax1,'on')

ylim(ax1,[-0.1 2])

ylabel(ax1,'ln(INR) [dimensionless]')
xlabel(ax1,'Time [Hours]')
title(ax1,'PID control of entire population')

% Control Input: Warfarin
ax2 = subplot(2,1,2);
hold(ax2,'on')
grid(ax2,'on')

ylabel(ax2,'Dose [mg]')
xlabel(ax2,'Time [Hours]')
title(ax2,'Control action of entire population')

%% Simulate entire population
for patientIdx = 1:nPatients

    % Load patient parameters
    patientID = sprintf('patient#%03d', patientIdx);
    patientParameters = loadPatientParameter(patientID);

    % Simulate
    sim('simulink_scheme_task_11.slx',[0 simulationParameters.T_sim]);

    % Current patient results
    currentLnINR = ln_INR.signals.values;
    currentDose  = warfarin_dose.signals.values;

    timeINR  = ln_INR.time;
    timeDose = warfarin_dose.time;

    % Allocate matrices after first simulation
    if patientIdx == 1
        allINR = zeros(length(currentLnINR), nPatients);
        allControl = zeros(length(currentDose), nPatients);
    end

    allINR(:,patientIdx) = currentLnINR;
    allControl(:,patientIdx) = currentDose;

    if patientIdx == 1
        hPatientINR = stairs(ax1,timeINR, currentLnINR,'LineWidth',1);

        hPatientDose = stairs(ax2,timeDose, currentDose,'LineWidth',1.5);
    else
        stairs(ax1,timeINR, currentLnINR,'LineWidth',1,'HandleVisibility','off');

        stairs(ax2,timeDose, currentDose,'LineWidth',1.5,'HandleVisibility','off');
    end
end

%% Reference and therapeutic range
hReference = stairs(ax1,ln_INR_r.time,ln_INR_r.signals.values,'--k','LineWidth',1.5);

% Therapeutic INR range
yline(ax1,log(2),'k-','LineWidth',1);
yline(ax1,log(3),'k-','LineWidth',1);

legend(ax1,[hPatientINR hReference],{'Patient ln(INR) profiles','Reference ln(INR)'}, ...
    'Location','NE');

legend(ax2,hPatientDose,{'Warfarin dose'},'Location','NE');

%% Mean and standard deviation
% Mean population response
avgINR = mean(allINR,2);
avgCtrl = mean(allControl,2);

% Standard deviation
stdINR = std(allINR,0,2);
stdCtrl = std(allControl,0,2);

% Upper and lower bounds
upperINR = avgINR + stdINR;
lowerINR = avgINR - stdINR;

upperCtrl = avgCtrl + stdCtrl;
lowerCtrl = avgCtrl - stdCtrl;

%% Step shaped coordinates for filled areas
[tINR_step, upperINR_step] = stairs(timeINR,upperINR);
[~, lowerINR_step] = stairs(timeINR,lowerINR);

[tCtrl_step, upperCtrl_step] = stairs(timeDose,upperCtrl);
[~, lowerCtrl_step] = stairs(timeDose,lowerCtrl);

%% Figure 2 - Mean +/- 1 std
figure(2)

ax3 = subplot(2,1,1);
hold(ax3,'on')
grid(ax3,'on')

% Mean +/- 1 std area
fill(ax3,[tINR_step; flipud(tINR_step)],[upperINR_step; flipud(lowerINR_step)], ...
    [0.1 0.7 0.9],'EdgeColor','none','FaceAlpha',0.5);

% Reference
stairs(ax3,ln_INR_r.time,ln_INR_r.signals.values,'--k','LineWidth',1.5);

% Mean
stairs(ax3,timeINR,avgINR,'b','LineWidth',2);

% Mean + 1 std
stairs(ax3,timeINR,upperINR,'k-','LineWidth',1.2);

% Mean - 1 std
stairs(ax3,timeINR,lowerINR,'k-','LineWidth',1.2);

% Therapeutic range
yline(ax3,log(2),'k-','LineWidth',1);
yline(ax3,log(3),'k-','LineWidth',1);

legend(ax3,{'\pm 1 std','Reference ln(INR)','Mean ln(INR)'},'Location','NE');

ylabel(ax3,'ln(INR) [dimensionless]')
xlabel(ax3,'Time [Hours]')
title(ax3,'PID control of entire population - mean \pm 1 std')

ylim(ax3,[-0.1 2])

ax4 = subplot(2,1,2);
hold(ax4,'on')
grid(ax4,'on')

% Mean +/- 1 std area
fill(ax4,[tCtrl_step; flipud(tCtrl_step)],[upperCtrl_step; flipud(lowerCtrl_step)], ...
    [0.1 0.7 0.9],'EdgeColor','none','FaceAlpha',0.5);

% Mean
stairs(ax4,timeDose,avgCtrl,'b','LineWidth',2);

% Mean + 1 std
stairs(ax4,timeDose,upperCtrl,'k-','LineWidth',1.2);

% Mean - 1 std
stairs(ax4,timeDose,lowerCtrl,'k-','LineWidth',1.2);

legend(ax4,{'\pm 1 std','Mean dose'},'Location','NE');

ylabel(ax4,'Dose [mg]')
xlabel(ax4,'Time [Hours]')
title(ax4,'Control action of entire population - mean \pm 1 std')
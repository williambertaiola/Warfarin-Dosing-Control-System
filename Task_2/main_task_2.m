%% Task 2 - Model implementation
% Author: William Bertaiola - 2163485

clear; close all; clc

addpath(genpath('Sources'))

%% Set Parameters
% Simulation parameters
simulationParameters = loadSimulationParameter;

% Select patient #001
patientParameters = loadPatientParameter('patient#001');

%% Comparison for patient #001
sim('simulink_scheme_task2.slx',[0 simulationParameters.T_sim]);

% Extract signals
timeNonlinear = ln_INR.time;
yNonlinear    = ln_INR.signals.values;

timeLinear = ln_INR_L.time;
yLinear    = ln_INR_L.signals.values;

timeDose = warfarin_dose.time;
dose     = warfarin_dose.signals.values;

% Reference ln(INR)
reference = zeros(size(timeLinear));
reference(timeLinear >= 48) = log(2.5);

figure(1)

% Linear vs nonlinear model
ax1 = subplot(2,1,1);
hold(ax1,'on')
grid(ax1,'on')

p_lin = stairs(ax1, timeLinear, yLinear,'r', 'LineWidth', 1.5);

p_nonlin = stairs(ax1, timeNonlinear, yNonlinear,'b', 'LineWidth', 1.5);

p_ref = stairs(ax1, timeLinear, reference,'--k', 'LineWidth', 1.3);

% Therapeutic range
plot(ax1, [timeLinear(1) timeLinear(end)],[log(2) log(2)], 'k-', 'LineWidth', 1);

plot(ax1, [timeLinear(1) timeLinear(end)],[log(3) log(3)], 'k-', 'LineWidth', 1);

xlabel(ax1, 'Time [Hours]')
ylabel(ax1, 'ln(INR) [dimensionless]')
title(ax1, 'Patient #001 INR profile')

ylim(ax1, [0 2])

legend(ax1, [p_lin p_nonlin p_ref],{'Linear model', 'Nonlinear patient model',...
    'Reference ln(INR)'},'Location', 'SE');

% Warfarin input
ax2 = subplot(2,1,2);
hold(ax2,'on')
grid(ax2,'on')

p_dose_1 = stairs(ax2, timeDose, dose,'LineWidth', 1.5);

xlabel(ax2, 'Time [Hours]')
ylabel(ax2, 'Dose [mg]')
title(ax2, 'Patient #001 Dose')

legend(ax2, p_dose_1, 'Warfarin Dose','Location', 'NE');

ylim(ax2, [-0.1 5])

linkaxes([ax1 ax2], 'x')

%% Population analysis
nPatients = 100;

nSamples = length(yNonlinear);

INR_population = zeros(nSamples,nPatients);

figure(2)

ax3 = subplot(2,1,1);
hold(ax3,'on')
grid(ax3,'on')

ax4 = subplot(2,1,2);
hold(ax4,'on')
grid(ax4,'on')

for patientIdx = 1:nPatients

    patientID = sprintf('patient#%03d', patientIdx);
    patientParameters = loadPatientParameter(patientID);

    sim('simulink_scheme_task2.slx',[0 simulationParameters.T_sim]);

    INR_population(:,patientIdx) = ln_INR.signals.values;

    stairs(ax3, ln_INR.time,ln_INR.signals.values,'LineWidth', 0.8);
end

% Linear model is identical for all patients
p_linear = stairs(ax3, ln_INR_L.time,ln_INR_L.signals.values,'k', 'LineWidth', 2);

% Reference ln(INR)
reference = zeros(size(ln_INR_L.time));
reference(ln_INR_L.time >= 48) = log(2.5);

p_ref_population = stairs(ax3, ln_INR_L.time, reference,'--k', 'LineWidth', 1.3);

% Therapeutic range
plot(ax3, [ln_INR_L.time(1) ln_INR_L.time(end)],[log(2) log(2)],'k-', 'LineWidth', 1);

plot(ax3, [ln_INR_L.time(1) ln_INR_L.time(end)],[log(3) log(3)],'k-', 'LineWidth', 1);

xlabel(ax3, 'Time [Hours]')
ylabel(ax3, 'ln(INR) [dimensionless]')
title(ax3, 'Population profiles')

ylim(ax3, [0 2])

legend(ax3, [p_linear p_ref_population],{'Linear model', 'Reference ln(INR)'}, ...
       'Location', 'NW');

% Dose identical for all patients
p_dose_population = stairs(ax4, warfarin_dose.time, warfarin_dose.signals.values, ...
                                'LineWidth', 1.2);

xlabel(ax4, 'Time [Hours]')
ylabel(ax4, 'Dose [mg]')
title(ax4, 'Population Warfarin Dosage')

ylim(ax4, [-0.1 5])

legend(ax4, p_dose_population,'Warfarin Dose','Location', 'NE');

linkaxes([ax3 ax4], 'x')

%% Population mean and standard deviation
timeAxis = ln_INR.time;

mean_INR = mean(INR_population,2);
std_INR  = std(INR_population,0,2);

upperBand = mean_INR + std_INR;
lowerBand = mean_INR - std_INR;

% Convert boundaries to step shaped vectors
[tBand, lowerStep] = stairs(timeAxis, lowerBand);
[~, upperStep]     = stairs(timeAxis, upperBand);

%% Figure - Mean ± 1 std
figure(3)

ax5 = subplot(2,1,1);
hold(ax5,'on')
grid(ax5,'on')

% Linear model
p_linear_mean = stairs(ax5, ln_INR_L.time,ln_INR_L.signals.values, ...
                            'r', 'LineWidth', 1.5);

% Population mean
p_mean = stairs(ax5, timeAxis, mean_INR, 'b', 'LineWidth', 1.5);

% Reference ln(INR)
reference = zeros(size(ln_INR_L.time));
reference(ln_INR_L.time >= 48) = log(2.5);

p_ref_mean = stairs(ax5, ln_INR_L.time, reference, '--k', 'LineWidth', 1.3);

% Standard deviation envelope
p_std = fill(ax5,[tBand; flipud(tBand)],[lowerStep; flipud(upperStep)], ...
    [0.3 0.7 0.9],'EdgeColor', 'none','FaceAlpha', 0.3);

stairs(ax5, timeAxis, upperBand,'k', 'LineWidth', 0.5);
stairs(ax5, timeAxis, lowerBand,'k', 'LineWidth', 0.5);

% Therapeutic range
plot(ax5, [ln_INR_L.time(1) ln_INR_L.time(end)],[log(2) log(2)],'k-', 'LineWidth', 1);

plot(ax5, [ln_INR_L.time(1) ln_INR_L.time(end)],[log(3) log(3)],'k-', 'LineWidth', 1);

xlabel(ax5, 'Time [Hours]')
ylabel(ax5, 'ln(INR) [dimensionless]')
title(ax5, 'Mean \pm 1 std Population INR Profile')

ylim(ax5, [0 2])

legend(ax5, [p_linear_mean p_mean p_ref_mean],{'Linear model', 'Population mean', ...
    'Reference ln(INR)'},'Location', 'SE');

%% Mean population dose
ax6 = subplot(2,1,2);
hold(ax6,'on')
grid(ax6,'on')

p_dose_mean = stairs(ax6, warfarin_dose.time,warfarin_dose.signals.values, ...
    'b', 'LineWidth', 1.2);

xlabel(ax6, 'Time [Hours]')
ylabel(ax6, 'Dose [mg]')
title(ax6, 'Mean Population Warfarin Dose')

legend(ax6, p_dose_mean,'Warfarin Dose','Location', 'NE');

ylim(ax6, [-0.1 5])

linkaxes([ax5 ax6], 'x')
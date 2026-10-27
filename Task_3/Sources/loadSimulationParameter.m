function simultationParameters= loadSimulationParameter

simultationParameters.T_sim=20*24;                 % [h] simulation duration
simultationParameters.T_integration =1/60;         % integration time [h] 
simultationParameters.Ts=1*24;                     % [h] sampling time

simultationParameters.u_max=50;                    % [mg] max Warfarin dose
simultationParameters.u_min=0;                     % [mg] min Warfarin dose

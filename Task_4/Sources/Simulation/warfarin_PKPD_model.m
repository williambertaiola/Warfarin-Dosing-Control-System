function dx = warfarin_PKPD_model(x, u, patientParam)


% Hamberg 2010
   
% PARAMETERS ================================================
% parametri PK: 
k_a = 2;   
k_e = patientParam.k_e;     % [h^-1]
% parametri PD:
Emax = 1;                   %fixed []
gamma = patientParam.gamma; % []
EC50 = patientParam.EC50;   % []
MTT1 = patientParam.MTT1;   % [h]
MTT2 = patientParam.MTT2;   % [h]
k1 = 3/MTT1;                % [h^-1]
k2 = 3/MTT2;                % [h^-1]

% EQUAZIONI ================================================
dx(8) = -k_a*x(8) + u;

dx(1) = k_a*x(8)-k_e*x(1);

% PD equations:
DR = x(1)*k_e;
if DR <= 0
  EFF = 0;
else
  EFF = Emax*(DR^gamma)/(EC50^gamma+DR^gamma);
end

% First coagulation chain
dx(2) = k1*(1-EFF)-k1*x(2);
dx(3) = k1*x(2)-k1*x(3);
dx(4) = k1*x(3)-k1*x(4);

% Second coagulation chain
dx(5) = k2*(1-EFF)-k2*x(5);
dx(6) = k2*x(5)-k2*x(6);
dx(7) = k2*x(6)-k2*x(7);


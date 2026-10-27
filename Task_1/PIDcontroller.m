function y = PIDcontroller(u,Kp,Kd,Ki,T)

    % Inputs from Simulink
    ln_INR_r = u(1); % Reference ln(INR)
    ln_INR   = u(2); % Measured ln(INR)
    I_e_old  = u(3); % Previous integral value
    e_old    = u(4); % Previous error
    
    % Current error
    e = ln_INR_r - ln_INR;
    
    % Integral update
    I_e = I_e_old + e*T;
    
    % Derivative term
    D_e = (e - e_old)/T;
    
    % PID control action
    control = Kp*e + Ki*I_e + Kd*D_e;

    % Outputs:
    % y(1) = control action
    % y(2) = current integral
    % y(3) = current error
    y = [control; I_e; e];

end
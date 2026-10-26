% Parameters

clear
clc
close all


n = 1.75;
Vt = 0.0259;
R = linspace(100, 5000, 500);
Vcc = 3;
Is = 5.3e-12

arg = R * Is / (n * Vt) * exp(Vcc / (n * Vt));

ID = n*Vt./R .* lambertw(0, arg);

figure()
plot(R, ID * 1e3, 'LineWidth', 2);
grid on;
xlabel('Series Resistor Resistance');
ylabel('Diode Current (mA)');
title('Diode Current vs Series Resistor Resistance');

valid_idx = (ID >= 2e-3) & (ID <= 5e-3);
valid_resistances = R(valid_idx);
valid_currents = ID(valid_idx) .* 1000;

valids = [valid_resistances;valid_currents];
writematrix(valids, "Valids.csv");
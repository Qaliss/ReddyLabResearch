clear
clc
close all

n = 1.75;
R_resistor = 500;
f = linspace(0, 1, 50);
R_effective = 10000 * f;
R_total = R_effective + R_resistor;
Vt = 0.0259;
Vcc = 3;
Is = 5.3e-12;

arg = n*Vt./R_total;

ID = arg .* lambertw(R_total./(n*Vt) * Is * exp(Vcc / (n*Vt)));

I_mA = ID * 1000;

figure()
plot(f, I_mA, 'LineWidth', 2);
grid on
xlabel("Fraction of Potentiometer Turn");
ylabel("Current in circuit [mA]");
title("Current in Pot-Resistor-Diode Series Circuit based on Dial Position");



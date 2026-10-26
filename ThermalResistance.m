clear
clc
close all

max_ratings = readmatrix("SBT-10X-UV LED Absolute Maximum Ratings.xlsx");
typical_device_performance = readmatrix("SBT-10X-UV LED Typical Device Performance.xlsx");
max_junction_temperature = max_ratings(4, 1); % As per datasheet

disp("This device typically operates at 25 [C]. Design ambient is 30 [C].");

wavelengths = string(typical_device_performance(1, :));

R_thermal_jc = 2.6; % As per datasheet


L = [0.8, 1.0, 1.57, 1.6, 2.0, 3.2] ./ 1000; % Thickness of the PCB [mm] -> [m]
k = 0.3; % Conductivity of FR4 PCB material
A = 1.25e-3 * 3.2e-3; % Area of Thermal Contact on the LED itself (shown in dimensions between anode and cathode)

R_thermal_cs = L / (k * A);

T_ambient = 30; % Estimated to be around room temp

R_thermal_sa = zeros(1, length(L));

figure; hold on; grid on;

for j = 1: 1: length(wavelengths)

    typical_forward_voltage = typical_device_performance(5, j);
    max_forward_voltage = typical_device_performance(6, j);
    fprintf("The typical forward voltage for your selected wavelength is %0.1f [V].\n", typical_forward_voltage)
    fprintf("The maximum forward voltage for your selected wavelength is %0.1f [V].\n\n", max_forward_voltage)


    if j > 1
        max_current = max_ratings(3, 1);
    else
        max_current = max_ratings(2, 1);
    end

    fprintf("The maximum current for your wavelength is %0.1f [A].\n\n", max_current);

    electrical_power_dissipated = max_forward_voltage * max_current; % Use the maximum values of forward voltage and current to overestimate power dissipated. Makes it a conservative estimate.
    p_heat = electrical_power_dissipated * 0.683; % Using a Wall-Plug-Efficiency of 31.7%, as denoted in the datasheet

    fprintf("The maximum electrical power dissipated for your selected wavelength is %0.3f [W].\n", electrical_power_dissipated);
    fprintf("The maximum heat power dissipated for your selected wavelength is %0.3f [W].\n", p_heat);

    R_thermal_sa = (max_junction_temperature - T_ambient)/p_heat - R_thermal_jc - R_thermal_cs;

    plot(L, R_thermal_sa, "-o", "DisplayName", wavelengths(j) + " nm");
end
xlabel("FR4-PCB Thickness in meters");
ylabel("Thermal Resistance Required for Heatsink");
legend("show");
title("Thermal Resistance Required for heatsink based on wavelength and PCB thickness");
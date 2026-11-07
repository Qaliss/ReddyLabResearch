clear
clc
close all

max_ratings = readmatrix("SBT-10X-UV LED Absolute Maximum Ratings.xlsx");
typical_device_performance = readmatrix("SBT-10X-UV LED Typical Device Performance.xlsx");
max_junction_temperature = max_ratings(4, 1); % As per datasheet

disp("This device typically operates at 25 [C]. Design ambient is 30 [C].");
T_AMBIENT = 30;
T_JUNCTION = 125;

wavelengths = string(typical_device_performance(1, :));
wavelength = menu("Select a wavelength.", wavelengths);
fprintf("You chose a wavelength of %s [nm].\n", wavelengths(wavelength));

typical_forward_voltage = typical_device_performance(5, wavelength);
max_forward_voltage = typical_device_performance(6, wavelength);

if wavelength > 1
    max_current = max_ratings(3, 1);
else
    max_current = max_ratings(2, 1);
end
   

WPE = 31.7;
power_percent_heat = (100 - WPE) * 0.01;
power_heat = power_percent_heat * max_forward_voltage * max_current;

fprintf("\nThe maximum forward voltage for your selected wavelength is %0.1f [V].\n", max_forward_voltage);
fprintf("The maximum forward current for your selected wavelength is %0.1f [A].\n", max_current);
fprintf("The power_dissipated to heat is %0.3f [W].\n\n", power_heat);

Rth_jc = 2.6;

pcb_thicknesses = string([0.8, 1.0, 1.57, 1.6, 2.0, 3.2]); % Thickness of the PCB [mm] -> [m]
pcb_thickness = menu("Please select a thickness for your PCB [mm]", pcb_thicknesses);
pcb_thickness_m = str2double(pcb_thicknesses(pcb_thickness)) / 1000;
fprintf("You chose a PCB thickness of %0.5f [m].\n", pcb_thickness_m);

via_diameters = string([0.1, 0.2, 0.3, 0.4]); % Diameter of via through-hole [mm] -> [m]
via_diameter = menu("Please select a diameter for the through-hole of the vias [mm]", via_diameters);
via_diameter_m = (str2double(via_diameters(via_diameter))) / 1000;
fprintf("You chose a via diameter of %0.5f [m].\n", via_diameter_m);
via_area = pi * (via_diameter_m / 2)^2;


% Using circle packing calculator in a rectangle, around 80% of circles to account
% for error

if via_diameter == 1
    n_vias = input("Please select a number of thermal vias (0-76): ");
elseif via_diameter == 2
    n_vias = input("Please select a number of thermal vias (0-18): ");
elseif via_diameter == 3
    n_vias = input("Please select a number of thermal vias (0-8): ");
elseif via_diameter == 4
    n_vias = input("Please select a number of thermal vias (0-2): ");
end

fprintf("You chose %d vias.\n", n_vias);

VIA_K = 58; % W/K

R_thvias = pcb_thickness_m / (n_vias * VIA_K * via_area);
area_vias = n_vias * via_area;

R_thFR4 = pcb_thickness_m / (0.2 * (1.25/1000 * 3.2/1000 - area_vias));
R_thFR4_vias = 1/((1/R_thFR4 + 1/R_thvias));


TIM_choices = ["Pad", "Gel", "Grease"];
TIM_choice = menu("Please select a TIM type.", TIM_choices);
if TIM_choice == 1
    TIM_k = 3; % Average
    TIM_thickness = 1/1000; % [m], avg
elseif TIM_choice == 2
    TIM_k = 5;
    TIM_thickness = 0.25/1000; % m
else
    TIM_k = 4;
    TIM_thickness = 0.05/1000;
end

fprintf("You chose a %s TIM.\n", TIM_choices(TIM_choice));

R_thTIM = TIM_thickness / (TIM_k * (1.25/1000 * 3.2/1000));

R_thha = (T_JUNCTION - T_AMBIENT) / power_heat - Rth_jc - R_thFR4_vias - R_thTIM;

fprintf("Thermal resistance in vias is %0.4f [K/W]\n", R_thvias);
fprintf("Thermal resistance in FR4 PCB is %0.4f [K/W]\n", R_thFR4);
fprintf("Thermal resistance in PCB and vias is %0.4f [K/W]\n", R_thFR4_vias)
fprintf("Thermal resistance in the TIM is %0.4f [K/W]\n", R_thTIM);
fprintf("Heatsink requires a thermal resistance of %0.4f [K/W].", R_thha);


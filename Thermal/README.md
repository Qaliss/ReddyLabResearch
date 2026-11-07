# Thermal

Thermal-budget model for the Luminus SBT-10X-UV LED (365–420 nm) used in the Reddy lab LED-driver work. The question it answers: given a wavelength, a PCB, and a thermal interface material, what thermal resistance must the heatsink have to keep the junction below its limit?

## Data files

Both scripts read their inputs from these two spreadsheets (datasheet values, kept in the same folder):

- `SBT-10X-UV LED Absolute Maximum Ratings.xlsx` — max forward voltage/current per wavelength and the max junction temperature (row 4).
- `SBT-10X-UV LED Typical Device Performance.xlsx` — wavelengths (row 1), typical forward voltage (row 5), max forward voltage (row 6).

## `ThermalResistance.m` — baseline 1-D model

Loops over every wavelength and six PCB thicknesses and computes the heatsink resistance the design still needs.

- Board: FR4, k = 0.3 W/m·K, conduction area = LED footprint 1.25 × 3.2 mm, thicknesses 0.8 / 1.0 / 1.57 / 1.6 / 2.0 / 3.2 mm.
- Junction-to-case: Rθj-c = 2.6 °C/W (datasheet, real value at 3 A).
- Ambient: 30 °C. Junction limit: read from the ratings spreadsheet.
- Max current from the ratings sheet (first wavelength uses row 2, the rest row 3).
- Power: worst case, P_elec = Vf_max × I_max; heat = 68.3% of P_elec (wall-plug efficiency 31.7%).
- Required heatsink resistance: R_thsa = (Tjmax − 30) / P_heat − Rθj-c − R_board.
- Output: one plot, required heatsink resistance vs PCB thickness, one curve per wavelength.

Finding: the required heatsink resistance comes out negative — the FR4 board path alone already exceeds the whole thermal budget, so no heatsink can fix it. The board, not the heatsink, is the bottleneck.

## `ThermalResistanceWithVias.m` — interactive model with vias and TIM

Same series chain, but interactive (menu prompts) and extended with thermal vias through the board and a thermal interface material (TIM) under it.

Menus: wavelength → PCB thickness → via diameter (0.1 / 0.2 / 0.3 / 0.4 mm) → number of vias → TIM type.

- Via counts come from circle packing at ~80% fill: 0–76 for 0.1 mm, 0–18 for 0.2 mm, 0–8 for 0.3 mm, 0–2 for 0.4 mm.
- Vias are modeled as solder-filled, k = 58 W/m·K: R_thvias = L / (n · k · A_via).
- FR4 resistance uses the footprint area minus the via holes, and is paralleled with the via path: R_board = 1 / (1/R_FR4 + 1/R_vias).
- TIM options: Pad (k = 3, 1 mm), Gel (k = 5, 0.25 mm), Grease (k = 4, 0.05 mm). R_TIM = t / (k · A_footprint).
- Junction limit is hardcoded to 125 °C (datasheet Tjmax); ambient 30 °C.
- Prints each term (vias, FR4, board + vias, TIM) and the required heatsink resistance: R_thha = (125 − 30) / P_heat − Rθj-c − R_board − R_TIM.

Current status (395 nm, 4.1 V, 4.0 A, P_heat = 11.2 W, 1.6 mm board, grease TIM): 6 × 0.2 mm vias → board 136.8 °C/W, required heatsink −134.05 °C/W. Maxed out at 18 vias → board 47.8 °C/W, required heatsink −45.03 °C/W. Vias alone do not close the gap — the board path needs to be ≤ ~2.8 °C/W.

## Assumptions and notes

- Both scripts apply the same 31.7% wall-plug efficiency at every wavelength; the datasheet WPE varies by wavelength.
- FR4 conductivity differs between the two scripts: 0.3 W/m·K in `ThermalResistance.m`, 0.2 W/m·K in `ThermalResistanceWithVias.m`.
- In `ThermalResistanceWithVias.m`, the junction limit is read from the spreadsheet but the calculation uses the hardcoded 125 °C.
- One-dimensional conduction through the LED footprint only — no lateral heat spreading into the copper pour, no convection or radiation. Steady state.
- All units SI in the code (mm converted to m).

## Running

MATLAB, with the two `.xlsx` files in the same folder. `ThermalResistance.m` runs straight through and plots; `ThermalResistanceWithVias.m` prompts for each choice.

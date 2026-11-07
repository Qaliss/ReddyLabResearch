# Circuit

Circuit exploration for LED brightness control with a microcontroller, for the Reddy lab LED-driver work. Two parts: MATLAB models that size the resistor/potentiometer for the LED test circuit, and ESP32 sketches that drive an LED with PWM.

## `Diode.m` — diode current vs series resistor

Solves the diode equation with a series resistor in closed form (Lambert W function) and finds which resistor values keep the diode current in the 2–5 mA window.

- Diode model: ideality factor n = 1.75, thermal voltage Vt = 0.0259 V, saturation current Is = 5.3e-12 A, supply Vcc = 3 V.
- Series resistance swept 100–5000 Ω (500 points): ID = (n·Vt / R) · W(R·Is / (n·Vt) · exp(Vcc / (n·Vt))).
- Output: plot of diode current (mA) vs series resistance, and `Valids.csv` with the valid (resistance, current) pairs.

## `Valids.csv` — output of `Diode.m`

Two rows, 65 entries: valid series resistances (Ω) and the corresponding diode currents (mA) for the 2–5 mA window. Resistance runs ~414–1043 Ω as current falls from ~4.98 to ~2.02 mA.

## `Potentiometer.m` — pot as a dimmer

Same diode model, now with a 10 kΩ potentiometer in series with a fixed 500 Ω resistor. The pot is modeled as a variable resistor (rheostat): R_total = 500 + 10000 · f, where f is the fraction of the pot's turn (0–1, 50 points). Plots circuit current (mA) vs dial position.

## `PWM/` — ESP32 sketches (LED on pin 2)

- `blink_led.ino` — blinks the LED 500 ms on / 500 ms off. Baseline sanity check.
- `led_dimmer.ino` — fades the LED by ramping the PWM duty cycle 0 → 255 → 0 in 15 ms steps (breathing LED).
- `sinusoid_dimmer.ino` — maps a sinusoid to brightness: a precomputed 628-point sine lookup table, values (sin + 1) × 127.5, stepped through with a frequency multiplier of 3.0 and a phase offset of 1.571, 20 ms per step.

PWM is the starting point for brightness-tracking exploration (driving LED brightness from a reference signal). It is not acceptable for the lab's final driver circuit — the tracking work starts here and moves to a non-PWM approach.

## Running

- MATLAB scripts run as-is (`Diode.m` writes `Valids.csv` into the same folder).
- `.ino` sketches open in the Arduino IDE with an ESP32 board selected; LED on pin 2.

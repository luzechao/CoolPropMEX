% Test script for CoolProp MATLAB MEX wrappers
% Add the Release folder to path before running

%% Test 1: PropsSI - High-level interface
fprintf('=== Testing PropsSI ===\n');
rho = PropsSI('D', 'T', 300, 'P', 101325, 'Water');
fprintf('Density of water at 300K, 101325Pa: %.2f kg/m³\n', rho);

h = PropsSI('H', 'T', 300, 'P', 101325, 'Water');
fprintf('Enthalpy: %.2f J/kg\n', h);

%% Test 2: HAPropsSI - Humid air
fprintf('\n=== Testing HAPropsSI ===\n');
h_ha = HAPropsSI('H', 'T', 298.15, 'R', 0.5, 'P', 101325);
fprintf('Enthalpy of humid air at 25°C, 50%% RH: %.2f J/kg_da\n', h_ha);

T_dp = HAPropsSI('D', 'T', 298.15, 'R', 0.5, 'P', 101325);
fprintf('Dew point temperature: %.2f K\n', T_dp);

%% Test 3: AbstractState with AbstractState class
fprintf('\n=== Testing AbstractState class ===\n');
state = AbstractState('HEOS', 'Water');

% Update with PT_INPUTS (now correctly = 9)
state.update(AbstractState.PT_INPUTS, 101325, 300);

fprintf('Using PT_INPUTS = %d\n', AbstractState.PT_INPUTS);
fprintf('Temperature: %.2f K\n', state.T());
fprintf('Pressure: %.2f Pa\n', state.p());
fprintf('Density: %.2f kg/m³\n', state.rhomass());
fprintf('Enthalpy: %.2f J/kg\n', state.hmass());
fprintf('Entropy: %.2f J/kg/K\n', state.smass());
fprintf('Cp: %.2f J/kg/K\n', state.cpmass());
fprintf('Viscosity: %.6e Pa·s\n', state.viscosity());
fprintf('Thermal conductivity: %.6f W/m/K\n', state.conductivity());

% Get critical properties
fprintf('Critical temperature: %.2f K\n', state.Tcrit());
fprintf('Critical pressure: %.2f Pa\n', state.pcrit());

% Clean up
clear state;

%% Test 4: Mixture with AbstractState
fprintf('\n=== Testing Mixture (Methane & Ethane) ===\n');
mixture = AbstractState('HEOS', 'Methane&Ethane');
mixture.set_fractions([0.5, 0.5]);
mixture.update(AbstractState.PT_INPUTS, 101325, 300);

fprintf('Mixture density: %.2f kg/m³\n', mixture.rhomass());
fprintf('Mixture enthalpy: %.2f J/kg\n', mixture.hmass());

fracs = mixture.get_mole_fractions();
fprintf('Mole fractions: [%.2f, %.2f]\n', fracs(1), fracs(2));

clear mixture;

fprintf('\n=== All tests completed successfully! ===\n');

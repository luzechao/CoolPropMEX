# CoolProp MATLAB Wrapper

This folder contains the MATLAB MEX wrappers for CoolProp, providing both high-level and low-level interfaces.

## Features

- **PropsSI** - High-level interface for pure and pseudo-pure fluids
- **HAPropsSI** - High-level interface for humid air properties
- **AbstractState** - Low-level interface for advanced calculations (mixtures, derivatives, etc.)

## Building the MEX Functions

### Prerequisites
- MATLAB (R2015b or later recommended)
- CMake (version 3.15 or later)
- C++ compiler compatible with your MATLAB version
- CoolProp library built in `..\..\build\Release\`

### Build Instructions

1. Compile CoolProp as Shared Library as explained in [documentation](https://coolprop.org/coolprop/wrappers/SharedLibrary/index.html). 

2. Copy this project to the following directory:
   ```powershell
   $COOLPROP_ROOT$\wrappers\MATLAB
   ```

3. Create a build directory and run CMake:
   ```powershell
   mkdir build
   cd build
   cmake ..
   cmake --build . --config Release
   ```

4. The compiled MEX files will be in the `Release` folder along with `CoolProp.dll`:
   - `PropsSI.mexw64` - Pure fluid properties
   - `HAPropsSI.mexw64` - Humid air properties
   - `AbstractState.mexw64` - Low-level interface
   - `CoolPropState.m` - Helper class for AbstractState

## Using the MEX Functions in MATLAB

### Setup
Add the Release folder to your MATLAB path:
```matlab
addpath('$COOLPROP_ROOT$\wrappers\MATLAB\Release')
```
Replace `$COOLPROP_ROOT$` with your path

---

## PropsSI - Pure and Pseudo-Pure Fluid Properties

### Function Syntax
```matlab
result = PropsSI(Output, Name1, Prop1, Name2, Prop2, FluidName)
```

**Parameters:**
- `Output` (string): The output property to calculate (e.g., 'D' for density, 'H' for enthalpy)
- `Name1` (string): Name of first input property (e.g., 'T' for temperature, 'P' for pressure)
- `Prop1` (double): Value of first input property
- `Name2` (string): Name of second input property
- `Prop2` (double): Value of second input property
- `FluidName` (string): Name of the fluid (e.g., 'Water', 'Air', 'R134a')

**Returns:**
- `result` (double): The calculated property value

### Examples

```matlab
% Get density of water at 101325 Pa and 300 K
rho = PropsSI('D', 'T', 300, 'P', 101325, 'Water')
% Returns: 996.56 kg/m³

% Get enthalpy of R134a at 101325 Pa and 300 K
h = PropsSI('H', 'T', 300, 'P', 101325, 'R134a')
% Returns: 452080 J/kg

% Get temperature of water at 101325 Pa with quality = 0 (saturated liquid)
T_sat = PropsSI('T', 'P', 101325, 'Q', 0, 'Water')
% Returns: 373.12 K

% Get critical temperature of CO2
T_crit = PropsSI('Tcrit', 'P', 0, 'T', 0, 'CO2')
% Returns: 304.13 K
```

### Common Property Keys

**Input/Output Properties:**
- `T` - Temperature [K]
- `P` - Pressure [Pa]
- `D` - Density [kg/m³]
- `H` - Enthalpy [J/kg]
- `S` - Entropy [J/kg/K]
- `Q` - Quality (vapor fraction) [0-1]
- `U` - Internal energy [J/kg]

**Fluid Properties (Output only):**
- `Tcrit` - Critical temperature [K]
- `Pcrit` - Critical pressure [Pa]
- `C` - Speed of sound [m/s]
- `V` - Viscosity [Pa·s]
- `L` - Thermal conductivity [W/m/K]

For a complete list of properties, see the [CoolProp documentation](http://www.coolprop.org/coolprop/HighLevelAPI.html#parameter-table).

---

## HAPropsSI - Humid Air Properties

### Function Syntax
```matlab
result = HAPropsSI(Output, Name1, Prop1, Name2, Prop2, Name3, Prop3)
```

**Parameters:**
- `Output` (string): The output property to calculate (e.g., 'H' for enthalpy, 'T' for temperature)
- `Name1` (string): Name of first input property (e.g., 'T', 'P', 'R', 'B')
- `Prop1` (double): Value of first input property
- `Name2` (string): Name of second input property
- `Prop2` (double): Value of second input property
- `Name3` (string): Name of third input property (usually 'P' for pressure)
- `Prop3` (double): Value of third input property

**Returns:**
- `result` (double): The calculated property value

### Humid Air Property Keys

**Input/Output Properties:**
- `T` - Dry bulb temperature [K]
- `P` - Pressure [Pa]
- `R` - Relative humidity [0-1]
- `B` - Wet bulb temperature [K]
- `D` - Dew point temperature [K]
- `W` - Humidity ratio [kg water/kg dry air]
- `H` - Enthalpy per kg dry air [J/kg]
- `S` - Entropy per kg dry air [J/kg/K]
- `V` - Specific volume [m³/kg dry air]
- `Vda` - Mixture specific volume per kg dry air [m³/kg]
- `Vha` - Mixture specific volume per kg humid air [m³/kg]

### Humid Air Examples

```matlab
% Get enthalpy of humid air at 25°C, 50% RH, and 101325 Pa
h = HAPropsSI('H', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~50800 J/kg_dry_air

% Get dew point at 25°C, 50% RH, and 101325 Pa
T_dp = HAPropsSI('D', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~287.4 K (14.3°C)

% Get humidity ratio at 25°C, 50% RH, and 101325 Pa
W = HAPropsSI('W', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~0.0099 kg_water/kg_dry_air

% Get wet bulb temperature at 25°C, 50% RH, and 101325 Pa
T_wb = HAPropsSI('B', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~291.4 K (18.3°C)

% Get relative humidity from temperature and humidity ratio
RH = HAPropsSI('R', 'T', 298.15, 'W', 0.01, 'P', 101325)
% Returns: ~0.506 (50.6%)
```

**Note:** Pressure (P) is typically specified as the third input for humid air calculations.

---

## AbstractState - Low-Level Interface

The AbstractState interface provides advanced functionality including:
- Mixture property calculations
- Phase specification
- Partial derivatives
- More control over calculations

### Using the Helper Class (Recommended)

The `CoolPropState` class provides an easy-to-use object-oriented interface:

```matlab
% Create a state object
state = CoolPropState('HEOS', 'Water');

% Update state with pressure and temperature
state.update(CoolPropState.PT_INPUTS, 101325, 300);

% Get properties
rho = state.rhomass()      % Mass density [kg/m³]
h = state.hmass()          % Mass enthalpy [J/kg]
s = state.smass()          % Mass entropy [J/kg/K]
cp = state.cpmass()        % Mass cp [J/kg/K]
visc = state.viscosity()   % Viscosity [Pa·s]
cond = state.conductivity() % Thermal conductivity [W/m/K]

% The destructor automatically frees the C++ object
clear state
```

### Input Pair Constants

Common input pairs available in `CoolPropState`:
- `PT_INPUTS` - Pressure [Pa], Temperature [K]
- `DmassT_INPUTS` - Mass density [kg/m³], Temperature [K]
- `HmassP_INPUTS` - Mass enthalpy [J/kg], Pressure [Pa]
- `PSmass_INPUTS` - Pressure [Pa], Mass entropy [J/kg/K]
- `PQ_INPUTS` - Pressure [Pa], Quality [0-1]
- `QT_INPUTS` - Quality [0-1], Temperature [K]

### Mixture Example

```matlab
% Create a mixture state
state = CoolPropState('HEOS', 'Methane&Ethane');

% Set mole fractions (50% methane, 50% ethane)
state.set_fractions([0.5, 0.5]);

% Update and get properties
state.update(CoolPropState.PT_INPUTS, 101325, 300);
rho = state.rhomass()
h = state.hmass()

% Check mole fractions
fracs = state.get_mole_fractions()
```

### Using the Low-Level MEX Interface Directly

For advanced users, you can call the MEX function directly:

```matlab
% Create state
handle = AbstractState('create', 'HEOS', 'Water');

% Update state
AbstractState('update', handle, 8, 101325, 300);  % 8 = PT_INPUTS

% Get output (iDmass = 11 for mass density)
rho = AbstractState('keyed_output', handle, 11);

% Free the state when done
AbstractState('free', handle);
```

Available commands:
- `create` - Create new state
- `free` - Free state
- `update` - Update state with input pair
- `keyed_output` - Get property by key
- `set_fractions` - Set mole fractions
- `get_mole_fractions` - Get mole fractions
- `specify_phase` - Force phase (liquid/gas)
- `unspecify_phase` - Remove phase specification
- `backend_name` - Get backend name
- `fluid_names` - Get fluid names

**Note:** Pressure (P) is typically specified as the third input for humid air calculations.

---

## Error Handling

The MEX function will throw MATLAB errors for:
- Incorrect number of input/output arguments
- Invalid input types (non-string or non-numeric where expected)
- CoolProp exceptions (e.g., invalid fluid name, out-of-range conditions)

Example:
```matlab
try
    rho = PropsSI('D', 'T', 300, 'P', 101325, 'InvalidFluid')
catch e
    fprintf('Error: %s\n', e.message)
end
```

## Files

- `PropsSI.cpp` - PropsSI MEX source code
- `HAPropsSI.cpp` - HAPropsSI MEX source code
- `AbstractState.cpp` - AbstractState MEX source code
- `CoolPropState.m` - Object-oriented wrapper for AbstractState
- `CMakeLists.txt` - CMake build configuration

## Troubleshooting

**Problem:** MEX file not found
- Make sure you've added the `Release` folder to your MATLAB path

**Problem:** Cannot load library
- Ensure `CoolProp.dll` is in the same directory as the MEX files

**Problem:** Build fails
- Verify CoolProp library exists in `..\..\build\Release\`
- Check that your C++ compiler is compatible with your MATLAB version
- Run `mex -setup` in MATLAB to configure the compiler

## License

CoolProp is licensed under the MIT License. See the root directory LICENSE file for details.

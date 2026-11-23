# CoolProp MATLAB MEX Wrapper

MATLAB MEX wrappers for [CoolProp v8.1.0](https://github.com/CoolProp/CoolProp), providing high-level and low-level thermophysical property interfaces. CoolProp is included as a git submodule and compiled together with the MEX files in a single build step.

## Features

- **PropsSI** - High-level interface for pure and pseudo-pure fluids
- **HAPropsSI** - High-level interface for humid air properties
- **AbstractState** - Low-level interface for advanced calculations (mixtures, derivatives, etc.)

## Repository Structure

```
CoolPropMEX/
├── CoolProp/          # CoolProp v8.1.0 (git submodule)
├── src/               # MEX C++ source files
│   ├── PropsSI.cpp
│   ├── HAPropsSI.cpp
│   └── AbstractStateMex.cpp
├── matlab/            # MATLAB files
│   ├── AbstractState.m
│   └── test_coolprop.m
├── CMakeLists.txt     # Builds CoolProp + MEX in one pass
└── .github/workflows/
    └── release.yml    # CI/CD: builds and releases on tag push
```

---

## Installation (Pre-built Binaries)

Download the latest release for your platform from the [Releases](../../releases) page:

| File | Platform |
|---|---|
| `CoolPropMEX-vX.Y.Z-windows.zip` | Windows 64-bit (`.mexw64`) |
| `CoolPropMEX-vX.Y.Z-linux.zip` | Linux 64-bit (`.mexa64`) |
| `CoolPropMEX-vX.Y.Z-macos.zip` | macOS (`.mexmaci64`) |

Each zip contains the three MEX files, the CoolProp shared library, and `AbstractState.m`. Unzip and add the folder to your MATLAB path:

```matlab
addpath('/path/to/unzipped/folder')
```

---

## Building from Source

### Prerequisites

- MATLAB R2021a or later
- CMake 3.15 or later
- A C++17-compatible compiler (MSVC 2019+, GCC 9+, Clang 11+)
- Python 3 (required by CoolProp's build system to generate headers)
- Internet access during configuration (CoolProp 8 fetches its dependencies via CPM.cmake)
- Git

### 1. Clone with submodules

```bash
git clone --recurse-submodules https://github.com/luzechao/CoolPropMEX.git
cd CoolPropMEX
```

If you already cloned without `--recurse-submodules`:

```bash
git submodule update --init --recursive
```

### 2. Build

```bash
mkdir build
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --config Release --parallel 2
```

> **Note on parallelism:** CoolProp 8 uses Eigen 5, whose template-heavy headers
> make each translation unit consume 3–5 GB of RAM during compilation. With
> unrestricted `--parallel` (one job per CPU core) machines with ≤ 16 GB RAM can
> run out of memory and kill the compiler. `--parallel 2` is a safe default;
> increase it only if you have ample RAM (≥ 32 GB).

### 3. Output

All compiled files are placed in `Release/` at the repo root:

| File | Description |
|---|---|
| `PropsSI.mex*` | Pure fluid properties MEX |
| `HAPropsSI.mex*` | Humid air properties MEX |
| `AbstractStateMex.mex*` | Low-level AbstractState MEX |
| `CoolProp.dll` / `libCoolProp.so` / `libCoolProp.dylib` | CoolProp shared library |
| `AbstractState.m` | MATLAB OOP wrapper class |

The `.mex*` extension is platform-specific: `.mexw64` (Windows), `.mexa64` (Linux), `.mexmaci64` (macOS).

### 4. Add to MATLAB path

```matlab
addpath('/path/to/CoolPropMEX/Release')
```

---

## Releases (CI/CD)

Releases are built automatically via GitHub Actions on every version tag push. **The tag must match the CoolProp submodule version** — e.g. if the `CoolProp/` submodule is pinned to v8.1.0, the tag must be `v8.1.0`. The workflow enforces this and fails immediately if they do not match.

### To release for a new CoolProp version

1. Update the submodule to the new CoolProp tag:
   ```bash
   cd CoolProp
   git fetch --depth 1 origin tag v8.1.0
   git checkout v8.1.0
   cd ..
   git add CoolProp
   git commit -m "update CoolProp submodule to v8.1.0"
   ```

2. Push the matching version tag:
   ```bash
   git tag v8.1.0
   git push origin main v8.1.0
   ```

The workflow builds Windows, Linux, and macOS artifacts in parallel, verifies the tag matches the submodule version, then publishes a GitHub Release with all three platform zips attached.

---

## PropsSI — Pure and Pseudo-Pure Fluid Properties

### Syntax

```matlab
result = PropsSI(Output, Name1, Prop1, Name2, Prop2, FluidName)
```

**Parameters:**
- `Output` (string): Output property (e.g., `'D'` for density, `'H'` for enthalpy)
- `Name1` (string): First input property name (e.g., `'T'`, `'P'`)
- `Prop1` (double): First input property value
- `Name2` (string): Second input property name
- `Prop2` (double): Second input property value
- `FluidName` (string): Fluid name (e.g., `'Water'`, `'Air'`, `'R134a'`)

**Returns:** `result` (double)

### Examples

```matlab
% Density of water at 300 K, 101325 Pa
rho = PropsSI('D', 'T', 300, 'P', 101325, 'Water')
% Returns: 996.56 kg/m³

% Enthalpy of R134a at 300 K, 101325 Pa
h = PropsSI('H', 'T', 300, 'P', 101325, 'R134a')
% Returns: 452080 J/kg

% Saturation temperature of water at 101325 Pa
T_sat = PropsSI('T', 'P', 101325, 'Q', 0, 'Water')
% Returns: 373.12 K

% Critical temperature of CO2
T_crit = PropsSI('Tcrit', 'P', 0, 'T', 0, 'CO2')
% Returns: 304.13 K
```

### Common Property Keys

**Input/Output:**
- `T` - Temperature [K]
- `P` - Pressure [Pa]
- `D` - Density [kg/m³]
- `H` - Enthalpy [J/kg]
- `S` - Entropy [J/kg/K]
- `Q` - Vapor quality [0–1]
- `U` - Internal energy [J/kg]

**Output only:**
- `Tcrit` - Critical temperature [K]
- `Pcrit` - Critical pressure [Pa]
- `C` - Speed of sound [m/s]
- `V` - Viscosity [Pa·s]
- `L` - Thermal conductivity [W/m/K]

For the full list see the [CoolProp documentation](http://www.coolprop.org/coolprop/HighLevelAPI.html#parameter-table).

---

## HAPropsSI — Humid Air Properties

### Syntax

```matlab
result = HAPropsSI(Output, Name1, Prop1, Name2, Prop2, Name3, Prop3)
```

### Humid Air Property Keys

- `T` - Dry bulb temperature [K]
- `P` - Pressure [Pa]
- `R` - Relative humidity [0–1]
- `B` - Wet bulb temperature [K]
- `D` - Dew point temperature [K]
- `W` - Humidity ratio [kg water/kg dry air]
- `H` - Enthalpy per kg dry air [J/kg]
- `S` - Entropy per kg dry air [J/kg/K]
- `V` - Specific volume [m³/kg dry air]

### Examples

```matlab
% Enthalpy of humid air at 25°C, 50% RH, 101325 Pa
h = HAPropsSI('H', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~50800 J/kg_dry_air

% Dew point at 25°C, 50% RH, 101325 Pa
T_dp = HAPropsSI('D', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~287.4 K (14.3°C)

% Humidity ratio at 25°C, 50% RH, 101325 Pa
W = HAPropsSI('W', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~0.0099 kg_water/kg_dry_air

% Wet bulb temperature at 25°C, 50% RH, 101325 Pa
T_wb = HAPropsSI('B', 'T', 298.15, 'R', 0.5, 'P', 101325)
% Returns: ~291.4 K (18.3°C)
```

---

## AbstractState — Low-Level Interface

Provides advanced functionality: mixture calculations, phase specification, partial derivatives.

### Using the OOP wrapper (recommended)

```matlab
% Create a state object
state = AbstractState('HEOS', 'Water');

% Update state at P = 101325 Pa, T = 300 K
state.update(AbstractState.PT_INPUTS, 101325, 300);

% Retrieve properties
rho  = state.rhomass()       % Mass density [kg/m³]
h    = state.hmass()         % Mass enthalpy [J/kg]
s    = state.smass()         % Mass entropy [J/kg/K]
cp   = state.cpmass()        % Isobaric heat capacity [J/kg/K]
visc = state.viscosity()     % Dynamic viscosity [Pa·s]
cond = state.conductivity()  % Thermal conductivity [W/m/K]

% Destructor frees the underlying C++ object automatically
clear state
```

### Common input pair constants

| Constant | Inputs |
|---|---|
| `PT_INPUTS` | Pressure [Pa], Temperature [K] |
| `DmassT_INPUTS` | Mass density [kg/m³], Temperature [K] |
| `HmassP_INPUTS` | Mass enthalpy [J/kg], Pressure [Pa] |
| `PSmass_INPUTS` | Pressure [Pa], Mass entropy [J/kg/K] |
| `PQ_INPUTS` | Pressure [Pa], Vapor quality [0–1] |
| `QT_INPUTS` | Vapor quality [0–1], Temperature [K] |

### Mixture example

```matlab
state = AbstractState('HEOS', 'Methane&Ethane');
state.set_fractions([0.5, 0.5]);  % 50% methane, 50% ethane (mole fractions)
state.update(AbstractState.PT_INPUTS, 101325, 300);
rho = state.rhomass()
h   = state.hmass()
```

### Low-level MEX interface (advanced)

```matlab
% Create state
handle = AbstractStateMex('create', 'HEOS', 'Water');

% Update state (17 = PT_INPUTS)
AbstractStateMex('update', handle, 17, 101325, 300);

% Get mass density (iDmass = 40)
rho = AbstractStateMex('keyed_output', handle, 40);

% Free state
AbstractStateMex('free', handle);
```

Available commands: `create`, `free`, `update`, `keyed_output`, `set_fractions`, `get_mole_fractions`, `specify_phase`, `unspecify_phase`, `backend_name`, `fluid_names`.

---

## Error Handling

The MEX functions throw MATLAB errors for invalid arguments or CoolProp exceptions:

```matlab
try
    rho = PropsSI('D', 'T', 300, 'P', 101325, 'InvalidFluid');
catch e
    fprintf('Error: %s\n', e.message)
end
```

---

## Troubleshooting

**MEX file not found**
- Add the `Release/` folder to your MATLAB path: `addpath('/path/to/Release')`

**Cannot load shared library**
- Ensure the CoolProp shared library (`CoolProp.dll` / `libCoolProp.so` / `libCoolProp.dylib`) is in the same folder as the MEX files

**Build fails — MATLAB not found**
- CMake uses `find_package(Matlab)`. Ensure MATLAB is installed and either on `PATH` or set `Matlab_ROOT_DIR`:
  ```bash
  cmake -S . -B build -DMatlab_ROOT_DIR="/usr/local/MATLAB/R2024a"
  ```

**Build fails — Python not found**
- CoolProp requires Python 3 to generate headers during configuration. Install Python 3 and ensure it is on `PATH`.

**Build fails — submodules missing**
- Run `git submodule update --init --recursive` to populate the `CoolProp/` submodule. (CoolProp 8 fetches its own dependencies via CPM.cmake at configure time, so an internet connection is required during `cmake` configuration.)

**macOS — "Invalid MEX-file ... code signature ... library load disallowed by system policy"**
- This happens because files downloaded through a browser get a `com.apple.quarantine` attribute, and the released binaries are only ad-hoc signed (not notarized with a paid Apple Developer ID). Gatekeeper blocks quarantined, non-notarized binaries from loading.
- Fix: remove the quarantine attribute and re-sign the files locally after unzipping:
  ```bash
  cd /path/to/unzipped/CoolPropMEX-macos
  xattr -dr com.apple.quarantine .
  codesign --force --deep --sign - *.mexmaca64 libCoolProp.dylib
  ```
- This is a one-time step per download. It's safe because you're signing the binaries yourself locally (ad-hoc signature), not bypassing verification of a binary from an untrusted source.

**macOS — "Library not loaded: @rpath/libMatlabEngine.dylib"**
- Fixed as of the current `CMakeLists.txt` (macOS builds now embed a portable `@loader_path` / `@executable_path`-relative `RPATH` instead of the build machine's absolute paths). If you still see this on a binary built before this fix, rebuild from source or download the latest release.

---

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

CoolProp is also MIT licensed. See [CoolProp/LICENSE](CoolProp/LICENSE).

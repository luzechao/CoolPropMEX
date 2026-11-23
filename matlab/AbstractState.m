classdef AbstractState < handle
    %ABSTRACTSTATE Wrapper class for CoolProp AbstractState MEX interface
    %   Provides an object-oriented interface to CoolProp's low-level API
    %
    %   Example:
    %       state = AbstractState('HEOS', 'Water');
    %       state.update(AbstractState.PT_INPUTS, 101325, 300);
    %       rho = state.rhomass();
    %       h = state.hmass();
    
    properties (Access = private)
        handle  % Handle to the C++ AbstractState object
    end
    
    properties (Constant)
        % Input pair constants (from DataStructures.h enum input_pairs)
        % NB: CoolProp 8 added mass-basis quality (Qmass) input pairs,
        %     which shifted the numeric values of all pairs after QT_INPUTS.
        INPUT_PAIR_INVALID = 0;
        QT_INPUTS = 1;             % Molar quality, Temperature [K]
        QmassT_INPUTS = 2;         % Mass-basis quality, Temperature [K]
        PQ_INPUTS = 3;             % Pressure [Pa], Molar quality
        PQmass_INPUTS = 4;         % Pressure [Pa], Mass-basis quality
        QSmolar_INPUTS = 5;        % Molar quality, Molar entropy [J/mol/K]
        QmassSmolar_INPUTS = 6;    % Mass-basis quality, Molar entropy [J/mol/K]
        QSmass_INPUTS = 7;         % Molar quality, Mass entropy [J/kg/K]
        QmassSmass_INPUTS = 8;     % Mass-basis quality, Mass entropy [J/kg/K]
        HmolarQ_INPUTS = 9;        % Molar enthalpy [J/mol], Molar quality
        HmolarQmass_INPUTS = 10;   % Molar enthalpy [J/mol], Mass-basis quality
        HmassQ_INPUTS = 11;        % Mass enthalpy [J/kg], Molar quality
        HmassQmass_INPUTS = 12;    % Mass enthalpy [J/kg], Mass-basis quality
        DmolarQ_INPUTS = 13;       % Molar density [mol/m^3], Molar quality
        DmolarQmass_INPUTS = 14;   % Molar density [mol/m^3], Mass-basis quality
        DmassQ_INPUTS = 15;        % Mass density [kg/m^3], Molar quality
        DmassQmass_INPUTS = 16;    % Mass density [kg/m^3], Mass-basis quality
        PT_INPUTS = 17;            % Pressure [Pa], Temperature [K]
        DmassT_INPUTS = 18;        % Mass density [kg/m^3], Temperature [K]
        DmolarT_INPUTS = 19;       % Molar density [mol/m^3], Temperature [K]
        HmolarT_INPUTS = 20;       % Molar enthalpy [J/mol], Temperature [K]
        HmassT_INPUTS = 21;        % Mass enthalpy [J/kg], Temperature [K]
        SmolarT_INPUTS = 22;       % Molar entropy [J/mol/K], Temperature [K]
        SmassT_INPUTS = 23;        % Mass entropy [J/kg/K], Temperature [K]
        TUmolar_INPUTS = 24;       % Temperature [K], Molar internal energy [J/mol]
        TUmass_INPUTS = 25;        % Temperature [K], Mass internal energy [J/kg]
        DmassP_INPUTS = 26;        % Mass density [kg/m^3], Pressure [Pa]
        DmolarP_INPUTS = 27;       % Molar density [mol/m^3], Pressure [Pa]
        HmassP_INPUTS = 28;        % Mass enthalpy [J/kg], Pressure [Pa]
        HmolarP_INPUTS = 29;       % Molar enthalpy [J/mol], Pressure [Pa]
        PSmass_INPUTS = 30;        % Pressure [Pa], Mass entropy [J/kg/K]
        PSmolar_INPUTS = 31;       % Pressure [Pa], Molar entropy [J/mol/K]
        PUmass_INPUTS = 32;        % Pressure [Pa], Mass internal energy [J/kg]
        PUmolar_INPUTS = 33;       % Pressure [Pa], Molar internal energy [J/mol]
        HmassSmass_INPUTS = 34;    % Mass enthalpy [J/kg], Mass entropy [J/kg/K]
        HmolarSmolar_INPUTS = 35;  % Molar enthalpy [J/mol], Molar entropy [J/mol/K]
        SmassUmass_INPUTS = 36;    % Mass entropy [J/kg/K], Mass internal energy [J/kg]
        SmolarUmolar_INPUTS = 37;  % Molar entropy [J/mol/K], Molar internal energy [J/mol]
        DmassHmass_INPUTS = 38;    % Mass density [kg/m^3], Mass enthalpy [J/kg]
        DmolarHmolar_INPUTS = 39;  % Molar density [mol/m^3], Molar enthalpy [J/mol]
        DmassSmass_INPUTS = 40;    % Mass density [kg/m^3], Mass entropy [J/kg/K]
        DmolarSmolar_INPUTS = 41;  % Molar density [mol/m^3], Molar entropy [J/mol/K]
        DmassUmass_INPUTS = 42;    % Mass density [kg/m^3], Mass internal energy [J/kg]
        DmolarUmolar_INPUTS = 43;  % Molar density [mol/m^3], Molar internal energy [J/mol]
        
        % Output parameter constants (from DataStructures.h enum parameters)
        INVALID_PARAMETER = 0;
        
        % General/Critical parameters
        igas_constant = 1;
        imolar_mass = 2;
        iacentric_factor = 3;
        irhomolar_reducing = 4;
        irhomolar_critical = 5;
        iT_reducing = 6;
        iT_critical = 7;
        irhomass_reducing = 8;
        irhomass_critical = 9;
        iP_critical = 10;
        iP_reducing = 11;
        iT_triple = 12;
        iP_triple = 13;
        iT_min = 14;
        iT_max = 15;
        iP_max = 16;
        iP_min = 17;
        idipole_moment = 18;
        iHmolar_formation = 19; % Standard molar enthalpy of formation [J/mol]
        
        % Bulk properties
        iT = 20;           % Temperature [K]
        iP = 21;           % Pressure [Pa]
        iQ = 22;           % Molar vapor quality [0-1] (alias for iQmolar)
        iQmass = 23;       % Mass-basis vapor quality [0-1] (new in CoolProp 8)
        iTau = 24;         % Reciprocal reduced temperature
        iDelta = 25;       % Reduced density
        
        % Molar specific properties
        iDmolar = 26;      % Molar density [mol/m^3]
        iHmolar = 27;      % Molar enthalpy [J/mol]
        iSmolar = 28;      % Molar entropy [J/mol/K]
        iCpmolar = 29;     % Molar cp [J/mol/K]
        iCp0molar = 30;    % Ideal gas molar cp [J/mol/K]
        iCvmolar = 31;     % Molar cv [J/mol/K]
        iUmolar = 32;      % Molar internal energy [J/mol]
        iGmolar = 33;      % Molar Gibbs energy [J/mol]
        iHelmholtzmolar = 34;  % Molar Helmholtz energy [J/mol]
        iHmolar_residual = 35;
        iSmolar_residual = 36;
        iGmolar_residual = 37;
        iHmolar_idealgas = 38;
        iSmolar_idealgas = 39;
        iUmolar_idealgas = 40;
        
        % Mass specific properties
        iDmass = 41;       % Mass density [kg/m^3]
        iHmass = 42;       % Mass enthalpy [J/kg]
        iSmass = 43;       % Mass entropy [J/kg/K]
        iCpmass = 44;      % Mass cp [J/kg/K]
        iCp0mass = 45;     % Ideal gas mass cp [J/kg/K]
        iCvmass = 46;      % Mass cv [J/kg/K]
        iUmass = 47;       % Mass internal energy [J/kg]
        iGmass = 48;       % Mass Gibbs energy [J/kg]
        iHelmholtzmass = 49;  % Mass Helmholtz energy [J/kg]
        iHmass_idealgas = 50;
        iSmass_idealgas = 51;
        iUmass_idealgas = 52;
        
        % Transport properties
        iviscosity = 53;   % Viscosity [Pa-s]
        iconductivity = 54;  % Thermal conductivity [W/m/K]
        isurface_tension = 55;  % Surface tension [N/m]
        iPrandtl = 56;     % Prandtl number
        
        % Derivative-based properties
        ispeed_sound = 57;  % Speed of sound [m/s]
        iisothermal_compressibility = 58;
        iisobaric_expansion_coefficient = 59;
        iisentropic_expansion_coefficient = 60;
        
        % Other properties
        ifundamental_derivative_of_gas_dynamics = 61;
        ialphar = 62;
        idalphar_dtau_constdelta = 63;
        idalphar_ddelta_consttau = 64;
        ialpha0 = 65;
        idalpha0_dtau_constdelta = 66;
        idalpha0_ddelta_consttau = 67;
        id2alpha0_ddelta2_consttau = 68;
        id3alpha0_ddelta3_consttau = 69;
        iBvirial = 70;     % Second virial coefficient
        iCvirial = 71;     % Third virial coefficient
        idBvirial_dT = 72;
        idCvirial_dT = 73;
        iZ = 74;           % Compressibility factor
        iPIP = 75;
        ifraction_min = 76;
        ifraction_max = 77;
        iT_freeze = 78;
        iGWP20 = 79;
        iGWP100 = 80;
        iGWP500 = 81;
        iFH = 82;
        iHH = 83;
        iPH = 84;
        iODP = 85;
        iPhase = 86;
    end
    
    methods
        function obj = AbstractState(backend, fluid)
            %ABSTRACTSTATE Construct an AbstractState object
            %   state = AbstractState(backend, fluid)
            %
            %   Inputs:
            %       backend - Backend name (e.g., 'HEOS', 'REFPROP')
            %       fluid   - Fluid name (e.g., 'Water', 'Air', 'R134a')
            %
            %   Example:
            %       state = AbstractState('HEOS', 'Water');
            
            obj.handle = AbstractStateMex('create', backend, fluid);
        end
        
        function delete(obj)
            %DELETE Destructor - frees the C++ object
            if ~isempty(obj.handle)
                AbstractStateMex('free', obj.handle);
                obj.handle = [];
            end
        end
        
        function update(obj, input_pair, value1, value2)
            %UPDATE Update the state
            %   state.update(input_pair, value1, value2)
            %
            %   Inputs:
            %       input_pair - Input pair constant (e.g., AbstractState.PT_INPUTS)
            %       value1     - First value
            %       value2     - Second value
            %
            %   Example:
            %       state.update(AbstractState.PT_INPUTS, 101325, 300);
            
            AbstractStateMex('update', obj.handle, input_pair, value1, value2);
        end
        
        function val = keyed_output(obj, param)
            %KEYED_OUTPUT Get output using parameter key
            %   val = state.keyed_output(param)
            %
            %   Input:
            %       param - Parameter constant (e.g., AbstractState.iT)
            %
            %   Example:
            %       T = state.keyed_output(AbstractState.iT);
            
            val = AbstractStateMex('keyed_output', obj.handle, param);
        end
        
        function set_fractions(obj, fractions)
            %SET_FRACTIONS Set mole fractions for mixtures
            %   state.set_fractions(fractions)
            %
            %   Input:
            %       fractions - Array of mole fractions
            %
            %   Example:
            %       state.set_fractions([0.5, 0.5]);
            
            AbstractStateMex('set_fractions', obj.handle, fractions);
        end
        
        function fracs = get_mole_fractions(obj)
            %GET_MOLE_FRACTIONS Get current mole fractions
            %   fracs = state.get_mole_fractions()
            %
            %   Example:
            %       fracs = state.get_mole_fractions();
            
            fracs = AbstractStateMex('get_mole_fractions', obj.handle);
        end
        
        function specify_phase(obj, phase)
            %SPECIFY_PHASE Force calculations in a specific phase
            %   state.specify_phase(phase)
            %
            %   Input:
            %       phase - Phase name (e.g., 'liquid', 'gas')
            %
            %   Example:
            %       state.specify_phase('liquid');
            
            AbstractStateMex('specify_phase', obj.handle, phase);
        end
        
        function unspecify_phase(obj)
            %UNSPECIFY_PHASE Remove phase specification
            %   state.unspecify_phase()
            
            AbstractStateMex('unspecify_phase', obj.handle);
        end
        
        function name = backend_name(obj)
            %BACKEND_NAME Get the backend name
            %   name = state.backend_name()
            
            name = AbstractStateMex('backend_name', obj.handle);
        end
        
        function names = fluid_names(obj)
            %FLUID_NAMES Get the fluid name(s)
            %   names = state.fluid_names()
            
            names = AbstractStateMex('fluid_names', obj.handle);
        end
        
        % Convenience methods for common properties
        function val = T(obj), val = obj.keyed_output(obj.iT); end
        function val = p(obj), val = obj.keyed_output(obj.iP); end
        function val = rhomolar(obj), val = obj.keyed_output(obj.iDmolar); end
        function val = rhomass(obj), val = obj.keyed_output(obj.iDmass); end
        function val = hmolar(obj), val = obj.keyed_output(obj.iHmolar); end
        function val = hmass(obj), val = obj.keyed_output(obj.iHmass); end
        function val = smolar(obj), val = obj.keyed_output(obj.iSmolar); end
        function val = smass(obj), val = obj.keyed_output(obj.iSmass); end
        function val = umolar(obj), val = obj.keyed_output(obj.iUmolar); end
        function val = umass(obj), val = obj.keyed_output(obj.iUmass); end
        function val = cpmolar(obj), val = obj.keyed_output(obj.iCpmolar); end
        function val = cpmass(obj), val = obj.keyed_output(obj.iCpmass); end
        function val = cvmolar(obj), val = obj.keyed_output(obj.iCvmolar); end
        function val = cvmass(obj), val = obj.keyed_output(obj.iCvmass); end
        function val = Q(obj), val = obj.keyed_output(obj.iQ); end
        function val = Qmass(obj), val = obj.keyed_output(obj.iQmass); end
        function val = viscosity(obj), val = obj.keyed_output(obj.iviscosity); end
        function val = conductivity(obj), val = obj.keyed_output(obj.iconductivity); end
        function val = speed_sound(obj), val = obj.keyed_output(obj.ispeed_sound); end
        function val = molar_mass(obj), val = obj.keyed_output(obj.imolar_mass); end
        function val = Tcrit(obj), val = obj.keyed_output(obj.iT_critical); end
        function val = pcrit(obj), val = obj.keyed_output(obj.iP_critical); end
    end
end

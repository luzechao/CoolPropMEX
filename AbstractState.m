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
        INPUT_PAIR_INVALID = 0;
        QT_INPUTS = 1;
        PQ_INPUTS = 2;
        QSmolar_INPUTS = 3;
        QSmass_INPUTS = 4;
        HmolarQ_INPUTS = 5;
        HmassQ_INPUTS = 6;
        DmolarQ_INPUTS = 7;
        DmassQ_INPUTS = 8;
        PT_INPUTS = 9;
        DmassT_INPUTS = 10;
        DmolarT_INPUTS = 11;
        HmolarT_INPUTS = 12;
        HmassT_INPUTS = 13;
        SmolarT_INPUTS = 14;
        SmassT_INPUTS = 15;
        TUmolar_INPUTS = 16;
        TUmass_INPUTS = 17;
        DmassP_INPUTS = 18;
        DmolarP_INPUTS = 19;
        HmassP_INPUTS = 20;
        HmolarP_INPUTS = 21;
        PSmass_INPUTS = 22;
        PSmolar_INPUTS = 23;
        PUmass_INPUTS = 24;
        PUmolar_INPUTS = 25;
        HmassSmass_INPUTS = 26;
        HmolarSmolar_INPUTS = 27;
        SmassUmass_INPUTS = 28;
        SmolarUmolar_INPUTS = 29;
        DmassHmass_INPUTS = 30;
        DmolarHmolar_INPUTS = 31;
        DmassSmass_INPUTS = 32;
        DmolarSmolar_INPUTS = 33;
        DmassUmass_INPUTS = 34;
        DmolarUmolar_INPUTS = 35;
        
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
        
        % Bulk properties
        iT = 19;           % Temperature [K]
        iP = 20;           % Pressure [Pa]
        iQ = 21;           % Quality [0-1]
        iTau = 22;         % Reciprocal reduced temperature
        iDelta = 23;       % Reduced density
        
        % Molar specific properties
        iDmolar = 24;      % Molar density [mol/m^3]
        iHmolar = 25;      % Molar enthalpy [J/mol]
        iSmolar = 26;      % Molar entropy [J/mol/K]
        iCpmolar = 27;     % Molar cp [J/mol/K]
        iCp0molar = 28;    % Ideal gas molar cp [J/mol/K]
        iCvmolar = 29;     % Molar cv [J/mol/K]
        iUmolar = 30;      % Molar internal energy [J/mol]
        iGmolar = 31;      % Molar Gibbs energy [J/mol]
        iHelmholtzmolar = 32;  % Molar Helmholtz energy [J/mol]
        iHmolar_residual = 33;
        iSmolar_residual = 34;
        iGmolar_residual = 35;
        iHmolar_idealgas = 36;
        iSmolar_idealgas = 37;
        iUmolar_idealgas = 38;
        
        % Mass specific properties
        iDmass = 39;       % Mass density [kg/m^3]
        iHmass = 40;       % Mass enthalpy [J/kg]
        iSmass = 41;       % Mass entropy [J/kg/K]
        iCpmass = 42;      % Mass cp [J/kg/K]
        iCp0mass = 43;     % Ideal gas mass cp [J/kg/K]
        iCvmass = 44;      % Mass cv [J/kg/K]
        iUmass = 45;       % Mass internal energy [J/kg]
        iGmass = 46;       % Mass Gibbs energy [J/kg]
        iHelmholtzmass = 47;  % Mass Helmholtz energy [J/kg]
        iHmass_idealgas = 48;
        iSmass_idealgas = 49;
        iUmass_idealgas = 50;
        
        % Transport properties
        iviscosity = 51;   % Viscosity [Pa-s]
        iconductivity = 52;  % Thermal conductivity [W/m/K]
        isurface_tension = 53;  % Surface tension [N/m]
        iPrandtl = 54;     % Prandtl number
        
        % Derivative-based properties
        ispeed_sound = 55;  % Speed of sound [m/s]
        iisothermal_compressibility = 56;
        iisobaric_expansion_coefficient = 57;
        iisentropic_expansion_coefficient = 58;
        
        % Other properties
        ifundamental_derivative_of_gas_dynamics = 59;
        ialphar = 60;
        idalphar_dtau_constdelta = 61;
        idalphar_ddelta_consttau = 62;
        ialpha0 = 63;
        idalpha0_dtau_constdelta = 64;
        idalpha0_ddelta_consttau = 65;
        id2alpha0_ddelta2_consttau = 66;
        id3alpha0_ddelta3_consttau = 67;
        iBvirial = 68;     % Second virial coefficient
        iCvirial = 69;     % Third virial coefficient
        idBvirial_dT = 70;
        idCvirial_dT = 71;
        iZ = 72;           % Compressibility factor
        iPIP = 73;
        ifraction_min = 74;
        ifraction_max = 75;
        iT_freeze = 76;
        iGWP20 = 77;
        iGWP100 = 78;
        iGWP500 = 79;
        iFH = 80;
        iHH = 81;
        iPH = 82;
        iODP = 83;
        iPhase = 84;
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
        function val = viscosity(obj), val = obj.keyed_output(obj.iviscosity); end
        function val = conductivity(obj), val = obj.keyed_output(obj.iconductivity); end
        function val = speed_sound(obj), val = obj.keyed_output(obj.ispeed_sound); end
        function val = molar_mass(obj), val = obj.keyed_output(obj.imolar_mass); end
        function val = Tcrit(obj), val = obj.keyed_output(obj.iT_critical); end
        function val = pcrit(obj), val = obj.keyed_output(obj.iP_critical); end
    end
end

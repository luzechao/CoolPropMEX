#include "mex.h"
#include <map>
#include <string>
#include <cstring>

extern "C" {
#include "CoolPropLib.h"
}

// Global storage for AbstractState handles
static std::map<long, bool> activeHandles;
static long nextId = 1;

// Helper function to convert MATLAB string or char array to C string
char* getString(const mxArray *arr) {
    if (mxIsChar(arr)) {
        // Traditional char array
        return mxArrayToString(arr);
    } else if (mxIsClass(arr, "string")) {
        // MATLAB string (R2016b+)
        mxArray *charArray = mxGetProperty(arr, 0, "StringData");
        if (charArray == NULL) {
            // Try alternative method for string conversion
            mxArray *lhs[1];
            mxArray *rhs[1];
            rhs[0] = const_cast<mxArray*>(arr);
            if (mexCallMATLAB(1, lhs, 1, rhs, "char") == 0) {
                return mxArrayToString(lhs[0]);
            }
        }
    }
    return NULL;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check minimum number of arguments
    if (nrhs < 1) {
        mexErrMsgIdAndTxt("CoolProp:AbstractState:nrhs",
                          "At least one input required (command).");
    }
    
    // Get command string
    if (!mxIsChar(prhs[0]) && !mxIsClass(prhs[0], "string")) {
        mexErrMsgIdAndTxt("CoolProp:AbstractState:notString",
                          "First input must be a command string.");
    }
    
    char *command = getString(prhs[0]);
    if (command == NULL) {
        mexErrMsgIdAndTxt("CoolProp:AbstractState:stringConversion",
                          "Failed to convert first input to string.");
    }
    std::string cmd(command);
    mxFree(command);
    
    // Error handling variables
    long errcode = 0;
    char message_buffer[1000];
    const long buffer_length = 1000;
    
    try {
        // CREATE command: AbstractState('create', backend, fluid)
        if (cmd == "create") {
            if (nrhs != 3 || nlhs != 1) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:create",
                                  "Usage: handle = AbstractState('create', backend, fluid)");
            }
            
            char *backend = getString(prhs[1]);
            char *fluid = getString(prhs[2]);
            
            if (backend == NULL || fluid == NULL) {
                if (backend) mxFree(backend);
                if (fluid) mxFree(fluid);
                mexErrMsgIdAndTxt("CoolProp:AbstractState:stringConversion",
                                  "Failed to convert backend or fluid to string.");
            }
            
            long handle = AbstractState_factory(backend, fluid, &errcode, message_buffer, buffer_length);
            
            mxFree(backend);
            mxFree(fluid);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
            
            activeHandles[handle] = true;
            plhs[0] = mxCreateDoubleScalar((double)handle);
        }
        
        // FREE command: AbstractState('free', handle)
        else if (cmd == "free") {
            if (nrhs != 2) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:free",
                                  "Usage: AbstractState('free', handle)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid or already freed handle.");
            }
            
            AbstractState_free(handle, &errcode, message_buffer, buffer_length);
            activeHandles.erase(handle);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
        }
        
        // UPDATE command: AbstractState('update', handle, input_pair, value1, value2)
        else if (cmd == "update") {
            if (nrhs != 5) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:update",
                                  "Usage: AbstractState('update', handle, input_pair, value1, value2)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            long input_pair = (long)mxGetScalar(prhs[2]);
            double value1 = mxGetScalar(prhs[3]);
            double value2 = mxGetScalar(prhs[4]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            AbstractState_update(handle, input_pair, value1, value2, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
        }
        
        // KEYED_OUTPUT command: value = AbstractState('keyed_output', handle, param)
        else if (cmd == "keyed_output") {
            if (nrhs != 3 || nlhs != 1) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:keyed_output",
                                  "Usage: value = AbstractState('keyed_output', handle, param)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            long param = (long)mxGetScalar(prhs[2]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            double result = AbstractState_keyed_output(handle, param, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
            
            plhs[0] = mxCreateDoubleScalar(result);
        }
        
        // SET_FRACTIONS command: AbstractState('set_fractions', handle, fractions)
        else if (cmd == "set_fractions") {
            if (nrhs != 3) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:set_fractions",
                                  "Usage: AbstractState('set_fractions', handle, fractions)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            if (!mxIsDouble(prhs[2])) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:notDouble",
                                  "Fractions must be a double array.");
            }
            
            double *fractions = mxGetPr(prhs[2]);
            long N = (long)mxGetNumberOfElements(prhs[2]);
            
            AbstractState_set_fractions(handle, fractions, N, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
        }
        
        // GET_MOLE_FRACTIONS command: fractions = AbstractState('get_mole_fractions', handle)
        else if (cmd == "get_mole_fractions") {
            if (nrhs != 2 || nlhs != 1) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:get_mole_fractions",
                                  "Usage: fractions = AbstractState('get_mole_fractions', handle)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            double fractions[20];  // Max 20 components
            long N = 0;
            
            AbstractState_get_mole_fractions(handle, fractions, 20, &N, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
            
            plhs[0] = mxCreateDoubleMatrix(1, N, mxREAL);
            double *output = mxGetPr(plhs[0]);
            for (long i = 0; i < N; i++) {
                output[i] = fractions[i];
            }
        }
        
        // SPECIFY_PHASE command: AbstractState('specify_phase', handle, phase)
        else if (cmd == "specify_phase") {
            if (nrhs != 3) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:specify_phase",
                                  "Usage: AbstractState('specify_phase', handle, phase)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            char *phase = getString(prhs[2]);
            
            if (phase == NULL) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:stringConversion",
                                  "Failed to convert phase to string.");
            }
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mxFree(phase);
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            AbstractState_specify_phase(handle, phase, &errcode, message_buffer, buffer_length);
            mxFree(phase);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
        }
        
        // UNSPECIFY_PHASE command: AbstractState('unspecify_phase', handle)
        else if (cmd == "unspecify_phase") {
            if (nrhs != 2) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:unspecify_phase",
                                  "Usage: AbstractState('unspecify_phase', handle)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            AbstractState_unspecify_phase(handle, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
        }
        
        // BACKEND_NAME command: name = AbstractState('backend_name', handle)
        else if (cmd == "backend_name") {
            if (nrhs != 2 || nlhs != 1) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:backend_name",
                                  "Usage: name = AbstractState('backend_name', handle)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            char backend[100];
            AbstractState_backend_name(handle, backend, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
            
            plhs[0] = mxCreateString(backend);
        }
        
        // FLUID_NAMES command: names = AbstractState('fluid_names', handle)
        else if (cmd == "fluid_names") {
            if (nrhs != 2 || nlhs != 1) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:fluid_names",
                                  "Usage: names = AbstractState('fluid_names', handle)");
            }
            
            long handle = (long)mxGetScalar(prhs[1]);
            
            if (activeHandles.find(handle) == activeHandles.end()) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:invalidHandle",
                                  "Invalid handle.");
            }
            
            char fluids[1000];
            AbstractState_fluid_names(handle, fluids, &errcode, message_buffer, buffer_length);
            
            if (errcode != 0) {
                mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", message_buffer);
            }
            
            plhs[0] = mxCreateString(fluids);
        }
        
        else {
            mexErrMsgIdAndTxt("CoolProp:AbstractState:unknownCommand",
                              "Unknown command. Valid commands: create, free, update, keyed_output, "
                              "set_fractions, get_mole_fractions, specify_phase, unspecify_phase, "
                              "backend_name, fluid_names");
        }
        
    } catch (const std::exception& e) {
        mexErrMsgIdAndTxt("CoolProp:AbstractState:exception", e.what());
    }
}

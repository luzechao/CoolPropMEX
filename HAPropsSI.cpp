#include "mex.h"

extern "C" {
#include "CoolPropLib.h"
}

#include <string>
#include <cmath>

// Helper function to convert MATLAB string or char array to C string
char* getString(const mxArray *arr) {
    if (mxIsChar(arr)) {
        // Traditional char array
        return mxArrayToString(arr);
    } else if (mxIsClass(arr, "string")) {
        // MATLAB string (R2016b+)
        mxArray *lhs[1];
        mxArray *rhs[1];
        rhs[0] = const_cast<mxArray*>(arr);
        if (mexCallMATLAB(1, lhs, 1, rhs, "char") == 0) {
            return mxArrayToString(lhs[0]);
        }
    }
    return NULL;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check for proper number of arguments
    if (nrhs != 7) {
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:nrhs",
                          "Seven inputs required: Output, Name1, Prop1, Name2, Prop2, Name3, Prop3");
    }
    
    // Check that inputs 1, 2, 4, 6 are strings or char arrays
    if ((!mxIsChar(prhs[0]) && !mxIsClass(prhs[0], "string")) ||
        (!mxIsChar(prhs[1]) && !mxIsClass(prhs[1], "string")) ||
        (!mxIsChar(prhs[3]) && !mxIsClass(prhs[3], "string")) ||
        (!mxIsChar(prhs[5]) && !mxIsClass(prhs[5], "string"))) {
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:notString",
                          "Inputs 1, 2, 4, and 6 must be strings.");
    }
    
    // Check that inputs 3, 5, 7 are real scalar doubles
    if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || 
        !mxIsDouble(prhs[4]) || mxIsComplex(prhs[4]) ||
        !mxIsDouble(prhs[6]) || mxIsComplex(prhs[6])) {
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:notScalar",
                          "Inputs 3, 5, and 7 must be real scalar doubles.");
    }
    
    // Get string inputs
    char *Output = getString(prhs[0]);
    char *Name1 = getString(prhs[1]);
    char *Name2 = getString(prhs[3]);
    char *Name3 = getString(prhs[5]);
    
    if (Output == NULL || Name1 == NULL || Name2 == NULL || Name3 == NULL) {
        if (Output) mxFree(Output);
        if (Name1) mxFree(Name1);
        if (Name2) mxFree(Name2);
        if (Name3) mxFree(Name3);
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:stringConversion",
                          "Failed to convert one or more string inputs.");
    }
    
    // Get double inputs
    double Prop1 = mxGetScalar(prhs[2]);
    double Prop2 = mxGetScalar(prhs[4]);
    double Prop3 = mxGetScalar(prhs[6]);
    
    // Call CoolProp function
    double result = HAPropsSI(Output, Name1, Prop1, Name2, Prop2, Name3, Prop3);
    
    // Check for error (HAPropsSI returns a huge value on error: > 1e30 or < -1e30 or NaN or Inf)
    if (!std::isfinite(result) || result > 1e30 || result < -1e30) {
        // Get the error message from CoolProp
        char errstr[10000];
        get_global_param_string("errstring", errstr, 10000);
        
        mxFree(Output);
        mxFree(Name1);
        mxFree(Name2);
        mxFree(Name3);
        
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:error", errstr);
    }
    
    // Create output
    plhs[0] = mxCreateDoubleScalar(result);
    
    // Free memory
    mxFree(Output);
    mxFree(Name1);
    mxFree(Name2);
    mxFree(Name3);
}

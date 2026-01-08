#include "mex.h"

extern "C" {
#include "CoolPropLib.h"
}

#include <string>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check for proper number of arguments
    if (nrhs != 7) {
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:nrhs",
                          "Seven inputs required: Output, Name1, Prop1, Name2, Prop2, Name3, Prop3");
    }
    
    // Check that inputs 1, 2, 4, 6 are strings
    if (!mxIsChar(prhs[0]) || !mxIsChar(prhs[1]) || !mxIsChar(prhs[3]) || !mxIsChar(prhs[5])) {
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
    char *Output = mxArrayToString(prhs[0]);
    char *Name1 = mxArrayToString(prhs[1]);
    char *Name2 = mxArrayToString(prhs[3]);
    char *Name3 = mxArrayToString(prhs[5]);
    
    // Get double inputs
    double Prop1 = mxGetScalar(prhs[2]);
    double Prop2 = mxGetScalar(prhs[4]);
    double Prop3 = mxGetScalar(prhs[6]);
    
    // Call CoolProp function
    double result = HAPropsSI(Output, Name1, Prop1, Name2, Prop2, Name3, Prop3);
    
    // Check for error (HAPropsSI returns a huge value on error)
    if (result > 1e30) {
        mxFree(Output);
        mxFree(Name1);
        mxFree(Name2);
        mxFree(Name3);
        mexErrMsgIdAndTxt("CoolProp:HAPropsSI:exception",
                          "HAPropsSI returned an error. Check input parameters.");
    }
    
    // Create output
    plhs[0] = mxCreateDoubleScalar(result);
    
    // Free memory
    mxFree(Output);
    mxFree(Name1);
    mxFree(Name2);
    mxFree(Name3);
}

#include "mex.h"

extern "C" {
#include "CoolPropLib.h"
}

#include <string>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    // Check for proper number of arguments
    if (nrhs != 6) {
        mexErrMsgIdAndTxt("CoolProp:PropsSI:nrhs",
                          "Six inputs required: Output, Name1, Prop1, Name2, Prop2, FluidName");
    }
    // if (nlhs != 1) {
    //     mexErrMsgIdAndTxt("CoolProp:PropsSI:nlhs",
    //                       "One output required.");
    // }
    
    // Check that all inputs are strings except for Prop1 and Prop2
    if (!mxIsChar(prhs[0]) || !mxIsChar(prhs[1]) || !mxIsChar(prhs[3]) || !mxIsChar(prhs[5])) {
        mexErrMsgIdAndTxt("CoolProp:PropsSI:notString",
                          "Inputs 1, 2, 4, and 6 must be strings.");
    }
    
    if (!mxIsDouble(prhs[2]) || mxIsComplex(prhs[2]) || !mxIsDouble(prhs[4]) || mxIsComplex(prhs[4])) {
        mexErrMsgIdAndTxt("CoolProp:PropsSI:notScalar",
                          "Inputs 3 and 5 must be real scalar doubles.");
    }
    
    // Get string inputs
    char *Output = mxArrayToString(prhs[0]);
    char *Name1 = mxArrayToString(prhs[1]);
    char *Name2 = mxArrayToString(prhs[3]);
    char *FluidName = mxArrayToString(prhs[5]);
    
    // Get double inputs
    double Prop1 = mxGetScalar(prhs[2]);
    double Prop2 = mxGetScalar(prhs[4]);
    
    // Call CoolProp function
    double result;
    try {
        result = PropsSI(Output, Name1, Prop1, Name2, Prop2, FluidName);
    } catch (const std::exception& e) {
        mxFree(Output);
        mxFree(Name1);
        mxFree(Name2);
        mxFree(FluidName);
        mexErrMsgIdAndTxt("CoolProp:PropsSI:exception", e.what());
    }
    
    // Create output
    plhs[0] = mxCreateDoubleScalar(result);
    
    // Free memory
    mxFree(Output);
    mxFree(Name1);
    mxFree(Name2);
    mxFree(FluidName);
}

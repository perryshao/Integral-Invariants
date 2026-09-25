/**************************************************************************
**       Title: Mex Interface of Dtw simulation
**    $RCSfile: dtwCalcPath.cpp,v $
**   $Revision: 2.4 $$Name:  $
**       $Date: 2002/06/28 21:11:09 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**-------------------------------------------------------------------------
**
**  $Log: dtwCalcPath.cpp,v $
**  Revision 2.4  2002/06/28 21:11:09  bahlmann
**  *** empty log message ***
**
**  Revision 2.3  2002/06/16 11:29:52  bahlmann
**  *** empty log message ***
**
**  Revision 2.2  2002/03/08 15:04:43  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/11/27 09:50:01  bahlmann
**  *** empty log message ***
**
**  Revision 2.6  2001/08/13 13:46:26  bahlmann
**  *** empty log message ***
**************************************************************************/
#include <iostream>
#include <mex.h>
#include <matrix.h>
#include <blitz/array.h>
#include <libhwr/hwr.hpp>
#include "mxDtw.hpp"
#include "mxStatistic.hpp"


/*======================================================================*/
/*! 
 *    Defines interface to dtw_distance and copies values
 *
 *   \param nlhs      number left hand side arguments
 *   \param plhs[]    left hand side arguments
 *   \param nrhs      number right hand side arguments
 *   \param prhs[]    right hand side arguments
 */
/*======================================================================*/
void mexFunction (int nlhs, 
                  mxArray *plhs[],
                  int nrhs, 
                  const mxArray *prhs[])
{

   //--------------------------------------------------------
   // Convert input data
   //--------------------------------------------------------
   Dtw<double> dtw;
   dtwConvert( prhs[0],dtw );

   int R = mxGetM( prhs[1] );
   int T = mxGetN( prhs[1] );
   Array<double,2> warpPathMatDouble( mxGetPr( prhs[1] ),
                                shape(R,T), 
                                neverDeleteData,
                                ColumnMajorArray<2>() );

   Array<int,2> warpPathMat = cast( warpPathMatDouble, int() );

   //--------------------------------------------------------
   // Convert output data
   //--------------------------------------------------------
   const int dims[]= {2, R+T};
   plhs[0] = 
     mxCreateNumericArray( 2, dims, mxINT32_CLASS, mxREAL );
   Array<int,2> warpPathSeq( (int*) mxGetPr( plhs[0] ),
                             shape(2,R+T), 
                             neverDeleteData,
                             ColumnMajorArray<2>() );

   dtw.calcPath( warpPathMat, warpPathSeq );

   cout << "warpPathSeq = " << warpPathSeq << endl;
  
  
} 


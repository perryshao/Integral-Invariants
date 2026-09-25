/**************************************************************************
**       Title: Demo of mex Dtw
**    $RCSfile: dtwExportHdf5.cpp,v $
**   $Revision: 2.9 $$Name:  $
**       $Date: 2002/06/28 21:11:09 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: dtwExportHdf5.cpp,v $
**  Revision 2.9  2002/06/28 21:11:09  bahlmann
**  *** empty log message ***
**
**  Revision 2.8  2002/06/16 11:29:52  bahlmann
**  *** empty log message ***
**
**  Revision 2.7  2002/03/08 15:04:43  bahlmann
**  *** empty log message ***
**
**  Revision 2.6  2001/08/13 13:46:26  bahlmann
**  *** empty log message ***
**
**  Revision 2.5  2001/06/12 09:29:47  bahlmann
**  *** empty log message ***
**
**  Revision 2.4  2001/05/29 12:23:15  bahlmann
**  *** empty log message ***
**
**  Revision 2.3  2001/05/22 09:05:36  bahlmann
**  *** empty log message ***
**
**  Revision 2.2  2001/05/21 14:26:54  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/05/04 17:28:21  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/05/02 09:55:48  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/04/25 07:46:13  bahlmann
**  *** empty log message ***
**
**  Revision 1.2  2001/04/12 15:43:54  bahlmann
**  *** empty log message ***
**
**  Revision 1.1  2001/04/12 08:26:23  bahlmann
**  *** empty log message ***
**
**************************************************************************/
#include <iostream>
#include <mex.h>
#include <hwr.hpp>
#include "mxDtw.hpp"

/*======================================================================*/
/*! 
 *    Computes Dynamic Time Warping distance
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

   //
   // Convert input data
   //
   Dtw<double> dtw;
   dtwConvert( prhs[0], dtw );
  
   int bufLen = (mxGetM(prhs[1]) * mxGetN(prhs[1])) + 1;
   char* fileName = (char*) mxCalloc( bufLen, sizeof(char) );
   mxGetString( prhs[1], fileName, bufLen );
  
   //
   // Convert output data
   //
   plhs[0] = mxCreateDoubleMatrix( 1,1,mxREAL );
   double* status = mxGetPr( plhs[0] );
  
   //
   // Function call:
   //
   *status = (double) dtw.exportHdf5( fileName );

//  *status = (double) dtw.importHdf5( fileName );
  
}

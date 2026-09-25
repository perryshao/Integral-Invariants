/**************************************************************************
**       Title: Demo of mex Dtw
**    $RCSfile: dtwDistBeamSearch.cpp,v $
**   $Revision: 2.1 $$Name:  $
**       $Date: 2002/11/18 18:48:38 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: dtwDistBeamSearch.cpp,v $
**  Revision 2.1  2002/11/18 18:48:38  bahlmann
**  *** empty log message ***
**
**  Revision 2.14  2002/06/28 21:11:09  bahlmann
**************************************************************************/
#include <iostream>
#include <mex.h>
#include <blitz/array.h>
#include <hwr.hpp>
#include "mxStatistic.hpp"
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
   vector<int> idxRef(2);
   double* idxRefTmp; 
   idxRefTmp = mxGetPr(prhs[2]);
   idxRef[0] = ( (int) idxRefTmp[0] ) - 1;
   idxRef[1] = ( (int) idxRefTmp[1] ) - 1;
  
   Dtw<double> dtw;
   dtwConvert( prhs[0],dtw );

   Statistic<double> statistic;
   statisticConvert( prhs[1], statistic );
/*  
    cout << "aPriori" << statistic.getAPriori() << endl;
    cout << "mean"  << statistic.getMean() << endl;
    cout << "weight" << statistic.getWeight() << endl;
    cout << "biasTransitionTransition" << statistic.getBiasTransitionTransition() << endl;
    cout << "modulo2Pi" << statistic.getModulo2Pi() << endl;
*/
   //
   // Convert output data
   //

   vector<vector<Statistic<double> > > refStats;
   refStats = dtw.getReferenceStatistic();
   int R = refStats[idxRef[0]][idxRef[1]].getNbSamples();
   int T = statistic.getNbSamples();
   const int dims[]= {R, T};
   plhs[0] = 
     mxCreateNumericArray( 2, dims, mxINT32_CLASS, mxREAL );
   plhs[1] = mxCreateDoubleMatrix( R+1,T+1,mxREAL );
   plhs[2] = mxCreateDoubleMatrix( R,T,mxREAL );
   Array<int,2> warpPathMat( (int*) mxGetData( plhs[0] ),
                             shape(R,T), 
                             neverDeleteData,
                             ColumnMajorArray<2>() );
   Array<double,2> warpMat( mxGetPr( plhs[1] ),
                            shape(R+1,T+1), 
                            neverDeleteData,
                            ColumnMajorArray<2>());
   Array<double,2> localDistMat( mxGetPr( plhs[2] ),
                                 shape(R,T), 
                                 neverDeleteData,
                                 ColumnMajorArray<2>() );
//  return;
  
   //
   // Function call:
   //
   dtw.dtwDistBeamSearch( 
      statistic, 
      idxRef, 
      warpMat, 
      warpPathMat, 
      localDistMat
      );
//  cout << "warpMat: " << warpMat << "warpPath:" << warpPathMat;

}

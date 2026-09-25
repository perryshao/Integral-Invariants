/**************************************************************************
**       Title: Mex Interface of Dtw simulation
**    $RCSfile: dtwSimulate.cpp,v $
**   $Revision: 2.18 $$Name:  $
**       $Date: 2002/11/18 18:48:38 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: dtwSimulate.cpp,v $
**  Revision 2.18  2002/11/18 18:48:38  bahlmann
**  *** empty log message ***
**
**************************************************************************/

#include <iostream>
#include <algorithm>
#include <mex.h>
#include <blitz/array.h>
#include <hwr.hpp>
#include "mxDtw.hpp"
#include "mxStatistic.hpp"

/*======================================================================*/
/*! 
 *    Parses Arguments to function call
 *
 *   \param nbArgsLeft
 *   \param argsLeft
 *   \param nbArgsRight
 *   \param argsRight
 */
/*======================================================================*/
int parseArgs( int nbArgsLeft,  
               mxArray *argsLeft[],
               int nbArgsRight, 
               const mxArray *argsRight[] )
{
 
   if (nbArgsRight < 2)
       mexErrMsgTxt("Minimum two inputs required.");

   if (!mxIsStruct(argsRight[0]))
       mexErrMsgTxt("First argument must be a DTW object.");

   if (!mxIsStruct(argsRight[1])) 
       mexErrMsgTxt("Second argument must be a Statistic object.");

   if (nbArgsRight > 2)  {
      if (!mxIsNumeric(argsRight[2])) 
          mexErrMsgTxt("Third argument must be a numeric value.");
   }
  
   return(0);
}

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

   mxArray            *mxDtw;
   mxArray            *mxTestStatistic;
   mxArray            *mxRefIdx;
   mxArray            *mxTmpWarpPathMat;
   mxArray            *mxTmpWarpPathSeq;
   mxArray            *mxTmpWarpMat;
   mxArray            *mxTmpLocalDistMat;
   mxArray            *mxIdxRefs;
   int                subs[2];
  
   double startTime = get_runtime();

   //--------------------------------------------------------
   // Parse arguments 
   //--------------------------------------------------------
   int errorCode = parseArgs(nlhs, plhs, nrhs, prhs);

   //--------------------------------------------------------
   // Convert input data
   //--------------------------------------------------------
   // Dtw:
   Dtw<double> dtw;
   dtwConvert( prhs[0],dtw );

   // Statistic:
   Statistic<double> statistic;
   statisticConvert( prhs[1], statistic );

   // Indices to References:
   int nbIdxRefs;
   int nbIdxRefsOut;
   if ( nrhs < 3 ) {
      mxIdxRefs = mxCreateDoubleMatrix( 2,0, mxREAL );
      nbIdxRefs = mxGetN( mxIdxRefs );
      nbIdxRefsOut = dtw.getNbModel();
   } else {
      mxIdxRefs = (mxArray*) prhs[2];
      nbIdxRefs = mxGetN( mxIdxRefs );
      nbIdxRefsOut = nbIdxRefs;
   }

   Array<double,2> idxRefsDouble( mxGetPr( mxIdxRefs ),
                         shape(2,nbIdxRefs), 
                         duplicateData,
                         ColumnMajorArray<2>() );
   int dummy;
   Array<int,2> idxRefs = cast( idxRefsDouble, dummy );

   idxRefs = idxRefs - 1;
      
   //--------------------------------------------------------
   // Convert output data
   //--------------------------------------------------------
   int nbClass = dtw.getNbClass(); 
   vector<vector<Array<int,2> > >     warpPathMats(nbClass);
   vector<vector<Array<int,2> > >     warpPathSeqs(nbClass);
   vector<vector<Array<double,2> > >  warpMats(nbClass);
   vector<vector<Array<double,2> > >  localDistMats(nbClass);

   int nbModel = dtw.getNbModel();
   vector<vector<Statistic<double> > > refStats;
   refStats = dtw.getReferenceStatistic();
   int T = statistic.getNbSamples();

   //
   // Allocate distances:
   //
   plhs[0] = mxCreateDoubleMatrix( 1, nbIdxRefsOut, mxREAL );
   Array<double,1> distances( mxGetPr( plhs[0] ),
                              shape(nbIdxRefsOut), 
                              neverDeleteData );

   //
   // Allocate labels:
   //
   Array<string,1> labels( nbIdxRefsOut );

   vector<int> nbModels;
   for( int idxClass = 0; idxClass < nbClass; ++idxClass ) {
      nbModels.push_back(dtw.getNbModel( idxClass ));
   }
   int maxNbModels = *max_element( nbModels.begin(),nbModels.end() );

   //
   // Allocate warpPathMat, warpPathSeq and warpMat
   //
   plhs[1] = mxCreateCellMatrix( nbClass, maxNbModels );
   plhs[2] = mxCreateCellMatrix( nbClass, maxNbModels );
   plhs[3] = mxCreateCellMatrix( nbClass, maxNbModels );
   plhs[4] = mxCreateCellMatrix( nbClass, maxNbModels );

   //
   // Allocate idxMin:
   //
   const int dims[]= {2, 1};
   plhs[5] = 
     mxCreateNumericArray( 2, dims, mxINT32_CLASS, mxREAL );
   Array<int,1>  idxMin(
             (int*) mxGetPr( plhs[5] ), 
             shape(2), 
             neverDeleteData,
             ColumnMajorArray<1>() );
  
   //
   // Allocate distMin:
   //
   plhs[6] = mxCreateDoubleMatrix( 1, 1, mxREAL );
   double* distMin;
   distMin = mxGetPr( plhs[5] );
      
   //
   // Allocate time:
   //
   plhs[7] = mxCreateDoubleMatrix( 1, nbIdxRefsOut, mxREAL );
   Array<double,1> timePerformance( mxGetPr( plhs[7] ),
                                    shape(nbIdxRefsOut), 
                                    neverDeleteData );

   //
   // Allocate conversion time overhead:
   //
   plhs[8] = mxCreateDoubleMatrix( 1, 1, mxREAL );
   double* timePerformanceConversionOverhead;
   timePerformanceConversionOverhead = mxGetPr( plhs[8] );
      
   //
   // Allocate memory for each idxRef:
   //
   for( int idxClass = 0; idxClass < nbClass; ++idxClass ) {

      warpPathMats[idxClass].resize(dtw.getNbModel(idxClass));
      warpPathSeqs[idxClass].resize(dtw.getNbModel(idxClass));
      warpMats[idxClass].resize(dtw.getNbModel(idxClass));
      localDistMats[idxClass].resize(dtw.getNbModel(idxClass));

      int nbModel = dtw.getNbModel( idxClass );
      for( int idxModel = 0; idxModel < nbModel; ++idxModel ){
      
         int R = refStats[idxClass][idxModel].getNbSamples();

         // was passiert eigentlich, wenn ich diese auf ( 0,0,..) setze?
         const int dims1[]= {R, T};
         mxTmpWarpPathMat = 
           mxCreateNumericArray( 2, dims1, mxINT32_CLASS, mxREAL );
         const int dims2[]= {2, R+T};
         mxTmpWarpPathSeq = 
           mxCreateNumericArray( 2, dims2, mxINT32_CLASS, mxREAL );
         // mxTmpWarpPathMat = mxCreateDoubleMatrix( R, T, mxREAL );
         // mxTmpWarpPathSeq = mxCreateDoubleMatrix( 2, R+T, mxREAL );
         mxTmpWarpMat = mxCreateDoubleMatrix( R+1, T+1, mxREAL );
         mxTmpLocalDistMat = mxCreateDoubleMatrix( R, T, mxREAL );

         subs[0] = idxClass;
         subs[1] = idxModel;
      
         int idxSingleWarpPathMat = 
             mxCalcSingleSubscript( plhs[1], 2, subs );
      
         int idxSingleWarpPathSeq = 
             mxCalcSingleSubscript( plhs[2], 2, subs );
      
         int idxSingleWarpMat = 
             mxCalcSingleSubscript( plhs[3], 2, subs );

         int idxSingleLocalDistMat = 
             mxCalcSingleSubscript( plhs[4], 2, subs );

         mxSetCell( plhs[1], idxSingleWarpPathMat, mxTmpWarpPathMat );
         mxSetCell( plhs[2], idxSingleWarpPathSeq, mxTmpWarpPathSeq );
         mxSetCell( plhs[3], idxSingleWarpMat, mxTmpWarpMat );
         mxSetCell( plhs[4], idxSingleLocalDistMat, mxTmpLocalDistMat );

         Array<int,2> warpPathMatTmp
             ( (int*) mxGetData( mxTmpWarpPathMat ),
               shape(R,T), 
               neverDeleteData,
               ColumnMajorArray<2>() );
         warpPathMats[idxClass][idxModel].reference( warpPathMatTmp );
      
         Array<int,2> warpPathSeqTmp
             ( (int*) mxGetData( mxTmpWarpPathSeq ),
               shape(2,R+T), 
               neverDeleteData,
               ColumnMajorArray<2>() );
         warpPathSeqs[idxClass][idxModel].reference( warpPathSeqTmp );
      
         Array<double,2> warpMatTmp
             ( mxGetPr( mxTmpWarpMat ),
               shape(R+1,T+1), 
               neverDeleteData,
               ColumnMajorArray<2>() );
         warpMats[idxClass][idxModel].reference( warpMatTmp );
      
         Array<double,2> localDistMatTmp
             ( mxGetPr( mxTmpLocalDistMat ),
               shape(R,T), 
               neverDeleteData,
               ColumnMajorArray<2>() );
         localDistMats[idxClass][idxModel].reference( localDistMatTmp );
      
      }

   }
  
   *timePerformanceConversionOverhead = get_runtime() - startTime;
  
   //--------------------------------------------------------
   // Function call:
   //--------------------------------------------------------
   dtw.simulate( statistic, 
                 idxRefs,
                 idxMin,
                 *distMin, 
                 distances,
                 labels, 
                 warpPathMats,
                 warpPathSeqs,
                 warpMats,
                 localDistMats,
                 timePerformance );
  
} 


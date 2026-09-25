/**************************************************************************
**       Title: Conversion Dynamic Time Warping object
**    $RCSfile: mxDtw.cpp,v $
**   $Revision: 2.19 $$Name:  $
**       $Date: 2002/11/22 18:37:46 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: mxDtw.cpp,v $
**  Revision 2.19  2002/11/22 18:37:46  bahlmann
**  *** empty log message ***
**
**  Revision 2.18  2002/11/19 12:06:46  bahlmann
**  *** empty log message ***
**
**  Revision 2.17  2002/06/16 12:52:03  bahlmann
**  *** empty log message ***
**
**  Revision 2.16  2002/06/16 11:29:52  bahlmann
**  *** empty log message ***
**
**  Revision 2.15  2002/03/08 15:04:43  bahlmann
**  *** empty log message ***
**
**  Revision 2.14  2002/02/22 16:40:38  bahlmann
**  *** empty log message ***
**
**  Revision 2.13  2002/02/11 08:48:53  bahlmann
**  *** empty log message ***
**
**  Revision 2.12  2002/02/01 12:38:34  bahlmann
**  *** empty log message ***
**
**  Revision 2.11  2001/12/06 10:04:42  bahlmann
**  *** empty log message ***
**
**  Revision 2.10  2001/11/27 20:11:34  bahlmann
**  *** empty log message ***
**
**  Revision 2.9  2001/11/27 19:52:58  bahlmann
**  *** empty log message ***
**
**  Revision 2.8  2001/11/27 09:50:01  bahlmann
**  *** empty log message ***
**
**  Revision 2.7  2001/08/17 11:49:47  bahlmann
**  *** empty log message ***
**
**  Revision 2.6  2001/08/13 13:46:26  bahlmann
**  *** empty log message ***
**
**  Revision 2.5  2001/07/11 15:00:23  bahlmann
**  *** empty log message ***
**
**  Revision 2.4  2001/05/29 12:23:57  bahlmann
**  *** empty log message ***
**
**  Revision 2.3  2001/05/02 09:55:48  bahlmann
**  *** empty log message ***
**
**  Revision 2.2  2001/04/25 07:46:21  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/04/12 08:26:09  bahlmann
**  *** empty log message ***
**
**  Revision 2.1  2001/04/10 10:03:42  bahlmann
**  *** empty log message ***
**
**
**************************************************************************/
#include "mxDtw.hpp"

using namespace std;
using namespace blitz;

/*=========================================================================
 *  DESCRIPTION OF FUNCTION:  convert Matlab Dtw Object to C++ Dtw Object
 *  ==> see headerfile
 *=======================================================================*/
int dtwConvert( const mxArray* mxDtw, Dtw<TypeFeature>& dtw )
{

   // ---------------------------------------------------------------
   // Convert Reference Statistics
   // ---------------------------------------------------------------

   mxArray*  mxReferenceStatistics = mxGetField( mxDtw,0,"ref" );

   if ( mxReferenceStatistics == NULL ) {
      mexErrMsgTxt("No such field 'ref' in dtw structure");
   }
  
   mxArray*  mxReferenceStatisticsClass;
   mxArray*  mxReferenceStatistic;
   int nbClass = mxGetN( mxReferenceStatistics );
   vector<int> nbModels( nbClass );
   vector<vector<Statistic<TypeFeature> > > referenceStatistics;
   referenceStatistics.resize( nbClass );
  
//  hier irgendwo ist noch ein Fehler:

   for( int idxClass = 0; idxClass < nbClass; ++idxClass ) {

      mxReferenceStatisticsClass = 
          mxGetCell( mxReferenceStatistics,idxClass );

      nbModels[idxClass] = mxGetN( mxReferenceStatisticsClass );

      (referenceStatistics[idxClass]).resize(nbModels[idxClass]);

      for( int idxModel = 0; idxModel < nbModels[idxClass]; ++idxModel ) {

         mxReferenceStatistic = 
             mxGetCell( mxReferenceStatisticsClass, idxModel );
         statisticConvert( mxReferenceStatistic, 
                           referenceStatistics[idxClass][idxModel] );

      }
    
   }
   dtw.setReferenceStatistic( referenceStatistics );

   // ---------------------------------------------------------------
   // Convert Labels
   // ---------------------------------------------------------------
   // hier vielleicht bessser call by refernce:
   mxArray*  mxReferenceLabels = mxGetField( mxDtw,0,"label" );

   if ( mxReferenceLabels == NULL ) {
      mexErrMsgTxt("No such field 'label' in dtw structure");
   }
  
   nbClass = mxGetN( mxReferenceLabels );
   vector<string> referenceLabels( nbClass );
   int bufLen;
  
   for( int idxClass = 0; idxClass < nbClass; ++idxClass ) {

      mxArray*  mxReferenceLabelClass = 
          mxGetCell( mxReferenceLabels,idxClass );
      bufLen = (mxGetM(mxReferenceLabelClass) * 
                mxGetN(mxReferenceLabelClass)) + 1;
    
      char* tmpStr = (char*) mxCalloc( bufLen, sizeof(char) );

      mxGetString( mxReferenceLabelClass,tmpStr,bufLen );
      referenceLabels[idxClass] = tmpStr;
    
   }

   dtw.setLabel( referenceLabels );

   // ---------------------------------------------------------------
   // Convert Transition and Offset Information
   // ---------------------------------------------------------------
   mxArray*  mxLcc = mxGetField(mxDtw,0,"lcc"); 

   if ( mxLcc == NULL ) {
      mexErrMsgTxt("No such field 'lcc' in dtw structure");
   }
  
   int nbTrans = mxGetNumberOfElements( mxLcc );
   vector<vector<vector<int> > > transition(nbTrans);
   vector<int> nbMoves;
   nbMoves.resize(nbTrans);
   mxArray* mxTrans;

   // initialization of offsets:
   int offset[2] = {0,0};

   for( int idxTrans = 0; idxTrans < nbTrans; ++idxTrans ) {

      // get pointer to current path's moves:
      mxTrans = mxGetCell( mxLcc ,idxTrans );
      double* ptrTrans = mxGetPr( mxTrans );
      nbMoves[idxTrans] = ( (int) mxGetM( mxTrans ) ) ;

      transition[idxTrans].resize(nbMoves[idxTrans]);
    
      for( int idxMove = 0; idxMove < nbMoves[idxTrans]; ++idxMove ) {

         transition[idxTrans][idxMove].resize(2);
         transition[idxTrans][idxMove][0] = 
             (int) ptrTrans[idxMove];
         transition[idxTrans][idxMove][1] = 
             (int) ptrTrans[idxMove+nbMoves[idxTrans]];
      
         // Offsets are maxima of paths:
         offset[0] = max( offset[0], transition[idxTrans][idxMove][0] );
         offset[1] = max( offset[1], transition[idxTrans][idxMove][1] );
      
      }

   }
  
   dtw.setTransition( transition );
   dtw.setOffset( offset );

   /* ---------------------------------------------------------------
    * Convert Beam Search Threshold Sample
    * --------------------------------------------------------------- */
   mxArray* mxBeamSearchThresholdSample = mxGetField(mxDtw,0,"beamSearchThresholdSample");

   if ( mxBeamSearchThresholdSample == NULL ) {
      mexErrMsgTxt("No such field 'beamSearchThresholdSample' in dtw structure");
   }
  
   dtw.setBeamSearchThresholdSample( mxGetScalar(mxBeamSearchThresholdSample) );

   /* ---------------------------------------------------------------
    * Convert Beam Search Threshold Char
    * --------------------------------------------------------------- */
   mxArray* mxBeamSearchThresholdChar = mxGetField(mxDtw,0,"beamSearchThresholdChar");

   if ( mxBeamSearchThresholdChar == NULL ) {
      mexErrMsgTxt("No such field 'beamSearchThresholdChar' in dtw structure");
   }
  
   dtw.setBeamSearchThresholdChar( mxGetScalar(mxBeamSearchThresholdChar) );

   /* ---------------------------------------------------------------
    * Convert Normalization Information
    * --------------------------------------------------------------- */
   // hier vielleicht bessser call by refernce:
   mxArray* mxNormalize = mxGetField(mxDtw,0,"normalize");

   if ( mxNormalize == NULL ) {
      mexErrMsgTxt("No such field 'normalize' in dtw structure");
   }
  
   bufLen = (mxGetN( mxNormalize ) * mxGetM( mxNormalize)) + 1;
   char* tmpStr = (char*) mxCalloc( bufLen, sizeof(char) );

   mxGetString( mxNormalize,tmpStr,bufLen );
   string normalize = tmpStr;
  
   dtw.setNormalize( normalize );

   /* ---------------------------------------------------------------
    * Convert aPriori flag
    * --------------------------------------------------------------- */
   // hier vielleicht bessser call by refernce:
   mxArray*  mxRespectAPriori = mxGetField(mxDtw,0,"respect_apriori");

   if ( mxRespectAPriori == NULL ) {
      mexErrMsgTxt("No such field 'respect_apriori' in dtw structure");
   }
  
   bufLen = (mxGetN( mxRespectAPriori ) * mxGetM( mxRespectAPriori)) + 1;
   char* tmpStr2 = (char*) mxCalloc( bufLen, sizeof(char) );

   mxGetString( mxRespectAPriori,tmpStr2,bufLen );
   string respectAPriori = tmpStr2;
  
   dtw.setRespectAPriori( respectAPriori );

   return 1;

}


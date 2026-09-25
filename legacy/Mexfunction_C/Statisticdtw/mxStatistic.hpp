/**************************************************************************
**       Title: Statistic <-> matlab conversion
**    $RCSfile: mxStatistic.hpp,v $
**   $Revision: 1.6 $$Name:  $
**       $Date: 2002/06/28 21:11:10 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: mxStatistic.hpp,v $
**  Revision 1.6  2002/06/28 21:11:10  bahlmann
**  *** empty log message ***
**
**  Revision 1.5  2002/06/16 10:53:13  bahlmann
**  *** empty log message ***
**
**  Revision 1.4  2001/08/13 13:46:29  bahlmann
**  *** empty log message ***
**
**  Revision 1.3  2001/05/29 12:23:57  bahlmann
**  *** empty log message ***
**
**  Revision 1.2  2001/04/25 07:57:54  bahlmann
**  *** empty log message ***
**
**  Revision 1.1  2001/04/12 08:26:24  bahlmann
**  *** empty log message ***
**
**
**************************************************************************/

#ifndef MXSTATISTIC_HH
#define MXSTATISTIC_HH

#include <iostream>
#include <mex.h>
#include <iostream>
#include <matrix.h>
//#include <myFix.h>
//#include <hwr.hpp>

//typedef myFix TypeFeature;
typedef double TypeFeature;


/*======================================================================*/
/*! 
 *   Convert Matlab statistic object into c++ Statistic object
 *
 *   \param mxStatistic       Matlab statistic object
 *   \param statistic         c++ Statistic object
 */
/*======================================================================*/
int statisticConvert( const mxArray* mxStatistic, Statistic<TypeFeature>& statistic );

/*======================================================================*/
/*! 
 *   Convert c++ statistic object into Matlab object
 *
 *   \param mxStatistic       Matlab statistic object
 *   \param statistic         c++ Statistic object
 */
/*======================================================================*/
mxArray* mxStatisticConvert( const Statistic<TypeFeature> statistic );

#endif

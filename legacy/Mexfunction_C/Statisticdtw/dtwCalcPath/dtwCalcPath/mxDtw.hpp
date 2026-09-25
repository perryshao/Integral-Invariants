/**************************************************************************
**       Title: Dtw <-> matlab conversion
**    $RCSfile: mxDtw.hpp,v $
**   $Revision: 2.8 $$Name:  $
**       $Date: 2002/06/28 21:11:09 $
**   Copyright: IIF-LMB $Author: bahlmann $
** Description:
**
**    
**
**-------------------------------------------------------------------------
**
**  $Log: mxDtw.hpp,v $
**  Revision 2.8  2002/06/28 21:11:09  bahlmann
**  *** empty log message ***
**
**  Revision 2.7  2002/06/16 12:52:03  bahlmann
**  *** empty log message ***
**
**  Revision 2.6  2002/06/16 11:29:52  bahlmann
**  *** empty log message ***
**
**  Revision 2.5  2001/08/13 13:46:26  bahlmann
**  *** empty log message ***
**
**  Revision 2.4  2001/05/29 12:23:57  bahlmann
**  *** empty log message ***
**
**  Revision 2.3  2001/04/27 07:41:36  bahlmann
**  everyday crontab checkin
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

#ifndef MXDTW_HPP
#define MXDTW_HPP

#include <iostream>
#include <vector>
#include <string>
#include <blitz/array.h>
#include <matrix.h>
#include <mex.h>
//#include <hwr.hpp>
#include "mxStatistic.hpp"
//#include <myFix.h>

//
// TypeFeature defined in mxStatistic.hpp...
//
//typedef myFix TypeFeature;
//typedef double TypeFeature;

/*======================================================================*/
/*! 
 *   Convert Matlab dtw object into c++ Dtw object
 *
 *   \param mxDtw       Matlab dtw object
 *   \param dtw         c++ Dtw object
 */
/*======================================================================*/
int dtwConvert( const mxArray* mxDtw, Dtw<TypeFeature>& dtw );

/*======================================================================*/
/*! 
 *   Convert c++ dtw object into Matlab object
 *
 *   \param mxDtw       Matlab dtw object
 *   \param dtw         c++ Dtw object
 */
/*======================================================================*/
//mxArray* mxDtwConvert( const Dtw<double> dtw );

#endif

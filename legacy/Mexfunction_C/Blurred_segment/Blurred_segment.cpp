// Blurred_segment.cpp : 定义控制台应用程序的入口点。
//

#include <mex.h> 
#include <matrix.h>
#include <math.h>
#include "unit_reco.cpp"




#define Fori(x) for (int i = 0 ;  i < (x) ; i++)
#define Forj(x) for (int j = 0 ;  j < (x) ; j++)


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *P,*width;
	double *MBS_B_E_seg;
	int m,pos=0,segment_m;
	

	/* parse input arguments*/
	P = mxGetPr(prhs[0]);//P
	m = mxGetM(prhs[0]);//rows for P
	width = mxGetPr(prhs[1]);//P


	/* create output arguments*/

	plhs[0]=mxCreateDoubleMatrix(m,4,mxREAL);//width
	MBS_B_E_seg= mxGetPr(plhs[0]);
	point P_i;
	/* define the parameters*/
	Reco * M[4];
	M[0] = new RecoLR();
	M[1] = new RecoRL();
	M[2] = new RecoTB();
	M[3] = new RecoBT();
	
	Q max_thickness(width[0],1);
	segment_m = 0;
	/* initialize the g matrix */
	while (pos<m)
	{
		
		int typemax = 0;
		int indmax  = 0;
		Q curEp;
		Fori(4)
		{	
			M[i]->Init();
			curEp = 0;
			int k =  0;
			while ( (curEp < max_thickness) && (pos+k<m) )
				{
					P_i.x=P[0*m+(pos+k)]; P_i.y=P[1*m+(pos+k)];
					M[i]->Insert(curEp, P_i);
					if (curEp < max_thickness)
					{
						if ( (indmax==0) && (M[i]->valid()) )  { indmax = 1; typemax = i; }
						if ( (indmax >0) && (k >= indmax) )   { indmax = k+1; typemax = i; }
						k++;
					}
				}
		}

		M[typemax]->Init();
		Fori(indmax)
		{
		  P_i.x=P[0*m+(pos+k)]; P_i.y=P[1*m+(pos+k)];
		  M[typemax]->Insert(curEp,P_i);
		  //MBS_B_E_seg[0*m+segment_m] = typemax;
		}
		Fori(4)          // reinit for the next segment
			M[i]->Init();
		MBS_B_E_seg[0*m+segment_m] = pos;
        pos = pos+indmax;
        if (pos != m ) pos--;
		MBS_B_E_seg[1*m+segment_m] = pos;
		MBS_B_E_seg[2*m+segment_m]=curEp.d;
		MBS_B_E_seg[3*m+segment_m]=curEp.n;
		segment_m++;
	}
	        
}


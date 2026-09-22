% [A,y_pred,Ea,Ey,P] = kf(Z,X,p,V);
%	runs Kalman-Bucy filter over observations matrix Z
%	for 1-step prediction onto matrix X (X can = Z)
%	with model order p
%	V = initial covariance of observation sequence noise
%	returns model parameter estimation sequence A,
%	sequence of predicted outcomes y_pred
%	and error matrix Ey (reshaped) for y and Ea for a
%	along with inovation prob P = P(y_t | D_t-1) = evidence
%	(c) S.J.Roberts Nov 1997, modified August 1998.

function [A,y_pred,Ea,Ey,P] = kf(Z,X,p,V)

ALPHA = 0.9;					% smoother for W, V estimates
SEG = p;
SHIFT = 1;					% move on one timestep at a time

W = zeros(p);					% zero to start
y_pred = zeros(size(X));			% output same size
E = zeros(size(X));
A = ones(size(X,1),p)/p;			% average first p points to start with
N = round(size(X,1)/SHIFT - SEG/SHIFT)
D = size(X,2);
a = ones(p,1)/p;				% model parameters - prior mean for a(0)
C = eye(p);					% initial covariance for a(0)
T = 0;						% test statistic on residual

hWait = waitbar(0,'Kalman filter');

for t = 1:N
  n = (t-1)*SHIFT + SEG +1;			% one-step predictor
  F = Z(1+(t-1)*SHIFT:(t-1)*SHIFT + SEG,:);	% p-past samples - relates obsn. to state
  y = X(n,:);					% one step predictor
  R = C + W;					% covariance of prior P(a|D_t-1)
  y_pred(n,:) = -a'*F;				% make one-step forecast, mean y_pred, cov E
  Q = F'*R*F + V;				% covariance of posterior P(Y_t|D_t-1)
  Q_W0 = F'*C*F + V;				% assuming there is no state noise added
  K = R*F/Q;					% Kalman gain factor
  a = a + K*(y_pred(n,:)-y)';			% posterior mean of P(a|D_t)
  C = R - K*F'*R;				% posterior cov of P(a|D_t)
  e = (y_pred(n,:)-y)'*(y_pred(n,:)-y);		% error residual
  sigma_wu = F'*R*F;				% pred error due to weight uncertainty
  T = T*ALPHA + (1-ALPHA)*(e - Q_W0)/(F'*F);	% infer the system (parameter) noise level
  if (T>0)
    W = T*eye(p);
    else W = zeros(p);
  end;
  if ((e - sigma_wu) > 0)
    V = ALPHA*V + (1-ALPHA) * (e - sigma_wu);	% infer observation noise level
  end;
  A(n,:) = a';
  Ey(n,:) = reshape(Q,1,size(Q,1)*size(Q,2));
  Ea(n,:) = reshape(diag(C),1,p);
  P(n) = gaussres(y,y_pred(n,:),Q) * sqrt(det(C)/det(R));
  if (rem(N,t/10)==0)
    waitbar(t/N,hWait);
  end;
end;

P = P';

close(hWait);
return;


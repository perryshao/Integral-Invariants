function [min_distance, d, g] = dtw_adj_orien(A, B, orientation1, orientation2, flag, adjustment_window_size)
% Minimal time normalized dtw distance between speech patterns A and B.

% References:
%
% [SakoeChiba1978] SAKOE, Hiroki; CHIBA, Seibi: Dynamic Programming
%     Algorithm Optimization for Spoken Word Recognition,
%     http://citeseer.ist.psu.edu/viewdoc/download?doi=10.1.1.114.3782&rep=rep1&type=pdf
%
% [Paliwal1982] PALIWAL, K.K. et al.: A Modification over Sakoe and Chiba's
%     Dynamic Time Warping Algorithm for Isolated Word Recognition,
%     http://maxwell.me.gu.edu.au/spl/publications/papers/sigpro82_kkp_dtw.pdf
%
% [Ellis2003] ELLIS, D.: Dynamic Time Warp (DTW) in Matlab,
%     http://www.ee.columbia.edu/~dpwe/resources/matlab/dtw/

r = adjustment_window_size;
A = A(3:end - 2, :); B = B(3:end - 2, :); % because beginning and ending two features are zero
orientation1 = orientation1(3:end - 2, :); orientation2 = orientation2(3:end - 2, :);
% get length of speech patterns A and B
I = size(A, 1);
J = size(B, 1);
d = zeros(I, J);
% local distance matrix
d = feature_dist_orien_matrix(A, B, orientation1, orientation2, flag);
% global distance matrix
NaN_index = isnan(d);
d(NaN_index) = 0;
I = size(d, 1); J = size(d, 2);
d = double(d);
%% search optimal path using C for acceleratting the computation
[g, steps] = dtwpath(d, r); %#ok<NASGU>
%% search optimal path using matlab
% g = zeros(I+1,J+1);
% g(:,:) = inf;
% g(1,1) = 2*d(1,1); % initial condition, see (19) in [SakoeChiba1978]
% s = J/I; % slope from (0,0) to (I,J)
% steps = zeros(I,J); % steps to take in order to reach D(i,j)
%
% for i = 2:I+1;
%     for j = 2:J+1;
%         if (abs(i-(j/s)) > r)
%             % we're outside the adjustment window
%             continue;
%         end
%
%         % local distance matrix is smaller than g, translate coordinates
%         i_l = i-1;
%         j_l = j-1;
%
%         % calculate global distances
%         % (see DP-equation (20) from [SakoeChiba1978] for reference)
%         [distance, step] =  min([g(i,   j-1) +   d(i_l, j_l)...
%                                  g(i-1, j-1) + 2*d(i_l, j_l)...
%                                  g(i-1, j)   +   d(i_l, j_l)]);
% %         distance =  min([g(i,   j-1) +   d(i_l, j_l)...
% %                          g(i-1, j-1) + 2*d(i_l, j_l)...
% %                          g(i-1, j)   +   d(i_l, j_l)]);
%         g(i,j) = distance;
%         steps(i-1,j-1) = step;
%     end
% end

% time normalize global distance matrix
N = I + J;
D = g / N;
% remove additional inf padded row and column from global distance matrix
D = D(2:end, 2:end);
% path=traceback_path(steps);
min_distance = D(end, end);

function d = feature_dist_orien_matrix(t, r, orientation1, orientation2, flag)

[det_k, det_t, det_orien, det_rd, S_k, S_t, S_orien, S_rd] = distance_matrix(t, r, orientation1, orientation2);
factor_kt = mean(mean(det_orien ./ S_orien)) / mean(mean((det_k ./ S_k) .* (det_t ./ S_t)));
factor_rd = mean(mean(det_orien ./ S_orien)) / mean(mean(det_rd ./ S_rd));
d = factor_kt * (det_k ./ S_k) .* (det_t ./ S_t) + ((det_orien ./ S_orien) + factor_rd * (det_rd ./ S_rd)); % 0.9694 interg 0.9817 interg(dynamic reaius)/0.9847 diff
% d=(det_orien./S_orien)+factor_rd*(det_rd./S_rd);% for Fourier descriptor
d = (det_k ./ S_k) .* (det_t ./ S_t); % for root trajectory only

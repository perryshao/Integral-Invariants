% [skel,mot] = readMocap('data/skl_s01_a01_r01.bvh');
[skel,mot]= readMocap('data/HDM_dg.asf', 'data/HDM_dg_06-03_03_120.amc');
 mot.samplingRate=120;
 mot.frameTime=0.0083;
 animate(skel, mot)
bvhPlayFile('data/HDM_dg_hitRHandHead_007_120.bvh');

[skel, channels, frameLength] = bvhReadFile('data/skl_s01_a01_r01.bvh');
% skelPlayData(skel, channels, frameLength);
%  
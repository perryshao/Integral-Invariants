function im2movie(aviname, dirname)

t = cputime;
vidObj = VideoWriter(aviname);
vidObj.Quality = 100;
vidObj.FrameRate = 3;
%%vidObj.compression='None';
open(vidObj);
%% make moive from image sequence in a folder
filename = dir(strcat(dirname, '\*.tif'));
ConvertFrameNum = length(filename);
for i = 1 : ConvertFrameNum
%     imshow(imread(strcat(dirname, '\', filename(i).name)));
%     currFrame=getframe;
%     writeVideo(vidObj,currFrame);

    pic = imread(strcat(dirname, '\', filename(i).name));
    Mov = im2frame(pic);
    if rem(i, vidObj.FrameRate) == 0
        disp([num2str(i) ' frames processed...'])
    end
    writeVideo(vidObj, Mov);
end
close(vidObj);
e = cputime - t
return
%% make movie from depth bin files
% [img, dimension]=DepthMapBinIO(dirname);
% img_seqs = reshape(img,dimension(1),dimension(2),dimension(3));
% for i = 1 : size(img_seqs,3)
%     imagesc(img_seqs(:,:,i));
%     currFrame=getframe;
%     writeVideo(vidObj,currFrame);
% end
% close(vidObj);
% e = cputime - t
% return
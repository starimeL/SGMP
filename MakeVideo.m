%framesPath :图像序列所在路径，同时要保证图像大小相同
%videoName:  表示将要创建的视频文件的名字
%quality:    生成视频的质量 0-100
%Compressed: 压缩类型， 'Indeo3'（默认）, 'Indeo5', 'Cinepak', 'MSVC', 'RLE' or 'None'
%fps: 帧率
%startFrame ,endFrame ;表示从哪一帧开始，哪一帧结束

if(exist('videoName','file'))
    delete videoName.avi
end

%生成视频的参数设定
aviobj=VideoWriter('video.avi','MPEG-4');  %创建一个avi视频文件对象，开始时其为空
aviobj.Quality=100;
aviobj.FrameRate=5;
% aviobj.compression='None';
open(aviobj);

%读入图片
for i=1:200    
    frames=video{i};
    writeVideo(aviobj,frames);
%     aviobj=addframe(aviobj,uint8(frames));
end
close(aviobj); % 关闭创建视频
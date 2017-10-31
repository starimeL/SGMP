AA = zeros(256,1);
B = zeros(256,1);
C = zeros(256,1);

start = 1;
stop = 200;

File1 = dir(fullfile('..\2014_imgleft\test_1\imgleft\','*.pgm'));
File2 = dir(fullfile('..\2014_labels\test_1\groundtruth\','*.pgm'));
File3 = dir(fullfile('..\2014_imgleft\test_2\imgleft\','*.pgm'));
File4 = dir(fullfile('..\2014_labels\test_2\groundtruth\','*.pgm'));
File5 = dir(fullfile('..\2014_imgleft\test_3\imgleft\','*.pgm'));
File6 = dir(fullfile('..\2014_labels\test_3\groundtruth\','*.pgm'));
File7 = dir(fullfile('..\2014_disp\test_1\dispInt\','*.pgm'));
File8 = dir(fullfile('..\2014_disp\test_2\dispInt\','*.pgm'));
File9 = dir(fullfile('..\2014_disp\test_3\dispInt\','*.pgm'));
File10 = dir(fullfile('..\2014_cameras\test_1\cameras\','*.xml'));
File11 = dir(fullfile('..\2014_cameras\test_2\cameras\','*.xml'));
File12 = dir(fullfile('..\2014_cameras\test_3\cameras\','*.xml'));

% File1 = dir(fullfile('..\2014_imgleft\train_1\imgleft\','*.pgm'));
% File2 = dir(fullfile('..\2014_labels\train_1\groundtruth\','*.pgm'));
% File3 = dir(fullfile('..\2014_imgleft\train_2\imgleft\','*.pgm'));
% File4 = dir(fullfile('..\2014_labels\train_2\groundtruth\','*.pgm'));
% File5 = dir(fullfile('..\2014_imgleft\train_3\imgleft\','*.pgm'));
% File6 = dir(fullfile('..\2014_labels\train_3\groundtruth\','*.pgm'));
% File7 = dir(fullfile('..\2014_disp\train_1\dispInt\','*.pgm'));
% File8 = dir(fullfile('..\2014_disp\train_2\dispInt\','*.pgm'));
% File9 = dir(fullfile('..\2014_disp\train_3\dispInt\','*.pgm'));
% File10 = dir(fullfile('..\2014_cameras\train_1\cameras\','*.xml'));
% File11 = dir(fullfile('..\2014_cameras\train_2\cameras\','*.xml'));
% File12 = dir(fullfile('..\2014_cameras\train_3\cameras\','*.xml'));

load('modelBsds.mat');

for imageId = start:stop
    disp(imageId);
    
    if imageId <=100 
        img = imread(strcat('..\2014_imgleft\test_1\imgleft\',File1(imageId).name));
        ground = imread(strcat('..\2014_labels\test_1\groundtruth\',File2(imageId).name));
        dispar = imread(strcat('..\2014_disp\test_1\dispInt\',File7(imageId).name));
        XMLpath = strcat('..\2014_cameras\test_1\cameras\',File10(imageId).name);
        [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);     
    end
    if imageId>100 &&  imageId<=200
        img = imread(strcat('..\2014_imgleft\test_2\imgleft\',File3(imageId-100).name));
        ground = imread(strcat('..\2014_labels\test_2\groundtruth\',File4(imageId-100).name));
        dispar = imread(strcat('..\2014_disp\test_2\dispInt\',File8(imageId-100).name));
        XMLpath = strcat('..\2014_cameras\test_2\cameras\',File10(imageId-100).name);
        [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);           
    end
    if imageId>200
        img = imread(strcat('..\2014_imgleft\test_3\imgleft\',File5(imageId-200).name));
        ground = imread(strcat('..\2014_labels\test_3\groundtruth\',File6(imageId-200).name));
        dispar = imread(strcat('..\2014_disp\test_3\dispInt\',File9(imageId-200).name));
        XMLpath = strcat('..\2014_cameras\test_3\cameras\',File10(imageId-200).name);
        [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);           
    end      

%     if imageId <=100 
%         img = imread(strcat('..\2014_imgleft\train_1\imgleft\',File1(imageId).name));
%         ground = imread(strcat('..\2014_labels\train_1\groundtruth\',File2(imageId).name));
%         dispar = imread(strcat('..\2014_disp\train_1\dispInt\',File7(imageId).name));
%         XMLpath = strcat('..\2014_cameras\train_1\cameras\',File10(imageId).name);
%         [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);           
%     end
%     if imageId>100 &&  imageId<=200
%         img = imread(strcat('..\2014_imgleft\train_2\imgleft\',File3(imageId-100).name));
%         ground = imread(strcat('..\2014_labels\train_2\groundtruth\',File4(imageId-100).name));
%         dispar = imread(strcat('..\2014_disp\train_2\dispInt\',File8(imageId-100).name));
%         XMLpath = strcat('..\2014_cameras\train_2\cameras\',File10(imageId-100).name);
%         [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);           
%     end
%     if imageId>200
%         img = imread(strcat('..\2014_imgleft\train_3\imgleft\',File5(imageId-200).name));
%         ground = imread(strcat('..\2014_labels\train_3\groundtruth\',File6(imageId-200).name));
%         dispar = imread(strcat('..\2014_disp\train_3\dispInt\',File9(imageId-200).name));
%         XMLpath = strcat('..\2014_cameras\train_3\cameras\',File10(imageId-200).name);
%         [focal, sx, sy, x0, y0, basel] = GetCamPara(XMLpath);           
%     end               
    
    % CUT IMAGE!!!
    img = img(40:400,24:1000);
    ground = ground(40:400,24:1000);
    dispar = dispar(40:400,24:1000);    
    
    dispar = FillDepth(dispar);
    [height,width] = size(img);   
    tic;

    % Achieve the high segmentation upper bound accuracy while only generate
    % about 100 segment regions
    [segments,GroundPlane,skyIndices] = SGMP(img, dispar, focal, sx, sy, x0, y0, basel, model);
%     SGMP;
    
    toc;
    
    img = double(img);
    img = img ./ max(img(:));           
    imgRgb = Convert2grayRGB(img);  % optional    
    
    ground = ground + 1; %%%
    segments = segments + 1; %%%
    RegionNum = max(segments(:)); 

    % regard bicycle as pedestrian
    ground(ground==5+1) = 2+1;
    ground(ground==12+1) = 2+1;        
    
% %     imgOrigin(inlierIndices) = 0;
% 
% %     LabelC = ShowLabel(segments);
% %     a1 = double(LabelC(:).*255);
% %     imgOrigin0 = Convert2grayRGB(imgOrigin);
% %     a2 = double(imgOrigin0(:));
% %     b = [a1 a2] * [0.5; 0.5];
% %     imgResult3 = uint8(reshape(b,[height width 3]));         
%     
% %     imwrite(imgResult,['SegResult',num2str(imageId),'.png']);  

%     imwrite(segments,['Segments',num2str(imageId),'.png']);   
    
%     save(strcat('Height',num2str(imageId),'.mat'),'PosHeight');
%     imwrite(PosHeight,['Height',num2str(imageId),'.png']);   

%% =========================================    vote region label

    LabelNum = max(ground(:));
    RegionLabelMatrix = zeros(RegionNum,LabelNum);
    
    for i = 1:height
        for j = 1:width
            RegionId = segments(i,j);
            if ground(i,j)~=255
                RegionLabelMatrix(RegionId,ground(i,j)) = RegionLabelMatrix(RegionId,ground(i,j)) + 1;
            end
        end
    end
    [~, RegionLabel] = max(RegionLabelMatrix,[],2);
    
%% ==========================================    calc accuracy  
    
    LabelPredict = RegionLabel;
    
    LabeledImg = zeros(height, width);
    for y = 1:height
        for x = 1:width
            RegionId = segments(y,x);
            P = LabelPredict(RegionId);
            G = ground(y,x);
            if (G==255)
                continue;
            end
            LabeledImg(y,x) = P;
            if P==G
                AA(P,1) = AA(P,1)+1;
                B(P,1) = B(P,1)+1;
                C(P,1) = C(P,1)+1;
            end
            if P ~= G && P > 0
                B(G,1) = B(G,1)+1;
                C(P,1) = C(P,1)+1;
            end
        end
    end
    
    ee = false(height,width);
    for i = 1:height
        for j = 1:width-1
            if segments(i,j)~=segments(i,j+1)
                ee(i,j) = true;
                ee(i,j+1) = true;
            end
        end
    end
    
    for j = 1:width
        for i = 1:height-1
            if segments(i,j)~=segments(i+1,j)
                ee(i,j) = true;
                ee(i+1,j) = true;
            end            
        end
    end

% %     figure(5);         
% %     LabelC = ShowLabel(ground);
%     LabelC = ShowLabel(segments);
%     a1 = double(LabelC(:).*255);
%     imgOrigin = Convert2grayRGB(imgOrigin);
%     a2 = double(imgOrigin(:));
%     b = [a1 a2] * [0.5; 0.5];
%     imgResult2 = uint8(reshape(b,[height width 3]));
    
% %     figure(5);         
% %     LabelC = ShowLabel(ground);
%     LabelC = ShowLabel(small+1);
%     a1 = double(LabelC(:).*255);
%     imgOrigin = Convert2grayRGB(Edges);
%     a2 = double(imgOrigin(:));
%     b = [a1 a2] * [0.3; 0.7];
%     imgResult3 = uint8(reshape(b,[height width 3]));
%     
    figure(1);
    imgOrigin = imgRgb;
    for i = 1:height
        for j = 1:width 
            if ee(i,j)
                imgOrigin(i,j,:) = [255 0 0];
            end
        end
    end
    imshow([imgOrigin]);
    
%     video{imageId} = imgOrigin;
    
%     figure(2);
%     imshow(imgResult2);
%     
%     figure(3);
%     imshow(imgResult3);   
    
%     
%     LabelC = ShowLabel(ground);    
%     a1 = double(LabelC(:).*255);
% %     imgOrigin = Convert2grayRGB(imgOrigin);
%     a2 = double(imgOrigin(:));
%     b = [a1 a2] * [0.5; 0.5];
%     imgResult1 = uint8(reshape(b,[height width 3]));
% 
%     imshow([imgResult; imgResult1;imgResult2]);    
% %     rr = [imgResult1;imgResult2];
% %     imwrite(rr,'GRID_MST_Segmentation.png');    
% 
% %     LabeledImg = uint8(LabeledImg);    
% %     imgResPath = images( ImageNow ).name;
% %     imgResPath = ['./Result/',imgResPath(1:end-15),'Result.png'];        
% %     imwrite(LabeledImg,imgResPath);    
% %     
% %     imgResShowPath = images( ImageNow ).name;
% %     imgResShowPath = ['./ResultShow/',imgResShowPath(1:end-15),'ShowResult.png'];        
% %     imwrite(imgResult1,imgResShowPath);

end

S = AA./(B+C-AA+eps);

disp('');
disp(['Ground = ',num2str(100*S(1,:)),'%']);
disp(['Car = ',num2str(100*S(2,:)),'%']);
disp(['People = ',num2str(100*S(3,:)),'%']);
disp(['Sky = ',num2str(100*S(5,:)),'%']);
disp(['Building = ',num2str(100*S(9,:)),'%']);


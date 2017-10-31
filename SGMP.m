function [segments,GroundPlane,skyIndices] = SGMP(img, dispar, focal, sx, sy, x0, y0, basel, model)
% note that disparity map here need to contain no holes or noise

    % ---------------------- Parameters for Ground Parsing --------------------
    p1.DepthShrink_Para         = 305000;    % the addition quantity on disparity for depth shrinkage (here nearly inf)
    p1.MinGridRegion_Para       = 2000;      % MinimalGridSize(to be considered as GroundPlane) = sum(ImgPixels)/MinGridRegion_Para
    p1.stepZ                    = 0.02;      % space grid step size on z-axis(>0.005)
    p1.stepX                    = 0.01;      % space grid step size on x-axis(>0.005)
    p1.MinGroundRegion_Para     = 500;       % MinRegionSize = sum(ImgPixels)/MinGroundRegion_Para
    p1.GroundEdge_RefinePara    = 15;        % for smoothing GroundPlane boundary
    p1.maxDistance              = 0.1;       % distance threshold for RANSAC plane fitting
    p1.Edge_Para                = 0.98;      % image gradient refining
    % -------------------------------------------------------------------------


    % -------- Parameters for Space Grid Segmentation(coarse) via MST ---------  
    p2.DepthShrink_Para         = 10000;     % the addition quantity on disparity for depth shrinkage  
    p2.stepZ                    = 0.04;      % space grid step size on z-axis(>0.005)
    p2.stepX                    = 0.02;      % space grid step size on x-axis(>0.005)  
    p2.height_histdim           = 100;       % dimentionality of height histogram feature
    p2.color_histdim            = 16;        % dimentionality of colour histogram feature
    p2.MinSize                  = 20;        % minimal grid size(to be considered valid grid)
    p2.RegionNum                = 125;       % expected number of mega pixels
    p2.BaseNum                  = 16;        % parameter of MST edge weight     
    % -------------------------------------------------------------------------   
    
    
    % ------------- Parameters for Segments Refine(fine) ----------------------  
    p3.DepthShrink_Para         = 10000;     % the addition quantity on disparity for depth shrinkage
    p3.SegSizeMin               = 50;        % minimal segment size (in pixel)
    p3.SegRelativeSizeMin       = 200;       % minimal segment size (in relative real world size)
    p3.Gradient_Thr             = 3;         % gradient threshold to judge if a small segment is crossing any semantic boudary
    % -------------------------------------------------------------------------          

    [height,width] = size(img);    
    
%% ========================   High Accuracy Ground Plane Calculation
   
    img = double(img);
    img = img ./ max(img(:));           
    imgRgb = Convert2grayRGB(img);  % optional
    
    [GroundPlane, PosHeight, SegRaw, GroundRaw, Edges] = ParseGround( dispar,focal,basel,x0,sx,y0,sy,imgRgb,model, p1 );              
    
%% ========================   Precompute the Sky Region(could be modified according to different dataset)
    
    % FIND SKY
    MeanHeight = mean(PosHeight(img>0.9));   
    skyIndices = PosHeight>MeanHeight & img>0.999;          
    PosHeight(skyIndices) = max(PosHeight(:));
    dispar(skyIndices) = min(dispar(:));    


%% ========================   Space Grid Mega Pixel Segmentation    
    
    [SegRAW, SegGRID] = SegGRID_MST(imgRgb,dispar,focal,basel,x0,sx,PosHeight,GroundPlane, p2 );      
    
    dispar = double(dispar);
    worldZ = (focal * basel) ./ (dispar + p3.DepthShrink_Para);   

    SegGRID = uint16(SegGRID);
    [segments, small] = SegRefine_mex(SegGRID,skyIndices,worldZ,Edges,GroundPlane, p3 ); 
end
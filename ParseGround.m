function [GroundPlane, PosHeight, SegRaw, GroundRaw, Edges] = ParseGround( dispar,focal,basel,x0,sx,y0,sy,imgRgb,model, p1 )

% ---------------------- Parameters for Ground Parsing --------------------
    DepthShrink_Para         = p1.DepthShrink_Para;  
    MinGridRegion_Para       = p1.MinGridRegion_Para;    
    stepZ                    = p1.stepZ;     
    stepX                    = p1.stepX;     
    MinGroundRegion_Para     = p1.MinGroundRegion_Para;     
    GroundEdge_RefinePara    = p1.GroundEdge_RefinePara;    
    maxDistance              = p1.maxDistance;      
    Edge_Para                = p1.Edge_Para;      
% -------------------------------------------------------------------------

    [height, width] = size(dispar);

    %% ============ GRID Segmentation for Finding Ground Plane
    
    dispar = double(dispar);
    [SegRaw, GroundRaw] = SegGRID_Ground_mex(dispar,focal,basel,x0,sx,MinGridRegion_Para,DepthShrink_Para,stepZ,stepX);    
    GroundPlane = GroundRaw;

    %% ============== Fit Plane & Get Height    
    
    dispar = double(dispar);
    
    xyzPoints = zeros(height,width,3);
    worldZ = (focal * basel) ./ dispar;   
    worldX = (repmat(1:width,height,1)-x0).*worldZ/(focal/sx);
    worldY = (repmat((1:height)',1,width)-y0).*worldZ/(focal/sy);
    xyzPoints(:,:,1) = worldX;
    xyzPoints(:,:,2) = worldY;
    xyzPoints(:,:,3) = worldZ;    
    xyzPoints = xyzPoints * 1000;     
    
    GroundPoints = [worldX(GroundPlane==1), worldY(GroundPlane==1), worldZ(GroundPlane==1)];
    GroundPoints = GroundPoints * 1000;        
    
    ptCloud = pointCloud(GroundPoints);    
    [modelPlane,inlierIndices,outlierIndices] = pcfitplane(ptCloud,maxDistance);       
    
    PlaneP = modelPlane.Parameters;
    xyzPoints(:,:,2) = xyzPoints(:,:,2) - ((PlaneP(4)-PlaneP(1)*xyzPoints(:,:,1)-PlaneP(3)*xyzPoints(:,:,3))/PlaneP(2));    
    
    PosHeight = -xyzPoints(:,:,2);
    PosHeight(abs(PosHeight)==Inf)=NaN;
    
    GroundHeight = nanmean(PosHeight(GroundPlane==1));
    
    GroundPlane = uint8((GroundPlane==1) | (PosHeight<GroundHeight));    
    GroundPlane = logical(GroundPlane);
    GroundPlane = MergeSeg_Ground_mex(GroundPlane,GroundEdge_RefinePara,height*width/MinGroundRegion_Para); 
    
    PosHeight = PosHeight - GroundHeight;
    PosHeight(PosHeight<0) = 0;       
    
    %% ============== Refine according to RGB

    Edges = edgesDetect(imgRgb,model);
    Edges = 1 - Edges;    
    
    GroundPlane = logical(GroundPlane);
    GroundPlane = GroundRefine_mex(Edges,GroundPlane,Edge_Para);

end


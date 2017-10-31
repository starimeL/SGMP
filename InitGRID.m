function [ SegRAW,indListNum,RegionHeightHist,RegionColorHist,RegionPNum,GridFlag ] = InitGRID( indMax,height_histdim,color_histdim,MinSize,stepZ,stepX,GroundPlane,worldZ,worldX,PosHeight,imgRgb1,imgRgb2,imgRgb3 )

    [height,width] = size(GroundPlane);

    indList = zeros(height*width,1);
    head = zeros(indMax,indMax);
    tail = zeros(indMax,indMax);
    indListNum = zeros(indMax,indMax);   
    GRIDlabel = zeros(indMax,indMax);

    for j = 1:width
        for i = 1:height
            if GroundPlane(i,j)
                continue;
            end                  
            zz = ceil(worldZ(i,j)/stepZ)+1;                         
            xx = ceil(worldX(i,j)/stepX)+1;
            indListNum(zz,xx) = indListNum(zz,xx) + 1;         
        end
    end         
    
    ind = 1;
    for zz = 1:indMax
        for xx = 1:indMax
            head(zz,xx) = ind;
            ind = ind + indListNum(zz,xx);
            tail(zz,xx) = ind - 1;
%             indList{zz,xx} = zeros(indListNum(zz,xx),1);
            GRIDlabel(zz,xx) = sub2ind([indMax,indMax],zz,xx); 
        end
    end    
    
    SegRAW = zeros(height,width);
    indImg = 0;
    indListNum = zeros(indMax,indMax);
    for j = 1:width
        for i = 1:height                                                                 
            indImg = indImg + 1;
            
            if GroundPlane(i,j)
                continue;
            end                
            
            zz = ceil(worldZ(i,j)/stepZ)+1;                         
            xx = ceil(worldX(i,j)/stepX)+1;            
            SegRAW(i,j) = GRIDlabel(zz,xx);             
                
            indList(head(zz,xx)+indListNum(zz,xx)) = indImg;
            indListNum(zz,xx) = indListNum(zz,xx) + 1;                
%             indList{zz,xx}(indListNum(zz,xx)) = indImg;        
%             indList{indZ,indX}(end+1) = indImg;            
        end
    end  
    
    RegionHeightHist = zeros(indMax*indMax,height_histdim);
    RegionColorHist = zeros(indMax*indMax,3*color_histdim);
    RegionPNum = zeros(1,indMax*indMax);

    imgCC = cell(1,3);
    imgCC{1} = imgRgb1;
    imgCC{2} = imgRgb2;
    imgCC{3} = imgRgb3;
    
    %% Calc Grid Info
    
    GroundPlane = uint16(GroundPlane);
    
    GridFlag = zeros(indMax,indMax);
    for zz = 1:indMax
        for xx = 1:indMax                 
            
            hh = head(zz,xx);
            tt = tail(zz,xx);
            pset = hh:tt;                  

            if (indListNum(zz,xx)>MinSize) && sum(GroundPlane(indList(pset)))/indListNum(zz,xx)<0.8    
                
                GridFlag(zz,xx) = 1;
                
                RegionPNum(sub2ind([indMax,indMax],zz,xx)) = indListNum(zz,xx);
                
                RegionHeight = PosHeight(indList(pset));
                RegionHeightHist(sub2ind([indMax,indMax],zz,xx),:) = hist(RegionHeight(:),100);                
                
                ColorHist = zeros(1,3*color_histdim);
                for c = 1:3
                    RegionColor = double(imgCC{c}(indList(pset)));
                    ColorHist((c-1)*color_histdim+1:c*color_histdim) = hist(RegionColor(:),16);
%                     ColorHist = [ColorHist, hist(RegionColor(:),color_histdim)];
                end
                RegionColorHist(sub2ind([indMax,indMax],zz,xx),:) = ColorHist;
                
            end
        end
    end        
    
end


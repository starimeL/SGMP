function [SegRAW, GroundPlane] = SegGRID_Ground(dispar,focal,basel,x0,sx,MinGridRegion_Para,DepthShrink_Para,stepZ,stepX)        

    [height, width] = size(dispar);

    MinSize = round(height*width/MinGridRegion_Para);        
    
    dispar = double(dispar);    
    worldZ = (focal * basel) ./ (dispar + DepthShrink_Para);   
    worldX = (repmat(1:width,height,1)-x0).*worldZ/(focal/sx);
    
    worldZ = worldZ - min(worldZ(:));
    worldZ = worldZ/max(worldZ(:));
    worldX = worldX - min(worldX(:));
    worldX = worldX/max(worldX(:));        

    y = zeros(height,width);
    x = zeros(height,width);
    
    indMax = max(ceil(1/stepZ),ceil(1/stepX)) + 1;
    indList = zeros(height*width,1);
    head = zeros(indMax,indMax);
    tail = zeros(indMax,indMax);    
    indListNum = zeros(indMax,indMax);
    
    for j = 1:width
        for i = 1:height
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
        end
    end
    
    segments = zeros(height,width);        
    indImg = 0;
    indListNum = zeros(indMax,indMax);
    for j = 1:width
        for i = 1:height
            indImg = indImg + 1;
            segments(i,j) = ceil(worldZ(i,j)/stepZ)*ceil(1/stepX)+ceil(worldX(i,j)/stepX);
            zz = ceil(worldZ(i,j)/stepZ)+1;                         
            xx = ceil(worldX(i,j)/stepX)+1;
            indList(head(zz,xx)+indListNum(zz,xx)) = indImg;
            indListNum(zz,xx) = indListNum(zz,xx) + 1;    
            
%             indList{zz,xx}(indListNum(zz,xx)) = indImg;  
%             indList{indZ,indX}(end+1) = indImg;         

            y(i,j) = i;
            x(i,j) = j;

        end
    end        
    
    SegRAW = segments;
   
    cnt = 0;
    VerticalMean = 0;
    
    for zz = 1:indMax
        for xx = 1:indMax
            
            hh = head(zz,xx);
            tt = tail(zz,xx);
            pset = hh:tt;      
            
            if (indListNum(zz,xx)<MinSize) && (indListNum(zz,xx)~=0)
                l = min(x(indList(pset)));
                r = max(x(indList(pset)));
                u = min(y(indList(pset)));
                d = max(y(indList(pset)));
                Areabb = (r-l+1) * (d-u+1);
                % Rectangularity
                if indListNum(zz,xx)/Areabb>0.8
                    cnt = cnt + 1;
                    VerticalMean = VerticalMean + (d-u+1);
                end
            end                                 
        end
    end    
    
    VerticalMean = VerticalMean / cnt;
    
    GridProposal = zeros(indMax,indMax);       
    
    for zz = 1:indMax
        for xx = 1:indMax
            
            hh = head(zz,xx);
            tt = tail(zz,xx);
            pset = hh:tt;              
            
            if (indListNum(zz,xx)<MinSize) && (indListNum(zz,xx)~=0)
                l = min(x(indList(pset)));
                r = max(x(indList(pset)));
                u = min(y(indList(pset)));
                d = max(y(indList(pset)));
                Areabb = (r-l+1) * (d-u+1);
                % Rectangularity & Vertical Length
                if (indListNum(zz,xx)/Areabb>0.4) && (abs(d-u+1-VerticalMean)<10)
                    GridProposal(zz,xx) = 1;
                end
            end                                 
        end
    end       
    
    GridProposal0 = GridProposal;
    
    GridProposal(GridProposal==0) = -1;    
    Smooth_para = 7;
    convM = ones(Smooth_para,Smooth_para);
    convM((Smooth_para+1)/2,(Smooth_para+1)/2) = 0;
    GridProposal = conv2(GridProposal,convM,'same');
    GridProposal(GridProposal<=0) = 0;
    GridProposal(GridProposal>0) = 1;    
    
    GroundPlane = zeros(height,width);               
  
    for zz = 1:indMax
        for xx = 1:indMax
            
            hh = head(zz,xx);
            tt = tail(zz,xx);
            pset = hh:tt;              
            
            if (GridProposal(zz,xx)==1) && (GridProposal0(zz,xx)==1)
                GroundPlane(indList(pset)) = 1;
            end                                 
        end
    end        
    
end
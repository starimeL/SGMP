function [ GroundPlane ] = GroundRefine( Edges,GroundPlane,Edge_Para )

    [height,width] = size(GroundPlane);

    for i = 2:height-1
        k = 0;
        for j = 1:width-1
            if (Edges(i,j)>Edge_Para) && GroundPlane(i,j) && (j>k)
                for k = j+1:width
                    if max([Edges(i-1,k),Edges(i,k),Edges(i+1,k)])<Edge_Para
                        break;
                    end
                    GroundPlane(i,k) = true;
                end
            end
        end
        k = width+1;
        for j = width:-1:2
            if (Edges(i,j)>Edge_Para) && GroundPlane(i,j) && (j<k)
                for k = j-1:-1:1
                    if max([Edges(i-1,k),Edges(i,k),Edges(i+1,k)])<Edge_Para
                        break;
                    end
                    GroundPlane(i,k) = true;
                end
            end
        end        
    end    

end


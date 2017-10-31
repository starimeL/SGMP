function LabelImg = ShowLabel(regions)
    %regions = uint16(regions);
    [height, width] = size(regions);
    LabelImg = zeros(height, width, 3);
    %RegionNum = 1+ max(regions(:));
%     LabelColor = zeros(RegionNum, 3);
%     for i = 1:RegionNum
%         LabelColor(i,:) = rand(1,3);
%     end
    load('LabelColor.mat');
    regions(find(regions==0)) = 255;
    for i = 1:height
        for j = 1:width
            LabelImg(i,j,:) = LabelColor(mod(regions(i,j)-1,8000)+1,:);
%             if (regions(i,j)==9)
%                 LabelImg(i,j,:) = [0 0 255];
%                 LabelColor(regions(i,j)+1,:)
%             end
        end
    end
    %LabelImg = uint8(round(LabelImg));
%     imshow(LabelImg);
end
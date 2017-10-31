function imgRgb = Convert2grayRGB(img)
    img = double(img);
    img = img ./ max(img(:));
    img = uint8(img*255);
    [H, W] = size(img);
    imgRgb = reshape(img, [H*W 1]);
    imgRgb = [imgRgb, imgRgb, imgRgb];
    imgRgb = reshape(imgRgb, [H W 3]);
end
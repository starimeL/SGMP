function [f, sx, sy, x0, y0, b] = GetCamPara_json(path)

    jsonStr= fileread(path);
    cell = parse_json(jsonStr);

    f = cell{1}.intrinsic.fx;
    sx = 1;
    sy = f/cell{1}.intrinsic.fy;
    x0 = cell{1}.intrinsic.u0/2;
    y0 = cell{1}.intrinsic.v0/2;
    b = cell{1}.extrinsic.baseline;
    
end

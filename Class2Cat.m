function [ groundConvert ] = Class2Cat( ground )

    ChangeM = zeros(50);
    ChangeM(7:10) = 7;
    ChangeM(11:16) = 11;
    ChangeM(17:20) = 20;
    ChangeM(21:22) = 21;
    ChangeM(23:23) = 23;
    ChangeM(24:25) = 24;
    ChangeM(26:33) = 26;
    ChangeM([1:6, 9:10, 14:16, 18, 29:30, 34]) = 34;

    ground(ground==0 | ground>34) = 34;
    ground(:) = ChangeM(ground(:)); 
    ground(ground==0 | ground>34) = 34;
    groundConvert = uint8(ground);

end


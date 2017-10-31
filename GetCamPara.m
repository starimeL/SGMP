function [f, sx, sy, x0, y0, b] = GetCamPara(path)

xDoc = xmlread(path);   % 读取文件  test.xml  

% 获取节点
fPOS = xDoc.getElementsByTagName('f').item(0); %从Slide节点集合获取第一个Slide节点，注意集合的索引已从0开始的
sxPOS = xDoc.getElementsByTagName('sx').item(0); 
syPOS = xDoc.getElementsByTagName('sy').item(0); 
x0POS = xDoc.getElementsByTagName('x0').item(0); 
y0POS = xDoc.getElementsByTagName('y0').item(0); 
bPOS = xDoc.getElementsByTagName('b').item(0); 

% 获取属性值，设置属性值，添加属性值
f = str2double(char(fPOS.getAttribute('value'))); %获取Slide1的Time属性,注意getTextContent()返回的是java.lang.String类型，使用char函数将它转化为MATLAB中的字符串类型
sx = str2double(char(sxPOS.getAttribute('value')));
sy = str2double(char(syPOS.getAttribute('value')));
x0 = str2double(char(x0POS.getAttribute('value')));
y0 = str2double(char(y0POS.getAttribute('value')));
b = str2double(char(bPOS.getAttribute('value')));

end

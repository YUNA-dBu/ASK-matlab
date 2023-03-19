%   作者：HCl
%   学校：NJUPT

function [outData] = ASK_PCMDecode(inputData)

n = length(inputData)/8;            %行数
Data = reshape(inputData,[8,n]);    %一维转二维

sig = 0;    %符号
par = 0;    %段落码
inside = 0; %段内码

mask = [0 16 32 64 128 256 512 1024];

for i=1:n
    sig = Data(1,i) * 2 - 1;
    par = Data(2,i)*4 + Data(3,i)*2 + Data(4,i) + 1;
    inside = (Data(5,i)*8 + Data(6,i)*4 + Data(7,i)*2 + Data(8,i));

    if par == 1
        Date_temp(i) = (sig * (mask(par) + inside)) / 2048;
    else
        Date_temp(i) = (sig * (mask(par) + 2^(par - 2) * inside)) / 2048;
    end
end

outData = Date_temp;
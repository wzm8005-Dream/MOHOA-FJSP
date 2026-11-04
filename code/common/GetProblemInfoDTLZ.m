%code reference link: https://mbd.pub/o/author-aG2Sl2xmaw==/work
%code reference link: https://mbd.pub/o/liang
function[Name,dim,numObj,final_lb,final_ub]=GetProblemInfoDTLZ(n)
switch n
    case 1
        Name='DTLZ1';%测试函数名称
        dim=7;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 2
        Name='DTLZ2';%测试函数名称
        dim=12;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 3
        Name='DTLZ3';%测试函数名称
        dim=12;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 4
        Name='DTLZ4';%测试函数名称
        dim=12;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 5
        Name='DTLZ5';%测试函数名称
        dim=12;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 6
        Name='DTLZ6';%测试函数名称
        dim=12;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 7
        Name='DTLZ7';%测试函数名称
        dim=22;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 8
        Name='DTLZ8';%测试函数名称
        dim=30;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限
    case 9
        Name='DTLZ9';%测试函数名称
        dim=30;%维度
        numObj=3;%目标个数
        final_lb = 0;%变量的下限
        final_ub = 1;%变量的上限

   

end
final_lb=final_lb.*ones(1,dim);
final_ub=final_ub.*ones(1,dim);
end
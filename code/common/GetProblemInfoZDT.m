function[Name,dim,numObj,final_lb,final_ub]=GetProblemInfoZDT(n)
switch n
    case 1
        Name='ZDT1';%测试函数名称
        dim=30;%维度
        numObj=2;%目标个数
        final_lb = 0.* ones(1, dim);%变量的下限
        final_ub = 1.* ones(1, dim);%变量的上限
    case 2
        Name='ZDT2';%测试函数名称
        dim=30;%维度
        numObj=2;%目标个数
        final_lb = 0.* ones(1, dim);%变量的下限
        final_ub = 1.* ones(1, dim);%变量的上限
    case 3
        Name='ZDT3';%测试函数名称
        dim=30;%维度
        numObj=2;%目标个数
        final_lb = 0.* ones(1, dim);%变量的下限
        final_ub = 1.* ones(1, dim);%变量的上限
    case 4
        Name='ZDT4';%测试函数名称
        dim=10;%维度
        numObj=2;%目标个数
        final_lb = [0 -5*ones(1,dim-1)];
        final_ub = [1 5*ones(1,dim-1)];
    case 5
        Name='ZDT6';%测试函数名称
        dim=10;%维度
        numObj=2;%目标个数
        final_lb = 0.* ones(1, dim);%变量的下限
        final_ub = 1.* ones(1, dim);%变量的上限
   
end
final_lb=final_lb.*ones(1,dim);
final_ub=final_ub.*ones(1,dim);
end
%% 传入的wolf是一个编码个体
function [machineTable,curJobTime]=sorting(machineTable,wolf,jobNum,jobInfo,operaVec,candidateMachine)
%% 生成OS整数序列
operaNum=sum(operaVec);
OS=[];
for i=1:jobNum
    OS=[OS,ones(1,operaVec(i))*i];
end
wolfOs=wolf(1:operaNum);
wolfMs=wolf(operaNum+1:2*operaNum);
[~,upIndex]=sort(wolfOs);
[~,osIndex]=sort(upIndex);
% sortedWolfOs=sort(wolfOs);
% [~,osIndex]=ismember(wolfOs,sortedWolfOs);
OS=OS(osIndex);                 % 将小数OS转成了fjsp中常用的整数OS
%% 主循环：依次循环每个染色体
operaRec=zeros(1,jobNum);   % 记录当前运行在每个Job的第几步
curJobTime=zeros(1,jobNum);   % 记录当前Job的上一道工序的结束时间
for i=1:sum(operaVec)
    curJob=OS(i);
    operaRec(curJob)=operaRec(curJob)+1;
    jobOpera=operaRec(curJob);
    jobMsIndex=sum(operaVec(1:curJob-1))+jobOpera;  % 确定当前job的当前工序在wolfMs的位置
    decode_JobMsIndex=round(1/(2*jobNum)*(wolfMs(jobMsIndex)+jobNum)*(length(candidateMachine{...
        curJob,jobOpera})-1)+1);
    machine=candidateMachine{curJob,jobOpera}(decode_JobMsIndex);
    %% 读取Machine的空闲时间段
    for j=1:length(machineTable{machine})
        % 寻找空闲时间块
        if isequal(machineTable{machine}(j).job,0)
            % 判断能否插入
            startT=max(machineTable{machine}(j).start,curJobTime(curJob));
            endT=startT+jobInfo{curJob}(jobOpera,machine);
            if endT<=machineTable{machine}(j).end           % 能插入
                insertion.start=startT;     % 插入时间块的起始时间
                insertion.end=endT;         % 插入时间块的结束时间
                a=combination(insertion,machineTable{machine}(j),curJob,jobOpera);
                movement=length(a)-1;
                % 循环插入：位置j则是要machineTable上要插入进去的块儿
                Len=length(machineTable{machine});
                % 移动原有块
                if ~isequal(Len,j)
                    for m=Len:-1:j+1
                        machineTable{machine}(m+movement).start=machineTable{machine}(m).start;
                        machineTable{machine}(m+movement).end=machineTable{machine}(m).end;
                        machineTable{machine}(m+movement).job=machineTable{machine}(m).job;
                        machineTable{machine}(m+movement).opera=machineTable{machine}(m).opera;
                    end
                end
                % 插入新块
                for m=1:length(a)
                    machineTable{machine}(j-1+m).start=a(m).start;
                    machineTable{machine}(j-1+m).end=a(m).end;
                    machineTable{machine}(j-1+m).job=a(m).job;
                    machineTable{machine}(j-1+m).opera=a(m).opera;
                end
                % 更新curJobTime
                curJobTime(curJob)=endT;
                break;
            end
        end
    end
    
end
end

%%   分块重组
function [a]=combination(insertion,block,job,opera)    
a=[];
if isequal(insertion.start,block.start)&&isequal(insertion.end,block.end)
    a.start=insertion.start;
    a.end=insertion.end;
    a.job=job;
    a.opera=opera;
elseif isequal(insertion.start,block.start)&&insertion.end<block.end
    a(1).start=insertion.start;
    a(1).end=insertion.end;
    a(1).job=job;
    a(1).opera=opera;
    a(2).start=insertion.end;
    a(2).end=block.end;
    a(2).job=0;
    a(2).opera=0;
elseif insertion.start>block.start&&isequal(insertion.end,block.end)
    a(1).start=block.start;
    a(1).end=insertion.start;
    a(1).job=0;
    a(1).opera=0;
    a(2).start=insertion.start;
    a(2).end=block.end;
    a(2).job=job;
    a(2).opera=opera;
elseif insertion.start>block.start&&insertion.end<block.end
    a(1).start=block.start;
    a(1).end=insertion.start;
    a(1).job=0;
    a(1).opera=0;
    a(2).start=insertion.start;
    a(2).end=insertion.end;
    a(2).job=job;
    a(2).opera=opera;
    a(3).start=insertion.end;
    a(3).end=block.end;
    a(3).job=0;
    a(3).opera=0;
end
end
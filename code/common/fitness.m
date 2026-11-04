function [f,machineTable]=fitness(pop,machineNum,jobNum,jobInfo,operaVec,candidateMachine,energy)
%% machineTable记录每个机器的工作时间表
% 建立结构体 workTable
workTable=[];
workTable.start=0;
workTable.end=Inf;
workTable.job=0;  % 0表示空闲
workTable.opera=0;
% 初始化machineTable
for i=1:machineNum
    machineTable{1,i}=workTable;
end
%% 解码排序
[machineTable,curJobTime]=sorting(machineTable,pop,jobNum,jobInfo,operaVec,candidateMachine);
%% 目标函数1：makespan
makespan=max(curJobTime);
%% 目标函数2：能耗
machine_work=zeros(machineNum,1);
machine_spare=zeros(machineNum,1);
for i=1:machineNum
    for j=1:length(machineTable{i})
        if isequal(machineTable{i}(j).end,inf)
            continue;
        end

        if isequal(machineTable{i}(j).job,0)
            machine_spare(i)=machine_spare(i)+(machineTable{i}(j).end-machineTable{i}(j).start);
        else
            machine_work(i)=machine_work(i)+(machineTable{i}(j).end-machineTable{i}(j).start);
        end
    end
end

consume_energy = energy.work(1: machineNum) * machine_work + energy.spare(1: machineNum) * machine_spare;

% 成本
consum_cost = energy.cost(1: machineNum) * machine_work;

%%
f{1}=[makespan, consume_energy, consum_cost];

end
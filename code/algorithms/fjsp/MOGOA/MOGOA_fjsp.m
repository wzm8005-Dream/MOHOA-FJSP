%_________________________________________________________________________________
%  Multi-objective Grasshopper Optimization Algorithm (MOGOA) source codes version 1.0
%
%  Developed in MATLAB R2016a
%
%  Author and programmer: Seyedali Mirjalili
%
%         e-Mail: ali.mirjalili@gmail.com
%                 seyedali.mirjalili@griffithuni.edu.au
%
%       Homepage: http://www.alimirjalili.com
%
%   Main paper:
%   S. Z. Mirjalili, S. Mirjalili, S. Saremi, H. Fatis, H. Aljarah, 
%   Grasshopper optimization algorithm for multi-objective optimization problems, 
%   Applied Intelligence, 2017, DOI: http://dx.doi.org/10.1007/s10489-017-1019-8
%____________________________________________________________________________________

function [Fbest,Xbest,Info] = MOGOA_fjsp(p,cfg,options)
Info=struct;
machineNum=p.MachineNum;jobNum=p.jobNum;jobInfo=p.jobInfo;operaVec=p.operaNumVec;candidateMachine=p.candidateMachine;energy=p.Energy;
% Parameters
N  = cfg.Population;
ArchiveMaxSize = 100;
max_iter  = cfg.Iterations;
% ObjectiveFunction= MultiObj.fun;

nVar = 2*sum(operaVec); 
dim = nVar;
lb = -jobNum * ones(1, nVar);       % 自变量下界
ub = jobNum * ones(1, nVar);        % 自变量上界
obj_no=3;%目标数目


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flag=0;
if (rem(dim,2)~=0)
    dim = dim+1;
    ub = [ub, 1];
    lb = [lb, 0];
    flag=1;
end


% 

Archive_X=zeros(100,dim);
Archive_F=ones(100,obj_no)*inf;

Archive_member_no=0;

%Initialize the positions of artificial whales
GrassHopperPositions=initialization(N,dim,ub,lb);

TargetPosition=zeros(dim,1);
TargetFitness=inf*ones(1,obj_no);

cMax=1;
cMin=0.00004;
%calculate the fitness of initial grasshoppers

for iter=1:max_iter
    for i=1:N
        
        Flag4ub=GrassHopperPositions(:,i)>ub';
        Flag4lb=GrassHopperPositions(:,i)<lb';
        GrassHopperPositions(:,i)=(GrassHopperPositions(:,i).*(~(Flag4ub+Flag4lb)))+ub'.*Flag4ub+lb'.*Flag4lb;
        
        % GrassHopperFitness(i,:)=ObjectiveFunction(GrassHopperPositions(:,i)');
        % [GrassHopperFitness(i,:), ~,~] = getMOFcn(FUN, GrassHopperPositions(:,i)', numObj);
        f_obj = fitness(GrassHopperPositions(:,i)', machineNum, jobNum, jobInfo, operaVec, candidateMachine, energy);
        GrassHopperFitness(i,:) = f_obj{1};


        if dominates(GrassHopperFitness(i,:),TargetFitness)
            TargetFitness=GrassHopperFitness(i,:);
            TargetPosition=GrassHopperPositions(:,i);
        end
        
    end
    
    [Archive_X, Archive_F, Archive_member_no]=UpdateArchive(Archive_X, Archive_F, GrassHopperPositions, GrassHopperFitness, Archive_member_no);
    
    if Archive_member_no>ArchiveMaxSize
        Archive_mem_ranks=RankingProcess(Archive_F, ArchiveMaxSize, obj_no);
        [Archive_X, Archive_F, Archive_mem_ranks, Archive_member_no]=HandleFullArchive(Archive_X, Archive_F, Archive_member_no, Archive_mem_ranks, ArchiveMaxSize);
    else
        Archive_mem_ranks=RankingProcess(Archive_F, ArchiveMaxSize, obj_no);
    end
    % Archive_mem_ranks=RankingProcess(Archive_F, ArchiveMaxSize, obj_no);
    index=RouletteWheelSelection(1./Archive_mem_ranks);
    if index==-1
        index=1;
    end
    
    TargetFitness=Archive_F(index,:);
    TargetPosition=Archive_X(index,:)';
    
    c=cMax-iter*((cMax-cMin)/max_iter); % Eq. (3.8) in the paper
    
    for i=1:N
        
        temp= GrassHopperPositions;
        
        for k=1:2:dim
            S_i=zeros(2,1);
            for j=1:N
                if i~=j
                    Dist=distance(temp(k:k+1,j), temp(k:k+1,i));
                    r_ij_vec=(temp(k:k+1,j)-temp(k:k+1,i))/(Dist+eps);
                    xj_xi=2+rem(Dist,2);
                       
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% % Eq. (3.2) in the paper 
                    s_ij=((ub(k:k+1)' - lb(k:k+1)') .*c/2)*S_func(xj_xi).*r_ij_vec;
                    S_i=S_i+s_ij;
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
            end
            S_i_total(k:k+1, :) = S_i;
            
        end
        
        X_new=c*S_i_total'+(TargetPosition)'; % Eq. (3.7) in the paper
        GrassHopperPositions_temp(i,:)=X_new';
    end
    % GrassHopperPositions
    GrassHopperPositions=GrassHopperPositions_temp';
    
     % display(num2str(iter));
    study.history('add',Archive_F);
end
Xbest=Archive_X;
Fbest=Archive_F;

end

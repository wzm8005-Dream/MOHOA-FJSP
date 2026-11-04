function [Fbest,Xbest,Info] = MOMA_functions(p,cfg,options)
Info=struct;
Max_iter=cfg.Iterations;SearchAgents_no=cfg.Population;FUN=p.Name;dim=p.D;numObj=p.M;lb=p.Lower;ub=p.Upper;

% Parameters
Np      = SearchAgents_no;
nPareto = 100;
MaxIt  = Max_iter;
% ObjectiveFunction= MultiObj.fun;
% getMOFcn(FUN, POS, numObj);
nVar    = dim;
LowerBound = lb(:)';%下限
UpperBound = ub(:)';%上限
% funcname = FUN;%问题名
% Objnum = numObj;%目标数目

ProblemSize=[1 nVar];       % Decision Variables Size
nPop=Np/2; nPopf=Np/2;       % Population Size (males and females)
g=0.8;                % Inertia Weight
gdamp=1;            % Inertia Weight Damping Ratio
a1=1.0;             % Personal Learning Coefficient
a2=1.5;  a3=1.5;           % Global Learning Coefficient
beta=2;             % Distance sight Coefficient
dance=0.77;          % Mutation Coefficient
dance_damp=0.99;    % Mutation Coefficient Damping Ratio
fl=0.77;                       % Random flight
fl_damp=0.99;
% Mating Parameters
nCrossover=20;  % Number of Parnets (Offsprings)
nMutation=round(0.5*nPop);        % Number of Mutants
mu=0.02;                                % Mutation Rate
% Velocity Limits
VelMax=1*(UpperBound-LowerBound)*5; VelMin=-VelMax;
%% Initialization
%run initial
empty_mayfly.Position=[];
empty_mayfly.Velocity=[];
empty_mayfly.Cost=[];
empty_mayfly.Best.Position=[];
empty_mayfly.Best.Cost=[];
empty_mayfly.Rank=[];
empty_mayfly.DominationSet=[];
empty_mayfly.DominatedCount=[];
empty_mayfly.CrowdingDistance=[];
Mayfly=repmat(empty_mayfly,nPop,1);
Mayflyf=repmat(empty_mayfly,nPopf,1);
for i=1:nPop
    % Initialize Male Position
    Mayfly(i).Position=unifrnd(LowerBound,UpperBound,ProblemSize);
    % Initialize Velocity
    Mayfly(i).Velocity=zeros(ProblemSize);
    % Evaluation
    % Mayfly(i).Cost=ObjectiveFunction(Mayfly(i).Position);
    [Mayfly(i).Cost,~,~]  = getMOFcn(FUN, Mayfly(i).Position, numObj);

    % Update Personal Best
    Mayfly(i).Best.Position=Mayfly(i).Position;
    Mayfly(i).Best.Cost=Mayfly(i).Cost;
    % Initialize female Position
    if i<=nPopf
        Mayflyf(i).Position=unifrnd(LowerBound,UpperBound,ProblemSize);
        Mayflyf(i).Velocity=zeros(ProblemSize);
        % Mayflyf(i).Cost=ObjectiveFunction(Mayflyf(i).Position);
        [Mayflyf(i).Cost,~,~]  = getMOFcn(FUN, Mayflyf(i).Position, numObj);

        Mayflyf(i).Best.Position=Mayflyf(i).Position;
        Mayflyf(i).Best.Cost=Mayflyf(i).Cost;
    end
end
% Merge
Pareto=[Mayfly;Mayflyf];
% Non-Dominated Sorting
[Pareto, F]=ParetoSorting(Pareto);
% Calculate Crowding Distance
Pareto=CalcCD(Pareto,F);
% Sort Population
Pareto=SortSolutions(Pareto);
Pareto=Pareto(F{1});
% Truncate
if numel(Pareto)>nPareto
    Pareto=Pareto(1:nPareto);
end
%% Mayfly Main Loop
for it=1:MaxIt
    for i=1:nPop
        leader=Pareto(randi(size(Pareto,2)));
        % Update Females
        if i<=nPopf
            if Dominates(Mayfly(i),Mayflyf(i))
                rmf=norm(Mayfly(i).Position-Mayflyf(i).Position);
                Mayflyf(i).Velocity = g*Mayflyf(i).Velocity ...
                    +a3*exp(-beta*rmf^2).*(Mayfly(i).Position-Mayflyf(i).Position);
            else
                e=unifrnd(-1,+1,ProblemSize);
                Mayflyf(i).Velocity = g*Mayflyf(i).Velocity+fl*(e);
            end
            % Apply Velocity Limits
            Mayflyf(i).Velocity = max(Mayflyf(i).Velocity,VelMin);
            Mayflyf(i).Velocity = min(Mayflyf(i).Velocity,VelMax);
            % Update Position
            Mayflyf(i).Position = Mayflyf(i).Position + Mayflyf(i).Velocity;%位置更新
            % Velocity Mirror Effect
            IsOutside=(Mayflyf(i).Position<LowerBound | Mayflyf(i).Position>UpperBound);
            Mayflyf(i).Velocity(IsOutside)=-Mayflyf(i).Velocity(IsOutside);
            % Apply Position Limits
            Mayflyf(i).Position = max(Mayflyf(i).Position,LowerBound);
            Mayflyf(i).Position = min(Mayflyf(i).Position,UpperBound);
            % Evaluation
            % Mayflyf(i).Cost=ObjectiveFunction(Mayflyf(i).Position);
            [Mayflyf(i).Cost,~,~]  = getMOFcn(FUN, Mayflyf(i).Position, numObj);

            Mayflyf(i).Best.Position=Mayflyf(i).Position;
            Mayflyf(i).Best.Cost=Mayflyf(i).Cost;
        end
        % Update Males
        % Update Velocity
        if Dominates(leader,Mayfly(i))
            rpbest=norm(Mayfly(i).Best.Position-Mayfly(i).Position);
            rgbest=norm(leader.Position-Mayfly(i).Position);
            Mayfly(i).Velocity = g*Mayfly(i).Velocity ...
                +a1*exp(-beta*rpbest^2).*(Mayfly(i).Best.Position-Mayfly(i).Position) ...
                +a2*exp(-beta*rgbest^2).*(leader.Position-Mayfly(i).Position);
        else
            e=unifrnd(-1,+1,ProblemSize);
            Mayfly(i).Velocity = g*Mayfly(i).Velocity+dance*(e);
        end
        % Apply Velocity Limits
        Mayfly(i).Velocity = max(Mayfly(i).Velocity,VelMin);
        Mayfly(i).Velocity = min(Mayfly(i).Velocity,VelMax);
        % Update Position
        Mayfly(i).Position = Mayfly(i).Position + Mayfly(i).Velocity;%位置更新
        % Velocity Mirror Effect
        IsOutside=(Mayfly(i).Position<LowerBound | Mayfly(i).Position>UpperBound);
        Mayfly(i).Velocity(IsOutside)=-Mayfly(i).Velocity(IsOutside);
        % Apply Position Limits
        Mayfly(i).Position = max(Mayfly(i).Position,LowerBound);
        Mayfly(i).Position = min(Mayfly(i).Position,UpperBound);
        % Evaluation
        % Mayfly(i).Cost=ObjectiveFunction(Mayfly(i).Position);
        [Mayfly(i).Cost,~,~]  = getMOFcn(FUN, Mayfly(i).Position, numObj);

        % Update Personal Best
        if Dominates(Mayfly(i),Mayfly(i).Best)
            Mayfly(i).Best.Position=Mayfly(i).Position;
            Mayfly(i).Best.Cost=Mayfly(i).Cost;
        elseif Dominates(Mayfly(i).Best,Mayfly(i))
            % Do Nothing
        else
            if rand<0.5
                Mayfly(i).Best.Position=Mayfly(i).Position;
                Mayfly(i).Best.Cost=Mayfly(i).Cost;
            end
        end
    end
    % MATE
    popc=repmat(empty_mayfly,nCrossover/2,2);
    for k=1:nCrossover/2
        % Select Parents
        i1=randi(numel(Pareto));
        i2=randi(numel(Pareto));
        %p1=Mayfly(i1).Best;
        %p2=Mayflyf(i2).Best;
        % Apply Crossover
        [popc(k,1).Position, popc(k,2).Position]=Crossover(Pareto(i1).Position,Pareto(i2).Position);
        % Evaluation
        popc(k,1).Position = max(popc(k,1).Position, LowerBound);
        popc(k,1).Position = min(popc(k,1).Position, UpperBound);
        % popc(k,1).Cost=ObjectiveFunction(popc(k,1).Position);
        [popc(k,1).Cost,~,~]  = getMOFcn(FUN, popc(k,1).Position, numObj);

        % Evaluation
        popc(k,2).Position = max(popc(k,2).Position, LowerBound);
        popc(k,2).Position = min(popc(k,2).Position, UpperBound);
        % popc(k,2).Cost=ObjectiveFunction(popc(k,2).Position);
        [popc(k,2).Cost,~,~]  = getMOFcn(FUN, popc(k,2).Position, numObj);

        popc(k,1).Best.Position = popc(k,1).Position;
        popc(k,1).Best.Cost = popc(k,1).Cost;
        popc(k,1).Velocity= zeros(ProblemSize);
        popc(k,2).Best.Position = popc(k,2).Position;
        popc(k,2).Best.Cost = popc(k,2).Cost;
        popc(k,2).Velocity= zeros(ProblemSize);
    end
    % break
    popc=popc(:);
    % Mutation
    popm=repmat(empty_mayfly,nMutation,1);
    for k=1:nMutation
        i=randi(numel(Pareto));
        popm(k)=Pareto(i);
        popm(k).Position=Mutate(popm(k).Position,mu,LowerBound,UpperBound);
        % Evaluation
        popm(k).Position = max(popm(k).Position, LowerBound);
        popm(k).Position = min(popm(k).Position, UpperBound);
        % popm(k).Cost=ObjectiveFunction(popm(k).Position);
        [popm(k).Cost,~,~]  = getMOFcn(FUN, popm(k).Position, numObj);

    end
    % Create Merged Population
    popc=[popc
        popm]; %#ok
    split=round((nCrossover/2+nMutation)/2);
    males=popc(1:split);
    Mayfly=[Mayfly
        males]; %#ok
    males=popc(split+1:nCrossover/2+nMutation);
    Mayflyf=[Mayflyf
        males]; %#ok
    % SHORT
    % Non-Dominated Sorting
    [Mayfly, F]=ParetoSorting(Mayfly);
    Mayfly=CalcCD(Mayfly,F);
    [Mayfly, F]=SortSolutions(Mayfly);
    [Mayflyf, F]=ParetoSorting(Mayflyf);
    Mayflyf=CalcCD(Mayflyf,F);
    [Mayflyf, F]=SortSolutions(Mayflyf);
    Mayfly=Mayfly(1:nPop);
    Mayflyf=Mayflyf(1:nPopf);
    Pareto=[Pareto
        Mayfly
        Mayflyf]; %#ok
    all=Pareto;
    % Non-Dominated Sorting
    [Pareto, F]=ParetoSorting(Pareto);
    % Calculate Crowding Distance
    Pareto=CalcCD(Pareto,F);
    % Sort Population
    [Pareto, F]=SortSolutions(Pareto);
    % Store F1
    Pareto=Pareto(F{1});
    % Truncate
    if numel(Pareto)>nPareto
        Pareto=Pareto(1:nPareto);
    end
    % Show Iteration Information
    % disp(['Iteration ' num2str(it) ': Number of Solution in repository = ' num2str(numel(Pareto))]);
    % Plot F1 Costs

    study.history('add',vertcat(Pareto.Cost));
    g=g*gdamp;
    dance = dance*dance_damp;
    fl = fl*fl_damp;
end

for i=1:size(Pareto,1)
    Fbest(i,:)=Pareto(i).Cost;
    Xbest(i,:)=Pareto(i).Position;
end



end

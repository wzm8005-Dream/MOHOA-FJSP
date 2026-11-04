%---------------------------佳点集初始化---------------------------%
% This function initialize the first population of search agents by good point set (GPS)
function Positions = gps_initialization(SearchAgents_no, dim, ub, lb)

    Boundary_no = size(ub, 2); % number of boundaries
    
    % If the boundaries of all variables are equal and user enter a single
    % number for both ub and lb
    if Boundary_no == 1
        Positions = good_point_set(SearchAgents_no, dim) .* (ub - lb) + lb;
    end
    
    % If each variable has a different lb and ub
    if Boundary_no > 1
        Good_points = good_point_set(SearchAgents_no, dim);
        for i = 1:dim
            ub_i = ub(i);
            lb_i = lb(i);
            Positions(:, i) = Good_points(:, i).* (ub_i - lb_i) + lb_i;
        end
    end

end

%% 佳点集生成函数
function [Good_points] = good_point_set(M, N)

    k = [1:M]' * ones(1, N);
    Ind = 1:N;
    
    prime1 = primes(100 * N);           % 产生素数
    [~, q] = find(prime1 >= (2 * N + 3)); % 找到满足条件的最小素数
    p = prime1(1, q(1));               % 最小素数
    
    tmp2 = 2 * cos((2 * pi .* Ind) / p);
    r = ones(M, 1) * tmp2;
    G_p = k.* r;
    
    Good_points = mod(G_p, 1);          % 佳点集

end

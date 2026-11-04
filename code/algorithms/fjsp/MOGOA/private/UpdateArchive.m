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

function [Archive_X_updated, Archive_F_updated, Archive_member_no]=UpdateArchive(Archive_X, Archive_F, Particles_X, Particles_F, Archive_member_no)

% Archive_X_temp=[Archive_X ; Particles_X'];
% Archive_F_temp=[Archive_F ; Particles_F];
% 
% % 初始化输出变量
% Archive_X_updated = [];  % 初始化为空
% Archive_F_updated = [];  % 初始化为空
% 
% o=zeros(1,size(Archive_F_temp,1));
% 
% for i=1:size(Archive_F_temp,1)
%     o(i)=0;
%     for j=1:i-1
%         if any(Archive_F_temp(i,:) ~= Archive_F_temp(j,:))
%             if dominates(Archive_F_temp(i,:),Archive_F_temp(j,:))
%                 o(j)=1;
%             elseif dominates(Archive_F_temp(j,:),Archive_F_temp(i,:))
%                 o(i)=1;
%                 break;
%             end
%         else
%             o(j)=1;
%             o(i)=1;
%         end
%     end
% end
% 
% Archive_member_no=0;
% index=0;
% for i=1:size(Archive_X_temp,1)
%     if o(i)==0
%         Archive_member_no=Archive_member_no+1;
%         Archive_X_updated(Archive_member_no,:)=Archive_X_temp(i,:);
%         Archive_F_updated(Archive_member_no,:)=Archive_F_temp(i,:);
%     else
%         index=index+1;
%         %         dominated_X(index,:)=Archive_X_temp(i,:);
%         %         dominated_F(index,:)=Archive_F_temp(i,:);
%     end
% end
    Archive_X_temp = [Archive_X; Particles_X'];
    Archive_F_temp = [Archive_F; Particles_F];

    nPop = size(Archive_F_temp, 1); % 总个体数
    o = zeros(1, nPop);             % 标记数组：1表示被支配，0表示非支配

    % ===== 判断支配关系 =====
    for i = 1 : nPop
        o(i) = 0; % 默认第i个非被支配
        for j = 1 : i - 1
            if all(Archive_F_temp(i,:) == Archive_F_temp(j,:))
                % 如果两个目标函数值完全相同：
                % 只标记后出现的解（j）为被支配（删除重复解）
                o(j) = 1;
            elseif any(Archive_F_temp(i,:) ~= Archive_F_temp(j,:))
                % 不相等时，判断支配关系
                if dominates(Archive_F_temp(i,:), Archive_F_temp(j,:))
                    % i支配j，j被支配
                    o(j) = 1;
                elseif dominates(Archive_F_temp(j,:), Archive_F_temp(i,:))
                    % j支配i，i被支配，终止j循环，i无需继续比较
                    o(i) = 1;
                    break;
                end
            end
            % 如果完全相等且不执行上述条件，则不做修改，防止漏判
        end
    end

    % ===== 根据标记筛除被支配解，保留非支配解 =====
    Archive_member_no = 0;
    Archive_X_updated = [];
    Archive_F_updated = [];

    for i = 1 : nPop
        if o(i) == 0
            Archive_member_no = Archive_member_no + 1;
            Archive_X_updated(Archive_member_no, :) = Archive_X_temp(i, :);
            Archive_F_updated(Archive_member_no, :) = Archive_F_temp(i, :);
        end
    end
    
    % ===== 兜底策略：避免归档为空 =====
    if Archive_member_no == 0
        % 若异常情况下全部个体被支配，则保留一个表现最好的个体（目标值最小和）
        [~, best_idx] = min(sum(Archive_F_temp, 2));
        Archive_member_no = 1;
        Archive_X_updated = Archive_X_temp(best_idx, :);
        Archive_F_updated = Archive_F_temp(best_idx, :);
    end


end
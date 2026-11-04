close all
clear
clc
MaxIt=100;
it=1:MaxIt;
mu=0.3.*((10*exp(-6))/(365)).^((it/(MaxIt/0.7)).^2)+0.2;%% 自适应变异率
figure
plot(mu)
xlabel('t')
ylabel('mu')

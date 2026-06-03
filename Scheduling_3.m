%Ejecutar algoritmo de despacho
clc
close all
clear all

r = 1;
freq = 2.6e9;
Pout = 10;
TTI = 10e-3;
fi = 0.1;
frames = 50;
buffer = 3;
rdg = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic
%Variando Qty_UE

%Qty_UE = [10, 20, 30, 40, 50, 60, 70, 80, 90, 100];
Qty_UE = [50, 100, 150, 200, 250];
%Qty_UE = [10, 20, 30, 40, 50];
%Qty_UE = [10,20, 30];
%Qty_UE = [50, 60, 70, 80, 90];
BW = 1.4e6;
Pkg = 5e6;

loops = 50;
ATP_RR_p = zeros(loops,length(Qty_UE));
ATP_BCQI_p = zeros(loops,length(Qty_UE));
ATP_BET_p = zeros(loops,length(Qty_UE));
ATP_PF_p = zeros(loops,length(Qty_UE));

F_T_RR_p = zeros(loops,length(Qty_UE));
F_T_BCQI_p = zeros(loops,length(Qty_UE));
F_T_BET_p = zeros(loops,length(Qty_UE));
F_T_PF_p = zeros(loops,length(Qty_UE));

Ef_RR_p = zeros(loops,length(Qty_UE));
Ef_BCQI_p = zeros(loops,length(Qty_UE));
Ef_BET_p = zeros(loops,length(Qty_UE));
Ef_PF_p = zeros(loops,length(Qty_UE));

delay_RR_p = zeros(loops,length(Qty_UE));
delay_BCQI_p = zeros(loops,length(Qty_UE));
delay_BET_p = zeros(loops,length(Qty_UE));
delay_PF_p = zeros(loops,length(Qty_UE));

outt_RR_p = zeros(loops,length(Qty_UE));
outt_BCQI_p = zeros(loops,length(Qty_UE));
outt_BET_p = zeros(loops,length(Qty_UE));
outt_PF_p = zeros(loops,length(Qty_UE));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Round Robin
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for iter = 1:loops

loop = 1;

for UE = Qty_UE

[atp, FT, Ef, delay, outt] = RR_function(Qty_UE(loop), r, freq, Pout, BW, TTI, buffer, Pkg, fi, frames, rdg);
loop = loop+1;
ATP_RR(loop-1) = atp;
F_T_RR(loop-1) = FT;
Ef_RR(loop-1) = Ef;
delay_RR(loop-1) = delay;
outt_RR(loop-1) = outt;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Best CQI
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = 1;

for UE = Qty_UE

[atp, FT, Ef, delay, outt] = BCQI_function(Qty_UE(loop), r, freq, Pout, BW, TTI, buffer, Pkg, fi, frames, rdg);
loop = loop+1;
ATP_BCQI(loop-1) = atp;
F_T_BCQI (loop-1) = FT;
Ef_BCQI(loop-1) = Ef;
delay_BCQI(loop-1) = delay;
outt_BCQI(loop-1) = outt;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Blind Equal Throughput
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = 1;

for UE = Qty_UE

[atp, FT, Ef, delay, outt] = BET_FAST_function(Qty_UE(loop), r, freq, Pout, BW, TTI, buffer, Pkg, fi, frames, rdg);
loop = loop+1;
ATP_BET(loop-1) = atp;
F_T_BET (loop-1) = FT;
Ef_BET(loop-1) = Ef;
delay_BET(loop-1) = delay;
outt_BET(loop-1) = outt;

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Proportional Fair
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
loop = 1;

for UE = Qty_UE

[atp, FT, Ef, delay, outt] = PF_FAST_function(Qty_UE(loop), r, freq, Pout, BW, TTI, buffer, Pkg, fi, frames, rdg);
loop = loop+1;
ATP_PF(loop-1) = atp;
F_T_PF (loop-1) = FT;
Ef_PF(loop-1) = Ef;
delay_PF(loop-1) = delay;
outt_PF(loop-1) = outt;

end

ATP_RR_p(iter,:) = ATP_RR;
ATP_BCQI_p(iter,:) = ATP_BCQI;
ATP_BET_p(iter,:) = ATP_BET;
ATP_PF_p(iter,:) = ATP_PF;

F_T_RR_p(iter,:) = F_T_RR;
F_T_BCQI_p(iter,:) = F_T_BCQI;
F_T_BET_p(iter,:) = F_T_BET;
F_T_PF_p(iter,:) = F_T_PF;

Ef_RR_p(iter,:) = Ef_RR;
Ef_BCQI_p(iter,:) = Ef_BCQI;
Ef_BET_p(iter,:) = Ef_BET;
Ef_PF_p(iter,:) = Ef_PF;

delay_RR_p(iter,:) = delay_RR;
delay_BCQI_p(iter,:) = delay_BCQI;
delay_BET_p(iter,:) = delay_BET;
delay_PF_p(iter,:) = delay_PF;

outt_RR_p(iter,:) = outt_RR;
outt_BCQI_p(iter,:) = outt_BCQI;
outt_BET_p(iter,:) = outt_BET;
outt_PF_p(iter,:) = outt_PF;


end

ATP_RR_x = mean(ATP_RR_p,1);
ATP_BCQI_x = mean(ATP_BCQI_p,1);
ATP_BET_x = mean(ATP_BET_p,1);
ATP_PF_x = mean(ATP_PF_p,1);

F_T_RR_x = mean(F_T_RR_p,1);
F_T_BCQI_x = mean(F_T_BCQI_p,1);
F_T_BET_x = mean(F_T_BET_p,1);
F_T_PF_x = mean(F_T_PF_p,1);

Ef_RR_x = mean(Ef_RR_p,1);
Ef_BCQI_x = mean(Ef_BCQI_p,1);
Ef_BET_x = mean(Ef_BET_p,1);
Ef_PF_x = mean(Ef_PF_p,1);

delay_RR_x = mean(delay_RR_p,1);
delay_BCQI_x = mean(delay_BCQI_p,1);
delay_BET_x = mean(delay_BET_p,1);
delay_PF_x = mean(delay_PF_p,1);

outt_RR_x = mean(outt_RR_p,1);
outt_BCQI_x = mean(outt_BCQI_p,1);
outt_BET_x = mean(outt_BET_p,1);
outt_PF_x = mean(outt_PF_p,1);

toc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de fairness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
plot(Qty_UE,F_T_RR_x, '-x');
title('Jains Index Fairness')
xlabel('Numero de UE')
ylabel('Fairness')
ylim([0 1])
grid on;
hold on;

plot(Qty_UE,F_T_BCQI_x, '-x');
plot(Qty_UE,F_T_BET_x, '-x');
plot(Qty_UE,F_T_PF_x, '-x');
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de thoughput
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
plot(Qty_UE,ATP_RR_x, '-x');
title('Throughput')
xlabel('Numero de UE')
ylabel('Throughput')
grid on;
hold on;

plot(Qty_UE,ATP_BCQI_x, '-x');
plot(Qty_UE,ATP_BET_x, '-x');
plot(Qty_UE,ATP_PF_x, '-x');
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de eficiencia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
plot(Qty_UE,Ef_RR_x, '-x');
title('Eficiencia espectral (bps/Hz)')
xlabel('Numero de UE')
ylabel('Eficiencia Espectral')
grid on;
hold on;

plot(Qty_UE,Ef_BCQI_x, '-x');
plot(Qty_UE,Ef_BET_x, '-x');
plot(Qty_UE,Ef_PF_x, '-x');
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de delay
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
plot(Qty_UE,delay_RR_x, '-x');
title('Delay (s)')
xlabel('Numero de UE')
ylabel('Delay (s)')
grid on;
hold on;

plot(Qty_UE,delay_BCQI_x, '-x');
plot(Qty_UE,delay_BET_x, '-x');
plot(Qty_UE,delay_PF_x, '-x');
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de outtage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
%plot(Qty_UE,out_RR, '-o');
%bar(Qty_UE, outt_RR);
bar( Qty_UE, [outt_RR_x; outt_BCQI_x; outt_BET_x; outt_PF_x] )
title('Probabilidad de interrupción (%)')
xlabel('Numero de UE')
ylabel('Porcentaje (s)')
grid on;
hold on;

%plot(Qty_UE,out_BCQI, '-o');
%bar(Qty_UE, outt_BCQI);
%plot(Qty_UE,out_BET, '-o');
%bar(Qty_UE, outt_BET);
%plot(Qty_UE,out_PF, 'o');
%bar(Qty_UE, outt_PF);
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Grafica de sensitividad throughput v fairness
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure()
set(gcf,'Color','w')
plot(ATP_RR_x,F_T_RR_x, '-x');
title('Throughput v Fairness')
xlabel('Throughput')
ylabel('Fairness')
grid on;
hold on;

plot(ATP_BCQI_x,F_T_BCQI_x, '-x');
plot(ATP_BET_x,F_T_BET_x, '-x');
plot(ATP_PF_x,F_T_PF_x, '-x');
legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')

hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tic
% %Variando BW
% 
% BW = [1.4e6, 3e6, 5e6, 10e6, 15e6, 20e6];
% %Qty_UE = [50, 100, 150, 200, 250];
% %Qty_UE = [10, 20, 30, 40, 50];
% Qty_UE = 50;
% Pkg = 50e6;
% 
% ATP_RR = 0;
% F_T_RR = 0;
% Ef_RR = 0;
% delay_RR = 0;
% outt_RR = 0;
% ATP_BCQI = 0;
% F_T_BCQI = 0;
% Ef_BCQI = 0;
% delay_BCQI = 0;
% outt_BCQI = 0;
% ATP_BET = 0;
% F_T_BET = 0;
% Ef_BET = 0;
% delay_BET = 0;
% outt_BET = 0;
% ATP_PF = 0;
% F_T_PF = 0;
% Ef_PF = 0;
% delay_PF = 0;
% outt_PF = 0;
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Round Robin
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop = 1;
% 
% for UE = BW
% 
% [atp, FT, Ef, delay, outt] = RR_function(Qty_UE, r, freq, Pout, BW(loop), TTI, buffer, Pkg, fi, frames);
% loop = loop+1;
% ATP_RR(loop-1) = atp;
% F_T_RR(loop-1) = FT;
% Ef_RR(loop-1) = Ef;
% delay_RR(loop-1) = delay;
% outt_RR(loop-1) = outt;
% 
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Best CQI
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop = 1;
% 
% for UE = BW
% 
% [atp, FT, Ef, delay, outt] = BCQI_function(Qty_UE, r, freq, Pout, BW(loop), TTI, buffer, Pkg, fi, frames);
% loop = loop+1;
% ATP_BCQI(loop-1) = atp;
% F_T_BCQI (loop-1) = FT;
% Ef_BCQI(loop-1) = Ef;
% delay_BCQI(loop-1) = delay;
% outt_BCQI(loop-1) = outt;
% 
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Blind Equal Throughput
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop = 1;
% 
% for UE = BW
% 
% [atp, FT, Ef, delay, outt] = BET_FAST_function(Qty_UE, r, freq, Pout, BW(loop), TTI, buffer, Pkg, fi, frames);
% loop = loop+1;
% ATP_BET(loop-1) = atp;
% F_T_BET (loop-1) = FT;
% Ef_BET(loop-1) = Ef;
% delay_BET(loop-1) = delay;
% outt_BET(loop-1) = outt;
% 
% end
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Proportional Fair
% %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop = 1;
% 
% for UE = BW
% 
% [atp, FT, Ef, delay, outt] = PF_FAST_function(Qty_UE, r, freq, Pout, BW(loop), TTI, buffer, Pkg, fi, frames);
% loop = loop+1;
% ATP_PF(loop-1) = atp;
% F_T_PF (loop-1) = FT;
% Ef_PF(loop-1) = Ef;
% delay_PF(loop-1) = delay;
% outt_PF(loop-1) = outt;
% 
% end
% 
% toc
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de fairness
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% plot(BW,F_T_RR, '-x');
% title('Jains Index Fairness')
% xlabel('Ancho de Banda')
% ylabel('Fairness')
% ylim([0 1])
% grid on;
% hold on;
% 
% plot(BW,F_T_BCQI, '-x');
% plot(BW,F_T_BET, '-x');
% plot(BW,F_T_PF, '-x');
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de thoughput
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% plot(BW,ATP_RR, '-x');
% title('Throughput')
% xlabel('Numero de UE')
% ylabel('Throughput')
% grid on;
% hold on;
% 
% plot(BW,ATP_BCQI, '-x');
% plot(BW,ATP_BET, '-x');
% plot(BW,ATP_PF, '-x');
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de eficiencia
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% plot(BW,Ef_RR, '-x');
% title('Eficiencia espectral (bps/Hz)')
% xlabel('Numero de UE')
% ylabel('Eficiencia Espectral')
% grid on;
% hold on;
% 
% plot(BW,Ef_BCQI, '-x');
% plot(BW,Ef_BET, '-x');
% plot(BW,Ef_PF, '-x');
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de delay
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% plot(BW,delay_RR, '-x');
% title('Delay (s)')
% xlabel('Numero de UE')
% ylabel('Delay (s)')
% grid on;
% hold on;
% 
% plot(BW,delay_BCQI, '-x');
% plot(BW,delay_BET, '-x');
% plot(BW,delay_PF, '-x');
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de outtage
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% %plot(Qty_UE,out_RR, '-o');
% %bar(Qty_UE, outt_RR);
% bar( BW, [outt_RR; outt_BCQI; outt_BET; outt_PF] )
% title('Probabilidad de interrupción (%)')
% xlabel('Numero de UE')
% ylabel('Porcentaje (s)')
% grid on;
% hold on;
% 
% %plot(Qty_UE,out_BCQI, '-o');
% %bar(Qty_UE, outt_BCQI);
% %plot(Qty_UE,out_BET, '-o');
% %bar(Qty_UE, outt_BET);
% %plot(Qty_UE,out_PF, 'o');
% %bar(Qty_UE, outt_PF);
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %
% %   Grafica de sensitividad throughput v fairness
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% figure()
% set(gcf,'Color','w')
% plot(ATP_RR,F_T_RR, '-x');
% title('Delay (s)')
% xlabel('Throughput')
% ylabel('Fairness')
% grid on;
% hold on;
% 
% plot(ATP_BCQI,F_T_BCQI, '-x');
% plot(ATP_BET,F_T_BET, '-x');
% plot(ATP_PF,F_T_PF, '-x');
% legend('Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair')
% 
% hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Guardar resultados en una tabla
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% UserEq = Qty_UE;
% Frecuencia = freq;
% Radio = r;
% Potencia = Pout;
% Bandwidth = BW;
% Pkg_size = Pkg;
% Frames = frames;
% Buffer = buffer;
% 
% Scheduler = {'Round Robin';'Best CQI';'Blind Equal Throughput';'Proportional Fair'};
% Fairness = [F_T_RR;F_T_BCQI;F_T_BET;F_T_PF];
% Throughput = [ATP_RR;ATP_BCQI;ATP_BET;ATP_PF];
% Eficiencia = [Ef_RR;Ef_BCQI;Ef_BET;Ef_PF];
% Delay = [delay_RR; delay_BCQI; delay_BET; delay_PF];
% Outage = [outt_RR; outt_BCQI; outt_BET; outt_PF];
% 
% Data = table(UserEq, Frecuencia, Radio, Potencia, Bandwidth, Pkg_size, Frames, Buffer);
% T = table(Scheduler,Fairness,Throughput,Eficiencia,Delay,Outage);
% 
% writetable(Data,sprintf('Sim_UE%d-%d_%g_%g_%g_%d_%d.xlsx',Qty_UE(1), Qty_UE(length(Qty_UE)),freq, BW, Pkg, frames, buffer),'WriteRowNames',true, 'Sheet', 'Datos')
% writetable(T,sprintf('Sim_UE%d-%d_%g_%g_%g_%d_%d.xlsx',Qty_UE(1), Qty_UE(length(Qty_UE)),freq, BW, Pkg, frames, buffer),'WriteRowNames',true, 'Sheet', 'Resultados')

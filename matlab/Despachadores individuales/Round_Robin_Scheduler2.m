clc
close all
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Algoritmo de despacho Round Robin
% 
%   LTE frame structure
%   - Un RB esta compuesto por 12 subcarriers de 15KHz c/u
%   - Y 7 simbolos OFDM (Lo cual es un slot y tiene una duracion de 0.5ms)
%   - 12 subcarriers * 7 simbolos OFDM = 84 resource elements en un RB
%   - Un simbolo son los 12 subcarriers en 0.5ms/7 de tiempo
%   - Un frame son 10ms en un ancho de banda determinado (1.4, 3, 5, 10, 15
%   o 20MHz)
%   - https://helpfiles.keysight.com/csg/89600B/Webhelp/Subsystems/lte/content/lte_overview.htm
%
%   5G NR frame structure
%   - Ancho de banda variable del RB gracias al subcarrier spacing
%   - Latencia dismuinuya en medida que aumenta el SCS
%   - https://www.3g4g.co.uk/5G/5Gtech_video0022_01.pdf
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tic

% Se definen los UE en coordenadas XYZ. El gNB se ubica en el centro y en
% el suelo
% gNB(0,0,0);

%UE = [2 1 1 ; 3 0 0; 3 0 1];

%Modificar solamente cantidad de UE
UEs = 20;
Qty_UE = UEs;
r = 1;  %radio de la celda
%Qty_UE = round(2*pi*r^2);

%Generacion de distancias de forma aleatoria
d = r*rand(1,Qty_UE);     %Generacion de distancias con distribucion uniforme
%d = r*abs(randn(1,Qty_UE));   %Generacion de distancias con distribucion normal

%d = [0.5 1 1.5 2 2.5]; %Debug
%d = [0.2858 0.7572 0.7537 0.3804 0.5678]; %Debug

% Frecuencia a la que se realiza la comunicacion para el modelo de canal
% https://es.wikipedia.org/wiki/Bandas_de_frecuencias_LTE
freq = 2.6e9;

%Potencia de transmisión del UE al gNB en dBm
Pout = 0;
%disp('Potencia con la que transmite el UE en dBm')
%disp(Pout)

% Se ingresan los datos del gNB a la funcion del modelo de canal.
pot = Modelo_de_canal(freq, d, Pout);   %calcular distancia
%disp('Potencia recibida por la gNB en dBm')
%disp(pot)
%RXGn = 10; % Ganancia en dB del amplificador del UE en dB. No se usa

Tn = -174;      % Ruido termico 174dB/Hz
BW = 20e6;      % 1.4, 3, 5, 10, 15 o 20MHz el BW del canal
TTI = 10e-3;    % Tiempo de un frame en LTE
SC = 12;        % Numero de subcarriers
SCS = 15e3;     %Subcarrier spacing de 15KHz en LTE (fijo)
slot = 0.5e-3;  %Duracion de un slot

%https://helpfiles.keysight.com/csg/89600B/Webhelp/Subsystems/lte/content/lte_overview.htm
%https://www.rfwireless-world.com/calculators/LTE-Resource-Block-Calculator.html
RBxFrame = (BW/1e6)*5*20; %20 slots en un frame de 10ms

%Variable para indicar si es buffer finito(1), infinito (0) o dinamico (2)
%o dinamico random (3)
frames = 50;
Pkg = 1e6;
buffer = 5;
var_UE = UEs*0.1; %Desviacion estandar de la generacion de usuarios

if(buffer == 1)
    Ps = Pkg * ones(1, Qty_UE);
    var_lg = 15;
elseif(buffer == 2)
    var_lg = frames + 1;
    Ps = Pkg * ones(1, Qty_UE);
elseif(buffer == 3)
    var_lg = frames + 1;
    Ps = Pkg*rand(1,Qty_UE);
else
    var_lg = frames + 1;
    Ps = Inf(1,Qty_UE);
end

%Bandera que indica que ya terminaron de atenderse todos los usuarios
f = 0;

vSNR = zeros(Qty_UE, RBxFrame);
data = zeros(Qty_UE, RBxFrame);
contRB = 0;
sumData = zeros(1,Qty_UE);
UE_time = zeros(1,Qty_UE);
UE_start = zeros(1,Qty_UE);
FN = Qty_UE * 0.1;
%FRR = zeros(1,RBxFrame);
UE_time = zeros(1,Qty_UE);
UE_tstart = zeros(1,Qty_UE);
UE_tend = zeros(1, Qty_UE);
UE_tp = zeros(1, Qty_UE);
RB_UE = zeros(Qty_UE,1);

active_UE = 0;
numTTI = 0;
Active_QtyUE = Qty_UE;
data_final = 0;

if(buffer == 4)
    gtp = zeros(Qty_UE*5,var_lg);
else
    gtp = zeros(Qty_UE,var_lg);
end

%gF = zeros(Qty_UE,var_lg);
gF = zeros(1,Qty_UE);

while(f == 0)

    %Cambiar cantidad de usuarios en cada TTI buffer infinito
    if(buffer == 4)
        Qty_UE = round(normrnd(UEs,var_UE));
        Ps = Inf(1,Qty_UE);
        vSNR = zeros(Qty_UE, RBxFrame);
        data = zeros(Qty_UE, RBxFrame);

        %d = r*(abs(normrnd(1,Qty_UE)));
        d = r*rand(1,Qty_UE);
        pot = Modelo_de_canal(freq, d, Pout);   %calcular distancia
        Ps = Inf(1,Qty_UE);
        sumData = zeros(1,Qty_UE);
        RB_UE = zeros(Qty_UE,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif(buffer == 5)
        Active_QtyUE = Qty_UE - length(find(vSNR(:,1) == -999));
        old = 0;
        while(old<Active_QtyUE)
            old = round(normrnd(UEs,var_UE));
        end
        Qty_UE = Qty_UE+old-Active_QtyUE;
        if(numTTI == 0)
            d = r*rand(1,Qty_UE);
            pot = Modelo_de_canal(freq, d, Pout);   %calcular distancia
            sumData = zeros(1,Qty_UE);
            %Ps = Pkg*rand(1,Qty_UE);
            Ps =Pkg*ones(1,Qty_UE);
        else
            d_aux = d;
            pot_aux = pot;
            sumData_aux = sumData;
            Ps_aux = Ps;
            d = zeros(1,Qty_UE);
            pot = zeros(1,Qty_UE);
            sumData = zeros(1,Qty_UE);
            Ps = zeros(1,Qty_UE);
            for u = 1:Qty_UE
                if(u>length(d_aux))
                    d(u) = r*rand;
                    pot(u) = Modelo_de_canal(freq, d(u), Pout);   %calcular distancia
                    %Ps(u) = Pkg*rand;
                    Ps(u) = Pkg;
                    sumData(u) = 0;
                else
                    d(u) = d_aux(u);
                    pot(u) = pot_aux(u);
                    sumData(u) = sumData_aux(u);
                    Ps(u) = Ps_aux(u);
                end
            end 
        end
        UE_done = find(vSNR(:,1) == -999);
        vSNR = zeros(Qty_UE, RBxFrame);
        data = zeros(Qty_UE, RBxFrame);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if(buffer~=5)
        UE_done = find(vSNR == -999);
    end
    RR = zeros(1,RBxFrame);
    dataxTTI = zeros(1,Qty_UE);

for w = 1:RBxFrame
    I = abs(normrnd(0, FN, [1, Qty_UE]));
    %I = 0; %Debug
    SNR = pot-(Tn+mag2db(BW)) - I; %SNR siempre debe degradar la señal
    vSNR(:,w) = SNR;
end

vSNR(UE_done,:) = -999;
%disp('SNR en dB con el cual se calcula el CQI de cada RB')
%disp(vSNR)

numTTI = numTTI + 1;

%**************************************************************************
%******************Loop para asignar recursos en un Frame******************
%**************************************************************************

for k = 1:RBxFrame

    mSNR = sprintf('SNR en RB %d',k);
    %disp(mSNR)
    %disp(vSNR(:,k))

    while(1)
        if(active_UE+1 > Qty_UE)
            active_UE = 0; %Error de SNR donde se quiere alojar un UE con numero 0
        end
        if(vSNR(active_UE+1,:) ~= -999)
            active_UE = active_UE + 1;
            break;
        else
            active_UE = active_UE + 1;
        end
    end

    %disp("Siguiente usuario a despachar:")
    %disp(active_UE)

    SNRenRB = vSNR(:,k);
    SNR_UE = SNRenRB(active_UE);

    %Funcion de CQI
    bRE = CQI(SNR_UE, BW);
    contRB = contRB+1;

    data(active_UE, k) = bRE*84; %El 84? 84 RE en un RB de LTE
    %disp(data)

    sumData(active_UE) = sumData(active_UE) + data(active_UE,k);
    dataxTTI(active_UE) = dataxTTI(active_UE) + data(active_UE,k);
    %UE_tp(active_UE) = UE_tp(Active_QtyUE) + (data(active_UE,k)/TTI);
    %%RB_UE(active_UE) = RB_UE(active_UE)+1;

    %disp("Suma de datos por usuario")
    %disp(sumData);

    if sumData(active_UE) >= Ps(active_UE)
        %disp("DONE")
        vSNR(active_UE,:) = -999;
        UE_tend(active_UE) = numTTI*TTI;
        if(buffer == 2 || buffer == 3)
            Qty_UE = Qty_UE + 1;
            d2 = r*rand;
            for w = 1:RBxFrame
                I = abs(normrnd(0, FN));
                %I = 0;
                pot2 = Modelo_de_canal(freq, d2, Pout);
                SNR2 = pot2-(Tn+mag2db(BW)) - I; %SNR siempre debe degradar la señal
                vSNR2(w) = SNR2;
            end
            pot(Qty_UE) = pot2;
            vSNR(Qty_UE, :) = vSNR2;
            data(Qty_UE, :) = zeros(1,RBxFrame);
            sumData(Qty_UE) = 0;
            hdata(Qty_UE,:) = zeros(1,numTTI);
            dataxTTI(Qty_UE) = 0;
            gtp(Qty_UE, :) = zeros(1,var_lg);
            UE_tstart(Qty_UE) = (numTTI-1)*TTI;
            UE_tend(Qty_UE) = Inf;
            UE_tp(Qty_UE) = 0;
            RB_UE(Qty_UE) = 0;
            
            if(buffer == 3)
                Ps(Qty_UE) = Pkg*rand;
            else
                Ps = Pkg * ones(1, Qty_UE);
            end
            %Active_QtyUE = Qty_UE - length(find(vSNR(:,1) == -999));
        end
        %Active_QtyUE = Qty_UE - length(find(vSNR(:,1) == -999));
    end

    DONE = sumData>=Ps;
    f = prod(DONE);

    if(f == 1)
        break;
    end

    RR(k) = active_UE;

end

    if(buffer == 4)
        data_final = data_final + sum(sumData);
    else
 
        for st = 1:Qty_UE
             C(st) = {sprintf('UE %d',st)};
        % 
        %     if(find(UE_done == st))
        %         UE_tp(st) = sumData(st)/(UE_time(st));
        %     else
        %         UE_tp(st) = sumData(st)/abs(UE_tstart(st)-(numTTI*TTI));
        %     end
        end
        str = string(C);
        %UE_time = abs(UE_tend-UE_tstart);
    end

%**************************************************************************
%**************************************************************************

%disp(RR);

%FRR es la variable que tiene la matriz de todos los recursos asignados
FRR(numTTI,:) = RR; 

%Throughput
tp = dataxTTI / TTI;
%atp = sum(sumData) / (TTI * numTTI); 
%gtp(:,numTTI+1) = tp;

%disp("Throughput en b/s")
%disp(tp);

%hdata(:,numTTI+1) = sumData;

%Fairness segun Jains index
%REVISAR
F = (sum(dataxTTI))^2 / ((Active_QtyUE) * sum(dataxTTI.^2));
%gF(:,numTTI+1) = F;
gF(numTTI) = F;

%disp("Fairness")
%disp(F)

%Condicion para buffer infinito
if(buffer ~=1 && numTTI>=frames)
    f = 1;
end

end

%atp = data_final/(numTTI*TTI);
atp = sum(sumData)/(numTTI*TTI);

disp("Tiempo transcurrido en s")
disp(numTTI*TTI);

%disp("Throughput en todos los TTI")
%disp(gtp)

%disp("Fairness en todos los TTI")
%disp(gF)

disp("Throughput de la red (b/s)")
disp(atp)

%Fairness según la métrica de Jain
%FT = (data_final)^2 / ((Qty_UE) * (data_final.^2));
FT = mean(gF);
disp('Jains Index Fairness')
disp(FT)

Ef = ((sum(sumData))/(numTTI*TTI)) / BW;
disp('Eficiencia espectral (bps/Hz)')
disp(Ef)

toc

% y = 0:TTI:(length(gF)-1)*TTI;

%Grafica de Throughput

% figure(1)
% set(gcf,'Color','w')
% plot(y,gtp);
% %plot(y, gtp(1:Qty_UE, 1:numTTI+1)); % Asegurarse de graficar todos los usuarios
% title('Throughput por usuario')
% xlabel('Tiempo (s)')
% ylabel('Throughput (b/s)')
% legend(str);
% grid on;

%Grafica de Fairness

% figure(2)
% set(gcf,'Color','w')
% p = plot(y,gF);
% title('Jains Index Fairness')
% xlabel('TTI')
% ylabel('Fairness')
% grid on;

%Grafica de datos historico
% figure(3)
% set(gcf,'Color','w')
% plot(y,hdata, 'Marker','.');
% title('Round Robin')
% xlabel('Tiempo (s)')
% ylabel('Datos (bits)')
% %ylim([0 12e7])
% legend(str);
% grid on;

% Nueva gráfica de Throughput vs Fairness
% figure(4)
% set(gcf,'Color','w')
% plot(gF, gtp, 'o');
% title('Throughput vs Fairness')
% ylabel('Throughput (b/s)')
% xlabel('Fairness (Jains Index)')
% grid on;

% figure(5)
% set(gcf,'Color','w')
% histogram(UE_time,0:0.1:numTTI*TTI)
% title('Histograma de tiempo por UE')
% ylabel('Cantidad de UEs')
% xlabel('Tiempo (s)')
% grid on;
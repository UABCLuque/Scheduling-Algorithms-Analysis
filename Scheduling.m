% Ejecutar algoritmo de despacho y comparar schedulers
clc; 
close all; 
clear all;

% Parametros de simulacion
r = 1;
freq = 2.6e9;
Pout = 10;
TTI = 10e-3;
fi = 0.1;
frames = 5;
buffer = 3;
rdg = 2;

% Parametros para los barridos
Qty_UE_vec = [50, 100, 150, 200, 250];
BW_values = [1.4e6, 3e6, 5e6];
Pkg_values = [1e6, 5e6, 10e6];

% Valores base para el 2do barrido
baseline_BW = BW_values(1);
baseline_Pkg = 5e6;
baseline_Qty = 100;

algNames = {'Round Robin', 'Best CQI', 'Blind Equal Throughput', 'Proportional Fair'};
algoCalls = {@RR_function, @BCQI_function, @BET_FAST_function, @PF_FAST_function};
nAlg = numel(algoCalls);

% Arrays donde se alojaran los resultados
% Barrido de Qty_UE (con BW y Pkg fijos)
nQty = numel(Qty_UE_vec);
ATP_qty = zeros(nAlg, nQty);
FT_qty = zeros(nAlg, nQty);
Ef_qty = zeros(nAlg, nQty);
delay_qty = zeros(nAlg, nQty);
outt_qty = zeros(nAlg, nQty);

% Barrido de BW (con Qty_UE y Pkg fijos)
nBW = numel(BW_values);
ATP_bw = zeros(nAlg, nBW);
FT_bw = zeros(nAlg, nBW);
Ef_bw = zeros(nAlg, nBW);
delay_bw = zeros(nAlg, nBW);
outt_bw = zeros(nAlg, nBW);

% Barrido de packet size (con Qty_UE y BW fijos)
nPkg = numel(Pkg_values);
ATP_pkg = zeros(nAlg, nPkg);
FT_pkg = zeros(nAlg, nPkg);
Ef_pkg = zeros(nAlg, nPkg);
delay_pkg = zeros(nAlg, nPkg);
outt_pkg = zeros(nAlg, nPkg);

% Se itera sobre cada valor de Qty_UE y se llama a cada algoritmo para obtener los resultados
for i = 1:nQty
    Qty_UE = Qty_UE_vec(i);
    for a = 1:nAlg
        [ATP_qty(a,i), FT_qty(a,i), Ef_qty(a,i), delay_qty(a,i), outt_qty(a,i)] = ...
            algoCalls{a}(Qty_UE, r, freq, Pout, baseline_BW, TTI, buffer, baseline_Pkg, fi, frames, rdg);
    end
end

% Se itera sobre cada valor de BW y se llama a cada algoritmo para obtener los resultados
for i = 1:nBW
    BW = BW_values(i);
    for a = 1:nAlg
        [ATP_bw(a,i), FT_bw(a,i), Ef_bw(a,i), delay_bw(a,i), outt_bw(a,i)] = ...
            algoCalls{a}(baseline_Qty, r, freq, Pout, BW, TTI, buffer, baseline_Pkg, fi, frames, rdg);
    end
end

% Se itera sobre cada valor de packet size y se llama a cada algoritmo para obtener los resultados
for i = 1:nPkg
    Pkg = Pkg_values(i);
    for a = 1:nAlg
        [ATP_pkg(a,i), FT_pkg(a,i), Ef_pkg(a,i), delay_pkg(a,i), outt_pkg(a,i)] = ...
            algoCalls{a}(baseline_Qty, r, freq, Pout, baseline_BW, TTI, buffer, Pkg, fi, frames, rdg);
    end
end

% -------------------------------------------------------------------------
% Throughput vs fairness plot para el barrido de Qty_UE
% -------------------------------------------------------------------------
figure('Color','w');
markers = {'-o','-s','-^','-d'};
for a = 1:nAlg
    plot(ATP_qty(a,:), FT_qty(a,:), markers{a}, 'LineWidth', 1.5, 'DisplayName', algNames{a});
    hold on;
end
xlabel('Throughput (bps)');
ylabel('Fairness (Jain''s index)');
title('Throughput vs Fairness for Qty_{UE} sweep');
grid on;
legend('Location','best');
hold off;

% -------------------------------------------------------------------------
% Subplots de cada metrica vs Qty_UE para cada despachador
% Aqui se varia el Qty_UE manteniendo fijo el BW y el packet size
% -------------------------------------------------------------------------
figure('Color','w');
subplot(2,2,1);
for a = 1:nAlg
    plot(Qty_UE_vec, ATP_qty(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Qty_{UE}'); ylabel('Throughput (bps)');
title('Throughput vs Qty_{UE}');
grid on;

subplot(2,2,2);
for a = 1:nAlg
    plot(Qty_UE_vec, FT_qty(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Qty_{UE}'); ylabel('Fairness');
title('Fairness vs Qty_{UE}');
grid on;

subplot(2,2,3);
for a = 1:nAlg
    plot(Qty_UE_vec, Ef_qty(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Qty_{UE}'); ylabel('Spectral efficiency (bps/Hz)');
title('Efficiency vs Qty_{UE}');
grid on;

subplot(2,2,4);
for a = 1:nAlg
    plot(Qty_UE_vec, delay_qty(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Qty_{UE}'); ylabel('Delay (s)');
title('Delay vs Qty_{UE}');
grid on;
legend(algNames, 'Location', 'bestoutside');

% -------------------------------------------------------------------------
% Outage vs Qty_UE
% -------------------------------------------------------------------------
figure('Color','w');
for a = 1:nAlg
    plot(Qty_UE_vec, outt_qty(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Qty_{UE}'); ylabel('Outage (%)');
title('Outage vs Qty_{UE}');
grid on;
legend(algNames, 'Location', 'best');
hold off;

% -------------------------------------------------------------------------
% Subplot de cada metrica vs BW para cada despachador
% Aqui se varia el BW manteniendo fijo el Qty_UE y el packet size
% -------------------------------------------------------------------------
figure('Color','w');
subplot(2,2,1);
for a = 1:nAlg
    plot(BW_values/1e6, ATP_bw(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('BW (MHz)'); ylabel('Throughput (bps)');
title(sprintf('Throughput vs BW (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,2);
for a = 1:nAlg
    plot(BW_values/1e6, FT_bw(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('BW (MHz)'); ylabel('Fairness');
title(sprintf('Fairness vs BW (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,3);
for a = 1:nAlg
    plot(BW_values/1e6, Ef_bw(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('BW (MHz)'); ylabel('Spectral efficiency (bps/Hz)');
title(sprintf('Efficiency vs BW (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,4);
for a = 1:nAlg
    plot(BW_values/1e6, outt_bw(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('BW (MHz)'); ylabel('Outage (%)');
title(sprintf('Outage vs BW (Qty_{UE}=%d)', baseline_Qty));
grid on;
legend(algNames, 'Location', 'bestoutside');

% -------------------------------------------------------------------------
% Subplot de cada metrica vs packet size para cada despachador
% Aqui se varia el packet size manteniendo fijo el Qty_UE y el BW
% -------------------------------------------------------------------------
figure('Color','w');
subplot(2,2,1);
for a = 1:nAlg
    plot(Pkg_values/1e6, ATP_pkg(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Packet size (Mbits)'); ylabel('Throughput (bps)');
title(sprintf('Throughput vs Pkg (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,2);
for a = 1:nAlg
    plot(Pkg_values/1e6, FT_pkg(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Packet size (Mbits)'); ylabel('Fairness');
title(sprintf('Fairness vs Pkg (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,3);
for a = 1:nAlg
    plot(Pkg_values/1e6, delay_pkg(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Packet size (Mbits)'); ylabel('Delay (s)');
title(sprintf('Delay vs Pkg (Qty_{UE}=%d)', baseline_Qty));
grid on;

subplot(2,2,4);
for a = 1:nAlg
    plot(Pkg_values/1e6, outt_pkg(a,:), markers{a}, 'LineWidth', 1.5); hold on;
end
xlabel('Packet size (Mbits)'); ylabel('Outage (%)');
title(sprintf('Outage vs Pkg (Qty_{UE}=%d)', baseline_Qty));
grid on;
legend(algNames, 'Location', 'bestoutside');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mediciones y Modelo de Propagacion
%
% Funcion
%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function P = Modelo_de_canal(freq, dist, pout)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Modelo de propagación de espacio libre
%   PL[dB] = 10*log[(lambda^2 / (4*pi)^2 * d^2)]
%   
%   donde:
%   lambda = longitud de onda (c/f)
%   d = distancia
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lambda = physconst('LightSpeed')/freq;
%L = 10 * log10(lambda.^2./(((4*pi).^2)*(dist.^2)));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   Modelo de propagación de espacio libre
%   elaborado
%
%   P[dBm] = (Pt*Gt*Gr*lambda^2) / ( (4*pi^2)*(d^2)*ls )
%   
%   donde:
%   Pt      es la potencia transmitida.
%   P[dBm]  la potencia recibida en función de la separación TR.
%   Gt      es la ganancia de la antena del transmisor.
%   Gr      la ganancia de la antena del receptor.
%   d       es la distancia de separación TR en metros.
%   ls      es el factor de pérdida del sistema no relacionado con la propagación 
%   lambda  es la longitud de onda en metros.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%P = (Pt*Gt*Gr*lambda^2) / ( (4*pi^2)*(d^2)*ls )

% Usando la función modelo de espacio libre de MATLAB
L = fspl(dist, lambda);
P = pout - L;
%figure()
%histogram(P,50)
%disp(mean(P))
% P = pout - L - raylrnd(length(pout));
% figure()
% histogram(P,50)
% disp(mean(P))
end


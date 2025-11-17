% Resolution equation de Laplace
%
clear
close all
clc

%% Q1

%% Dimensions / maillage
dx=1; % cm
dy=1; % cm
Nx = 40;
Ny = 40;

%% Potentiels / sources
v0 = 0; % condition aux limites (en V)
v1 = 100; % conducteur 1
v2 = -100; % conducteur 2

% Initialisation la matrice de calcul
V = zeros(Nx,Ny); % mettre toute la matrice a zero

% Conditions aux limites (Pour les cas où par exemple on a pas v0=0 sur l armature)
for j=1:Ny
    V(1,j)=v0;
    V(Nx,j)=v0;
end
for i=1:Nx
    V(i,1)=v0;
    V(i,Ny)=v0;
end

% Potentiels conducteur 1
%for i=8:35
%    for j=25;29
%        V(i,j)=v1;
%    end
%end

% Au lieu d une boucle, on peut passer les indices en vecteurs

i=7:34; % Colonnes
j=25:28; % Lignes
V(i,j)=100; % Met à +100V

% Potentiels conducteur 2

i=20:21;
j=5:22;
V(i,j)=-100;

% Figure
%figure;
%pcolor(V);
%colormap jet;

%% Q2

% Equation de calcul
%i=1;j=1;
%V(i,j)=...
%for i=2:Nx-1 % Pas besoin d aller calculer sur les bords
%    for j=2:Ny-1
%        V(i,j)=0.25*(V(i-1,j)+V(i+1,j)+V(i,j+1)+V(i,j-1));
%    end
%end
% Problème avec la boucle car on calcul de gauche a droites
% et on prend en compte nos calcul en amonts pour ceux en avals -> créer une dissymétrie donc on fait en vectoriel

i=2:Nx-1;
j=2:Ny-1;
V(i,j)=0.25*(V(i-1,j)+V(i+1,j)+V(i,j+1)+V(i,j-1));

% On a modifié les valeurs dans les conducteurs or on ne s interresse pas aux valeurs
%dedans et même le resultat obtenu sera faux car on modifie le potentiel dans le conducteur
i=7:34;j=25:28;
V(i,j)=100;
i=20:21;j=5:22;
V(i,j)=-100;

for k=1:200
    i=2:Nx-1;
    j=2:Ny-1;
    V(i,j)=0.25*(V(i-1,j)+V(i+1,j)+V(i,j+1)+V(i,j-1));
    i=7:34;j=25:28;
    V(i,j)=100;
    i=20:21;j=5:22;
    V(i,j)=-100;
end
% Figure
figure;
pcolor(V');
colormap jet;
axis equal;

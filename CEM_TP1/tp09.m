% Nelven THÉBAULT – 18/11/25
% TP CEM – Simulation par méthode DF (Différences Finies)
% -------------------------------------------------------
% Résolution numérique de l’équation de Laplace dans une
% géométrie coaxiale 2D : conducteur intérieur circulaire
% à +1 V et conducteur extérieur carré à -1 V.
%
% Objectif :
%  - obtenir le potentiel V(x,y)
%  - en déduire le champ électrique E = -grad(V)
%  - calculer la capacité linéique par le théorème de Gauss
%  - comparer avec C_théorique fourni dans l’énoncé.
% -------------------------------------------------------

%% Nettoyage espace de travail
clear
close all
clc

%% Définition du maillage (201×201 mailles comme demandé)
dx = 1; % Pas en x (maille unitaire, sans dimension physique)
dy = 1; % Pas en y
Nx = 201;
Ny = 201;

%% Potentiels imposés
v1 = -1;   % Potentiel du conducteur extérieur (carré)
v2 =  1;   % Potentiel du conducteur intérieur (cercle)
v0 =  0;   % Valeur initiale ailleurs

%% Initialisation de la matrice de potentiels
V = zeros(Nx,Ny);

%% Définition des conditions aux limites
% Le fichier 'indice.txt' contient les indices (linéarisés) des mailles
% appartenant au conducteur circulaire intérieur (Fig. 1 du sujet).
indice = load("indice.txt");

% On place les mailles du conducteur intérieur à +1 V
V(indice) = v2;

% On place les bords du carré extérieur à -1 V (C. L. Dirichlet)
V(1,:)        = v1;
V(Nx-1:Nx,:)  = v1;   % Deux dernières lignes
V(:,1)        = v1;
V(:,Ny-1:Ny)  = v1;   % Deux dernières colonnes

%% Paramètres de convergence pour la DF
eps = 1e-3;    % Seuil de convergence ( précision )
itmax = 10000; % Nombre maximum d itérations en sécurité
nb_iteration = 0;

%% Boucle de relaxation (méthode de Jacobi vectorisée)
% ------------------------------------------------------
% On met à jour les points intérieurs tant que :
%    |V(n) - V(n-1)|_max > eps  ET  n < itmax
% ------------------------------------------------------

erreur = 1; % Valeur initiale > eps

while (erreur > eps) && (nb_iteration < itmax)

    nb_iteration = nb_iteration + 1;
    Vold = V;   % Sauvegarde pour comparer la variation

    % Application du schéma DF (Laplace 2D, dx=dy=1)
    i = 2:Nx-1;
    j = 2:Ny-1;
    V(i,j) = 0.25*( V(i+1,j) + V(i-1,j) + V(i,j+1) + V(i,j-1) );

    % Réimposition des conditions aux limites à chaque itération
    V(indice) = v2;
    V(1,:)        = v1;
    V(Nx-1:Nx,:)  = v1;
    V(:,1)        = v1;
    V(:,Ny-1:Ny)  = v1;

    % Vérification de la convergence (norme infinie)
    erreur = max(max(abs(V - Vold)));

end

% ==> À mettre dans le compte rendu :
fprintf("Nombre d'itérations nécessaires : %d\n", nb_iteration);

%% Calcul du champ électrique E = -grad(V)
[Ex, Ey] = gradient(V); % gradient(V) donne (dV/dx , dV/dy)
Ex = -Ex;
Ey = -Ey;

%% Calcul de la charge par le théorème de Gauss
% -------------------------------------------------------------
% On définit une surface fermée autour du conducteur intérieur.
% Cette surface doit être suffisamment proche du cercle mais
% ne doit PAS le couper (pour récupérer le flux électrique total).
%
% Ici on choisit un rectangle englobant défini manuellement :
%
% Exemple arbitraire :
%     i = 62:140
%     j = 62:140
%
% On calcule le flux ES·dS sur chaque côté : top/bottom/right/left.
% -------------------------------------------------------------

% Exemple d encadrement
imin = 62; imax = 140;
jmin = 62; jmax = 140;

% Flux sur chaque côté du contour
% dS = 1 car maille unitaire

% côtés horizontaux (normale ±y)
flux_top    =  sum( Ey(imin:imax, jmax) );
flux_bottom = -sum( Ey(imin:imax, jmin) );

% côtés verticaux (normale ±x)
flux_right  =  sum( Ex(imax, jmin:jmax) );
flux_left   = -sum( Ex(imin, jmin:jmax) );

% Flux total sortant (≈ Q/eps0)
Etot = flux_top + flux_bottom + flux_right + flux_left;

% Charge linéique (par unité de longueur z)
eps0 = 8.854e-12;
Q = eps0 * Etot;

% Différence de potentiel entre conducteurs
dV = v2 - v1; % ici = 2 volts

% Capacité linéique (F/m)
C_num = Q / dV;

%% Calcul de la capacité théorique
% --------------------------------------------------------
% d = diamètre de l âme circulaire = 2*a = 2*40 = 80 mailles
% D = côté interne du carré extérieur = 201 mailles
%
% Formule de l énoncé :
% C_th = 1 / ( 138 * c0 * log10( 1.1 * D / d ) )
% Attention : c0 = vitesse de la lumière
% --------------------------------------------------------

c0 = 3e8;
d = 80;
D = 201;

C_th = 1 / ( 138 * c0 * log10(1.1 * (D/d)) );


%% Figure
figure;
% pcolor(V') % permet de tracer transposée de V
% hold on;
% colormap jet % permet d'avoir un contraste de couleur (bleu->rouge)
% axis equal % permet d'avoir un repère orthonormé
hold on;
contour(V') % permet de tracer transposée de V
quiver(-Ex,-Ey) % permet de tracer les équipotentielles de V
colormap jet % permet d'avoir un contraste de couleur (bleu->rouge)
axis equal % permet d'avoir un repère orthonormé
colorbar
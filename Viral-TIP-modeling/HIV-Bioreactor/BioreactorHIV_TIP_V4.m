
% Neha Khetan, June 2023
% HIV-TIP - Bioreactor modeling for design criterion for amplification of
% spontaneously emerged DIPs in an evolutionary experimental scheme
% Design criterion, conditions
% THIS is used for TIP-HIV paper

clear gobal
clc ; clf;
close all;
clear all;


%% Experimenta set-up
% SP: 0 ; Cont with cell division and without cell replacement: 1;
% Cont with division + replenishment = 2

    BRsetup = 1;
% ---------------------------------------------------------------------
switch ( BRsetup )
    case 0
        opath     ='./Revised/'; %./Revised/SP/';
        tp        = 25 ;
        dilFac    = 0.1;
        iEnd      = 100;
        %opath = './';


    case 1
        opath     ='./Revised/Cont/';
        tp        = 150;
        iEnd      = 150;

    case 2
        opath     ='./Revised/ContCD/';
        tp        = 300;
        iEnd      = 300;
end
timTot  = iEnd;
timstep  = 1;
% T, I , V , Tt , Td , Vt
ivE0     = [ 1.6*10^6 , 0  , 2*10^4  , 0 , 0 , 0 , 0 ];
ivE      = ivE0;
iStart   = 0;



%% =====================================================================
%
%% =====================================================================
set(0,'defaulttextfontsize',16);
set(0,'defaultaxesfontsize',16);
set( gcf ,'color','w');
%
tolval    = 1e-12;
abtol     = tolval;
options1  = odeset('AbsTol', tolval  , 'RelTol', tolval );%,'Stats','off', 'InitialStep' , 10^-12  );



Pv          = 0.7;   % [ 0.5 , 0.7 , 1 , 1.5 , 5 ,10  ];%,  5 , 15 , 45  , 100  ];
Dv          = 0.9; %[   0.1 , 0.8 ]; %[ 0.04 , 0.4 , 0.8 ];%  0.08 , 0.2 ,  0.8 , 1  ];
LowCutOff   = 10^-3;%10^-12;


PDpairs = [];
for i = 1:length(Pv)
    for k =1:length(Dv)
        PDpairs = [PDpairs ; Pv(i) , Dv(k) ];
    end
end



dilFac = [  10 , 5 , 3, 2 , 1 ];
for pd = 1:size( dilFac ,2  )


    AllStates = [];
    sol = [];
    for iTime = iStart:tp:iEnd-tp
        Timvals   = [ iTime iTime+tp ];
        timpts   =  [ Timvals(1):timstep:Timvals(2)];
        %----------------------------
        pvaal           = getpars_HIVTIP_BR();
        pvaal.D         = Dv;
        pvaal.P         = Pv;
        sol             = ode23s( @( Timvals , yy2 )TipmodelBioreactor( Timvals , yy2 , pvaal  )  , Timvals , ivE  , options1 );


        sol2           = deval( sol ,  timpts  );
        tmpIdx         = sol2(:,:) <LowCutOff ;
        sol2(tmpIdx )  = LowCutOff ;
        AllStates      = [ AllStates , sol2 ];

     
        if BRsetup == 0
            ivE            = [ ivE0(1:2)  , sol.y(3,end)/dilFac(pd) , ivE0(4:5) , sol.y(6,end)/dilFac(pd) ,  ivE0(7) ];
        else
            ivE            = [ ivE0(1:7)  ];
        end

    end



    AllStatesIdx   = AllStates(:,:) < LowCutOff;
    AllStates( AllStatesIdx ) = 0;
    TotalTCells               = ( AllStates(1,:) + AllStates( 2,:) + AllStates( 4,:) +AllStates( 5,:));
    TotalInf                  = ((AllStates(2,:) + AllStates(5,:))./TotalTCells).*100;
    Infect                    = ( AllStates(2,:)./TotalTCells).*100 ;
    InfectDual                = ( AllStates(5,:)./TotalTCells).*100 ;

    TotalDIP                  = (AllStates(4,:) + AllStates(5,:));

    %% Ext Fig1 : Viral load, DIP and Total T cells
    % figure(1),...
    % yyaxis left,...
    %  plot( ((AllStates(4,:)+AllStates(5,:))./TotalTCells).*100 , '-',  'linewidth' ,1.5   ), hold on,...
    %  yyaxis right,...
    % plot( ((AllStates(4,:)+AllStates(5,:))) , '-',  'linewidth' ,1.5   ), hold on,...
    % 
    % 
    % figure(2),...
    %     yyaxis left,...
    %     semilogy(  ( AllStates(6,:)./( AllStates(3,:) + AllStates(6,:) )).*100   ,  'linewidth' ,1 ), hold on,...
    %     ylabel(' % DIPs/[DIPs + HIV] '),...
    %     yyaxis right,...
    %     semilogy(  (AllStates(6,:)  ) ,  'linewidth' ,1 ), hold on,...
    %     ylabel('# DIPs/mL'),...




    figure(10),...
        ax = gca();
         yyaxis left,...
         plot(  timpts,     TotalTCells./10^6 , '-'   ,  'linewidth' ,1.5    , 'color' , [0.7 , 0.7 ,0.7 ] ), hold on,...
         plot(  timpts,     TotalDIP./10^6 , '-.'   ,  'linewidth' ,1.5    , 'color' , [0.7 , 0.7 ,0.7 ] ), hold on,...
        yyaxis right,...
         semilogy(  timpts,  AllStates(3,:)  , '-',  'linewidth' ,1.5 ), hold on,...
          semilogy( timpts,  AllStates(6,:)  , '-.', 'linewidth' ,1.5 ), hold on;
         ax.YAxis(1).Color = [ 0.7 , 0.7 , 0.7] ;
          ax.YAxis(2).Color = [ 1 0.25 0.25] ; %'g'; % [0.47,0.67,0.19],...
     

end


%ax.YAxis(1).Color = [ 1 0.25 0.25] ; %'r'; % [0.47,0.67,0.19],...
%ymax = round( log10( max((AllStates(3,:)  + AllStates(6,:)  ) ) ));
%yticks( [0 10^ymax ]),...
%    ylim( [ 0 10^ymax ]),...
% figure(1),...
%     export_fig( FH1 , [ opath , 'Fig1_' , sprintf('%s', num2str(BRsetup)) ,'.pdf' ] , '-pdf', '-transparent'   );

%
% figure(2),...
%     export_fig( FH2 , [ opath , 'Fig2_' , sprintf('%s', num2str(BRsetup)) ,'.pdf' ] , '-pdf', '-transparent'   );
%
%
% figure(10),...
%     export_fig( FH10 , [ opath , 'Fig10_' , sprintf('%s', num2str(BRsetup)) ,'.pdf' ] , '-pdf', '-transparent'   );




function dY = tanner2019( T , Y , PP )
lam = PP.lam;
d   = PP.d;
k   = PP.k;
d2  = PP.d2;
c   = PP.c;
n   = PP.n;
P   = PP.P;
D   = PP.D;

h   = PP.h;
dr  = PP.dr;
Pr  = PP.pr;
drV = PP.drV;



dY = zeros( 7 , 1 );
%T(
dY(1) = lam   + Y(1)*( ( h - ( Y(1)+Y(2) + Y(4) + Y(5)) )/h )  - ( d*Y(1) ) - k*Y(1)*( Y(3) + Y(6)  ) - (dr*Y(1));
%I
dY(2) = (k*Y(3)*Y(1)) - ( d2 * Y(2) ) - (dr*Y(2));
%V
dY(3) = ( n*d2 * Y(2) ) + ( D * n * d2 * Y(5) )   - ( c*Y(3) ) - (drV*Y(3));

%Tt
dY(4) = (k*Y(1)*Y(6))  + Y(4)*(  (h - ( Y(1)+Y(2) + Y(4) + Y(5) ))/h )- ( k*Y(3)*Y(4) ) + ( Pr*k*Y(1)*Y(3)) - (d*Y(4)) - (dr*Y(4));
%Td
dY(5) = (k*Y(3)*Y(4)) - ( d2 * Y(5) ) - (dr*Y(5));
% Vt
dY(6) = ( P*D*n*d2*Y(5) ) - ( c*Y(6) ) - (drV*Y(6));
dY(7) = (dr*Y(1)) + (dr*Y(2)) + (drV*Y(3)) + (dr*Y(4)) + (dr*Y(5)) + (drV*Y(6));

end





function dY = TipmodelBioreactor( T , Y , PP )
lam = PP.lam;
d   = PP.d;
k   = PP.k;
d2  = PP.d2;
c   = PP.c;
n   = PP.n;
P   = PP.P;
D   = PP.D;
d3  = D*d2;
h   = PP.h;
dr  = PP.dr;
Pr  = PP.pr;
drV = PP.drV;
h0  = PP.h0;

dY = zeros( 7 , 1 );
dY(1) = lam   + Y(1)*h0*( ( h -( Y(1)+Y(2) + Y(4) + Y(5) ) )/h )  - (d*Y(1)) - k*Y(1)*( Y(3) + Y(6)  )- (dr*Y(1));
dY(2) = (k*Y(3)*Y(1)) - ( d2 * Y(2) ) - (dr*Y(2));
dY(3) = ( n*d2 * Y(2) ) - ( c*Y(3) ) + ( D * n * d3 * Y(5) ) - (drV*Y(3));


dY(4) = (k*Y(1)*Y(6) )  + Y(4)*h0*(  (h - (Y(1)+Y(2) + Y(4) + Y(5) ))/h ) - ( k*Y(3)*Y(4) ) + (Pr*k*Y(1)*Y(3))- (d*Y(4))- (dr*Y(4));
dY(5) = (k*Y(3)*Y(4)) - ( d3 * Y(5) ) - (dr*Y(5));
dY(6) = ( P^2 * D*n*d3*Y(5) ) - ( c*Y(6) ) -  (drV*Y(6)) ;

dY(7) = (dr*Y(1)) + (dr*Y(2)) + (dr*Y(3)) + (dr*Y(4)) + (dr*Y(5)) + (dr*Y(6));
%dY(7) =  (drV*Y(3))+ (drV*Y(6));

end




function dY = expandedHIV( T , Y , PP )
lam = PP.lam;
d   = PP.d;
k   = PP.k;
d2  = PP.d2;
c   = PP.c;
n   = PP.n;
P   = PP.P;
D   = PP.D;
d3  = D*d2;

dY = zeros( 6 , 1 );
dY(1) = lam - Y(1)*( d + ( k*Y(3) )  + ( k*Y(6) ) );
dY(2) = (k*Y(3)*Y(1)) - ( d2 * Y(2) );
dY(3) = ( n*d2 * Y(2) ) - ( c*Y(3) ) + ( D * n * d3 * Y(5) );
dY(4) = (k*Y(1)*Y(6)) - ( k*Y(3)*Y(4) ) - (d*Y(4));
dY(5) = (k*Y(3)*Y(4)) - ( d3 * Y(5) );
dY(6) = ( P^2 * D*n*d3*Y(5) ) - ( c*Y(6) );
end

function dY = pbasicHiv( T , Y , PP )

lam = PP.lam;
d   = PP.d;
k   = PP.k;
d2  = PP.d2;
c   = PP.c;
n   = PP.n;


dY = zeros( 3 , 1 );
dY(1) = lam - Y(1)*( d ) - k*Y(3)*Y(1) ;
dY(2) = (k*Y(3)*Y(1)) - ( d2 * Y(2) );
dY(3) = ( n*d2 * Y(2) ) - ( c*Y(3) ) ;
end
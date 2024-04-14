%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Neha Khetan, 2023
% Plotting- different VLSP: T-cells, TIP-cells, VL and TIP-load
% Revising for representative..........
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clearvars; clc; close all;
ipath  = './out/';
cc = [  240 , 128 , 128 ;
        100 , 149 , 237 ;
        143 , 188 , 143 ;
        120 , 120 , 120 ]./255;
T1        =  365;       %65;
T2        =  365*3;     % days
ReqTimPts1          = [0:5:T1]-T1; ReqTimPts2 =[T1:5:T2]-T1;
ReqdTim             = [ ReqTimPts1 , ReqTimPts2 ];
saveinfo  = 1;

%% ======================================================================
% V.L
f1 = load( [ ipath , 'LogVL_20_0.02_rhoScal3.out' ]);
f2 = load( [ ipath , 'LogVL_20_0.04_rhoScal3.out' ]);
f3 = load( [ ipath , 'LogVL_30_0.02_rhoScal3.out' ]);
f4 = load( [ ipath , 'LogVL_30_0.04_rhoScal3.out' ]);

% 75 = 0; 78: Day 15; 99: 120 days
VL1 = mean( f1 , 2) ;
VL2 = mean( f2 , 2);
VL3 = mean( f3 , 2);
VL4 = mean( f4 , 2);

% pre-TIP | day 15 | day 120 | Steady state-value
SPVL  = round( [   VL1( 75 ) , VL2( 75 ) , VL3( 75  ) , VL4( 75 ) ]  , 2 );       
KinVL =  [         VL1( 75 ) , VL1( 78 ) , VL1( 99  ) ,  mean(  VL1( 78:99  ) );
                   VL2( 75 ) , VL2( 78 ) , VL2( 99  ) ,  mean(  VL2( 78:99  ) );
                   VL3( 75 ) , VL3( 78 ) , VL3( 99  ) ,  mean(  VL3( 78:99  ) );
                   VL4( 75 ) , VL4( 78 ) , VL4( 99  ) ,  mean(  VL4( 78:99  ) )];
FH1=figure(1),...
    H1=plot( ReqdTim' , mean( f1 , 2) , 'color' , cc(1,:) , 'linewidth' ,4  ),hold on,...
    errorbar( ReqdTim' , mean( f1 , 2) , std( f1 , 0,  2) , 'linewidth' ,0.7 , 'lineStyle' ,'none' , 'color' , cc(1,:) ,'Marker' , 'none' ),...
    H2=plot( ReqdTim' , mean( f2 , 2) , 'color' , cc(2,:) , 'linewidth' ,4  ),hold on,...
    errorbar( ReqdTim' , mean( f2 , 2) , std( f2 , 0,  2) , 'linewidth' ,1.0 , 'lineStyle' ,'none' , 'color' , cc(2,:) ),...
    H3=plot( ReqdTim' , mean( f3 , 2) , 'color' , cc(3,:) , 'linewidth' ,3  ),hold on,...
    errorbar( ReqdTim' , mean( f3 , 2) , std( f3 , 0,  2) , 'linewidth' ,1  , 'lineStyle' ,'none' , 'color' , cc(3,:) ),...
    H4=plot( ReqdTim' , mean( f4 , 2) , 'color' , cc(4,:) , 'linewidth' ,4  ),hold on,...
    errorbar( ReqdTim' , mean( f4 , 2) , std( f4 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(4,:) ),...
    xlabel('Days'),...
    ylabel('Log_{10} HIV-RNA copies/mL'),...
    ylim([ 0 7 ]),...
    legend( [  H1, H2 H3, H4 ] , { '5.03' , '4.61' , '5.29' , '5.11'} ),...
    xlim([ -100 ReqdTim(end) ]),...
    yline(3 , '-.' , 'color' , 'k' , 'linewidth', 3 ),...
    set( gca , 'fontsize', 24);
    if saveinfo
        saveas( gcf , [ipath, 'Error_VL_pred.pdf'])
    end

%%  CD4
f1 = load( [ ipath , 'TotalTcells_20_0.02_rhoScal3.out' ]);
f2 = load( [ ipath , 'TotalTcells_20_0.04_rhoScal3.out' ]);
f3 = load( [ ipath , 'TotalTcells_30_0.02_rhoScal3.out' ]);
f4 = load( [ ipath , 'TotalTcells_30_0.04_rhoScal3.out' ]);

CD41 = mean( f1 , 2) ;
CD42 = mean( f2 , 2);
CD43 = mean( f3 , 2);
CD44 = mean( f4 , 2);
KinCD4 =  [     CD41( 75 ) , CD41( 78 ) , CD41( 99  ) ,  mean(  CD41( 78:99  ) );
                CD42( 75 ) , CD42( 78 ) , CD42( 99  ) ,  mean(  CD42( 78:99  ) );
                CD43( 75 ) , CD43( 78 ) , CD43( 99  ) ,  mean(  CD43( 78:99  ) );
                CD44( 75 ) , CD44( 78 ) , CD44( 99  ) ,  mean(  CD44( 78:99  ) )];
 
FH2=figure(2),...
    H1=plot( ReqdTim' , mean( f1 , 2) , 'color' , cc(1,:) , 'linewidth' ,3  ),hold on,...
    errorbar( ReqdTim' , mean( f1 , 2) , std( f1 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(1,:) ),...
    H2=plot( ReqdTim' , mean( f2 , 2) , 'color' , cc(2,:) , 'linewidth' ,3  ),hold on,...
    errorbar( ReqdTim' , mean( f2 , 2) , std( f2 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(2,:) ),...
    H3=plot( ReqdTim' , mean( f3 , 2) , 'color' , cc(3,:) , 'linewidth' ,3  ),hold on,...
    errorbar( ReqdTim' , mean( f3 , 2) , std( f3 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(3,:) ),...
    H4=plot( ReqdTim' , mean( f4 , 2) , 'color' , cc(4,:) , 'linewidth' ,3  ),hold on,...
    errorbar( ReqdTim' , mean( f4 , 2) , std( f4 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(3,:) ),...
    legend( [  H1, H2 H3, H4 ] , { '5.03' , '4.61' , '5.29' , '5.11'} ),...    xlabel('Days'),...
    ylabel('T-cells/\muL'),...
    %ylim([ 0 6 ]),...
    xlim([ -100 ReqdTim(end) ]),...
    set( gca , 'fontsize', 24);
    if saveinfo
        saveas( gcf , [ipath, 'All_CD4_pred.pdf'])
    end


%% TIP cells
ff1 = load( [ ipath , 'AllTIP_20_0.02_rhoScal3.out' ]);
ff2 = load( [ ipath , 'AllTIP_20_0.04_rhoScal3.out' ]);
ff3 = load( [ ipath , 'AllTIP_30_0.02_rhoScal3.out' ]);
ff4 = load( [ ipath , 'AllTIP_30_0.04_rhoScal3.out' ]);
tip1 = mean( f1 , 2) ;
tip2 = mean( f2 , 2);
tip3 = mean( f3 , 2);
tip4 = mean( f4 , 2);

FH4=figure(4),...
    H1=plot( ReqdTim' , mean( ff1 , 2) , '-.',  'color' , cc(1,:) , 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( ff1 , 2) , std( f1 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(1,:) ),...
    H2=plot( ReqdTim' , mean( ff2 , 2) ,     '-.', 'color' , cc(2,:) , 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( ff2 , 2) , std( f2 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(2,:) ),...
    H3=plot( ReqdTim' , mean( ff3 , 2) , '-.', 'color' , cc(3,:) , 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( ff3 , 2) , std( f3 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(3,:) ),...
    H4=plot( ReqdTim' , mean( ff4 , 2) ,'-.',  'color' , cc(4,:) , 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( ff4 , 2) , std( f4 , 0,  2) , 'linewidth' ,0.7  , 'lineStyle' ,'none' , 'color' , cc(4,:) ),...
    legend( [  H1, H2 H3, H4 ] , { '5.03' , '4.61' , '5.29' , '5.11'} ),...
    xlabel('Days'),...
    ylabel('TIP-integrated cells/\muL'),...
    xlim([ -100 ReqdTim(end) ]),...
    set( gca , 'fontsize', 24);
   legend( [  H1, H2 H3, H4 ] , { '5.03' , '4.61' , '5.29' , '5.11'} ),...
    xlabel('Days'),...
    ylabel('TIP-integrated cells/\muL'),...
    set( gca , 'fontsize', 24);
   if saveinfo
        saveas( gcf , [ipath, 'TIP_CD4_pred.pdf'])
   end
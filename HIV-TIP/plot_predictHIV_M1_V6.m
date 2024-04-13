%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Neha Khetan, Sep. 2022 - 2023
% Aim:  Predict TIP efficacy in humans based on SIV estimates
%     1. for all possible estimates of P-D
%     2. for varying lambda/d -> for variable VLSP
%     3. with cell-division
%     4. Parameter-scan within scope of estimated range from patientestimates
%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all, clc, clf, close all;


opath     = './test0725/';
set( groot ,'DefaultFigureVisible','on');


%% =======================================================================
% Fit-P and D params
vldat  = load( [ opath , 'PDvals.txt'] );
vv    = unique( vldat , 'rows');
vv    = [ round( vv(:,1)) , round( vv(:,2) ,2)  ];
vv    = unique( vv , 'rows');


%vv = [ 38 , 0.03 ] ;
% 25 , 0.02;
% 81 ,0.06];
%% =======================================================================


tipvals      = vv;
cc           = hsv(size( tipvals ,2 ));
CFulml       = 10^3;


paramSet     = [ 20 , 3*10^-4 , 0.02 , 0.74 , 200];
iniV         = [ paramSet(1,1)./paramSet(1,3) , 0 , 10^2]; %10^-6 ];
paramSetIndx = size( paramSet ,1  );




%% ======================================================================
v2RNA        = 2;
pClusterVals = vv(:,1);
dClusterVals = vv(:,2);

T1        =  365;       %65;
T2        =  365*3;     % days
tss       =  15;        % days after TIP administration
TcutOff   =  365;       %180;       % days uptol which the median valus ic calculated
CF        =  10^3;      % conversion for uL to mL --> 10^3



%%======================================================================
Timvals             = [ 0 , T1 ];
Timvals2            = [ T1  T2 ];
ReqTimPts1          = [ 0:5:T1]; ReqTimPts2 =[T1:5:T2];
ReqdTim             = [ ReqTimPts1 ,ReqTimPts2 ];

%% ========================================================================

tolval              = 1e-8;
options1            = odeset( 'RelTol', tolval  ,'AbsTol', tolval  , 'Stats','off');% , 'InitialStep' , 10^-12 ); %,    'MaxStep' , 0.01  );
Id0                 =  0;
Tt0                 =  0;
Vt0                 =  0;
VT0                 = 10^-6; %10^2    % TIP load: copies/uL
rho_scaling         = 3;   % [ 1 , 2 ,3 

%% ========================================================================



AllH    = [];
AllTcells  =[];
AllVL   = [];
AllTipL = [];


for tip =1:size( tipvals , 1 )

    vltmp = [];
    % Call param
    pvaal              = getpars_HIVTIP(); %getBasicPars();
    pvaal.lam          = paramSet( paramSetIndx , 1 );
    pvaal.k            = paramSet( paramSetIndx , 2 ) ;
    pvaal.d            = paramSet( paramSetIndx , 3 );
    pvaal.d2           = paramSet( paramSetIndx , 4 );
    pvaal.n            = paramSet( paramSetIndx , 5 );
    ivE                = [ paramSet(paramSetIndx , 1)/paramSet( paramSetIndx ,3) , 0 , 10^-6 , Tt0, Id0 , Vt0 ];
    sol1               = ode23s( @( Timvals , yy ) expandedHiv( Timvals , yy , pvaal  )  , Timvals , ivE  , options1 );




    % Add TIP
    pvaal.P            = rho_scaling*pClusterVals( tip );
    pvaal.D            = dClusterVals( tip );
    ivE2               = [ sol1.y(1:3,end)' , 0 , 0 , VT0 ];
    sol2               = ode23s( @( Timvals2 , yy2 ) expandedHiv( Timvals2 , yy2 , pvaal  )  , Timvals2 , ivE2  , options1 );
    tmpAll             = [ sol1.x', sol1.y(:,:)' ; sol2.x' , sol2.y(:,:)'];




    %=======================================================================
    vltmp1              = interp1( sol1.x , sol1.y(3,:) ,   ReqTimPts1 );
    vltmp2              = interp1( sol2.x , sol2.y(3,:) ,   ReqTimPts2 );
    tmpvl               = [ vltmp1' ; vltmp2'];
    AllVL               = [ AllVL , tmpvl ];
    % clear vltmp1 vltmp2 tmpvl


    % TIP data
    vltmp1              = interp1( sol1.x , sol1.y(6,:) ,   ReqTimPts1 );
    vltmp2              = interp1( sol2.x , sol2.y(6,:) ,   ReqTimPts2 );
    tmpvl               = [ vltmp1' ; vltmp2'];
    AllTipL            =  [  AllTipL  , tmpvl ];
    clear vltmp1 vltmp2 tmpvl

    % Total CD4
    vltmp1              = interp1( sol1.x , sol1.y(1,:) ,   ReqTimPts1 );
    vltmp2              = interp1( sol2.x , sol2.y(1,:) ,   ReqTimPts2 );

    vltmp3              = interp1( sol1.x , sol1.y(2,:) ,   ReqTimPts1 );
    vltmp4              = interp1( sol2.x , sol2.y(2,:) ,   ReqTimPts2 );

    vltmp5              = interp1( sol1.x , sol1.y(4,:) ,   ReqTimPts1 );
    vltmp6              = interp1( sol2.x , sol2.y(4,:) ,   ReqTimPts2 );

    vltmp7              = interp1( sol1.x , sol1.y(5,:) ,   ReqTimPts1 );
    vltmp8              = interp1( sol2.x , sol2.y(5,:) ,   ReqTimPts2 );

    tmpTtar              = [ vltmp1'; vltmp2'];
    tmpTtip              = [ vltmp5'; vltmp6'];
    tmpTInf              = [ vltmp3'; vltmp4'];
    tmpTDual             = [ vltmp7'; vltmp8'];



    AllH                = [ AllH , ( tmpTtar + tmpTtip)];
    AllTcells           = [ AllTcells ,  ( tmpTtar + tmpTtip + tmpTDual + tmpTInf)];
    clear vltmp1 vltmp2 vltmp3 vltmp4 vltmp5 vltmp6 vltmp7 vltmp8

    %figure(1),...
    %plot( sol1.x , (sol1.y(3,:))), hold on,...
    %plot( sol2.x , (sol2.y(3,:))), hold on,...
    %plot(  ReqTimPts2 , vltmp2 , 'k*'),hold on;


end



LogVL       = log10(AllVL.*CFulml);
LogVLTIP    = log10(AllTipL.*CFulml);


FH1=figure(1),...
    plot( ReqdTim' , mean( LogVL , 2) ,'k', 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( LogVL  , 2) , std( LogVL , 0, 2) , 'linewidth' ,1  , 'lineStyle' ,'none' , 'color' , [0.5 ,0.5 ,0.5] ),...
    %set( gca , 'yscale' , 'log'),...
    xlabel('Days'),...
    ylabel('HIV-RNA copies/mL (Log10)'),...
    %ylim([ 0 7 ]),...
    yline(3 , '-.' , 'color' , 'k' , 'linewidth', 3 ),...)
    set( gca , 'fontsize', 24),...
    saveas( FH1 , 'HIV_vl.fig')




FH2=figure(2),...
    plot( ReqdTim' , mean(AllTcells, 2) , 'k','linewidth' ,2 ),hold on,...
    errorbar( ReqdTim' , mean(AllTcells, 2) , std( AllTcells , 0 , 2 ) , 'linewidth' ,1  , 'lineStyle' ,'none'  , 'color' , [0.5 ,0.5 ,0.5] ),...
    xlabel('Days'),...
    ylabel('Total T cells/\muL'),...
    set( gca , 'fontsize', 24),...
    saveas( FH2 , 'Tcells.fig')



FH3=figure(3),...
    plot( ReqdTim' , mean( LogVLTIP , 2) ,'k', 'linewidth' ,2  ),hold on,...
    errorbar( ReqdTim' , mean( LogVLTIP  , 2) , std( LogVLTIP  , 0, 2) , 'linewidth' ,1  , 'lineStyle' ,'none'  , 'color' , [0.5 ,0.5 ,0.5] ),...
    %set( gca , 'yscale' , 'log'),...
    xlabel('Days'),...
    ylabel('TIP-RNA copies/mL (Log10)'),...
    % ylim([ 2 10 ]),...
    % yline(3 , '-.' , 'color' , 'k' , 'linewidth', 3 ),...)
    set( gca , 'fontsize', 24),...
    saveas( FH3 , 'TIP_vl.fig')



% 74th: 365, 77:380
% Log-fold reduction

% figure(5),...
%     hist( log10( AllVL(74,:)./AllVL(78,:)) ), hold on,...
%     xlabel('HIV-RNA copies/mL (Log10)'),...
%     set( gca , 'fontsize', 24)

% FH6=figure(6),...
%     [f6, x6]= hist( LogVL(end,:)), hold on,...
%     bar( x6 , f6./sum(f6)  ,1  ,'Facecolor' , 'none'), hold on,...
%     xlabel('Log_{10} HIV-RNA copies/mL'),...
%     set( gca , 'fontsize', 24),...
%     ylabel('Frequency'),...
%




% FH8=figure(200),...
%     plot( LogVL(78,:) , LogVL(end,:) ,'ko'),hold on,...
%     plot( LogVL(81,:) , LogVL(end,:) ,'ro'),hold on,...
%     set( gca , 'fontsize', 24),...
%     %xlim([1 5.2]),...
%     %ylim( [ 1 5.2 ]),...
%     axis equal,...
%     axis square,...
%     yline( 3 , '-.' , 'color' , [0.7 0.7 0.7] , 'linewidth', 2 ),...
%       xline( 3 , '-.' , 'color' , [0.7 0.7 0.7] , 'linewidth', 2 ),...
%     legend( 'Day 15' , 'Day 30' , 'fontsize',14 , 'location' , 'northwest' );
%     %saveas( FH8 , 'TIP_vl_',  sprintf('%s', num2str( paramSet(1) ) ) , '_',  sprintf('%s', num2str( paramSet(3) ) )  ,'_rhoScal',  sprintf('%s', num2str( rho_scaling ) ) , '.fig')


% % output files
dlmwrite( [opath , 'LogVL_', sprintf('%s', num2str( paramSet(1) ) ) , '_',  sprintf('%s', num2str( paramSet(3) ) )  ,'_rhoScal',  sprintf('%s', num2str( rho_scaling ) ) , '.out'], LogVL , 'delimiter' ,'\t' );
dlmwrite( [opath , 'LogVLTip_', sprintf('%s', num2str( paramSet(1) ) ) , '_',  sprintf('%s', num2str( paramSet(3) ) ) ,'_rhoScal',  sprintf('%s', num2str( rho_scaling ) ) , '.out'], LogVLTIP , 'delimiter' ,'\t' );
dlmwrite( [opath , 'TotalTcells_', sprintf('%s', num2str( paramSet(1) ) ) , '_',  sprintf('%s', num2str( paramSet(3) ) ) ,'_rhoScal',  sprintf('%s', num2str( rho_scaling ) ) , '.out'], AllTcells , 'delimiter' ,'\t' );


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

function dY = expandedHiv( T , Y , PP )
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


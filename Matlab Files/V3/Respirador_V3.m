%GEOMETRICAL PARAMETERS

l0 = 30;
h0 = 6.5;

h1 = 10;
h2 = 19;

lm = 30;
hm = 22;

lb = l0 - 8.5;

%Minimum radius of the camshaft
v = hm - h2;

%Y coordinate variation between min and max positions of the camshaft
dv = h2 - h1;


%BREATHING CYCLE PARAMETERS

%Duration of the inhale cycle / duration of the whole cycle
lambda = 0.35;

%Soft transition between inhale and exhale cycles
dpsi21 = 0.05;
dpsi12 = 0.03;

%Adjust parameters of the inhale curve (interpolated as a parable)
x1 = 0.02;
y1 = 14;
m1 = 1.5;
e1 = 2;

%Adjust parametes of the exhale curve (interpolated as a exponential)
% m2 = 2;
% m22 = 0.8;
% y2 = 6.5;
% x2 = -0.025;

x3 = 0.55;
y3 = 2.8;
m3 = 1;
e3 = 0.5;


%GENERATION OF THE CURVES AND THE CAMSHAFT

%Time increment
dt = 0.01;

%time coordinate during the whole cycle
theta = 0:dt:2*pi;

%Generation of the soft transition between inhale and exhale curves
psi1 = [];
psi2 = [];

for i = 1:numel(theta);
    if theta(i) < dpsi21*2*pi;
        psi1(i) = 0.5 - 0.5*cos(theta(i)/(2*dpsi21));
        
    elseif theta(i) < (lambda-dpsi12/2)*2*pi;
        psi1(i) = 1;
        
    elseif theta(i) < (lambda+dpsi12/2)*2*pi;
        psi1(i) = 0.5 - 0.5*cos((theta(i)-(lambda+dpsi12/2)*2*pi)/(2*dpsi12));
                
    else
        psi1(i) = 0;
        
    end;
    
    psi2(i) = 1 - psi1(i);
    
end;    


%Generation of the complete breathing cycle rho(theta)

rho = [];
rho1 = [];
rho2 = [];
rho2next = [];

rhomin = 1000;
rhomax = 0;

for i = 1:numel(theta);
    
    %Inhale curve
    rho1(i) = y1 - (m1*(theta(i)-(lambda+x1)*2*pi))^e1;
    
    %Exhale curve
    rho2(i) = y3 + m3*e3^(theta(i)-(lambda+x3)*2*pi);
    rho2next(i) = y3 + m3*e3^(2*pi+theta(i)-(lambda+x3)*2*pi);
    
    if theta(i) < lambda*pi    
        rho(i) = psi1(i)*rho1(i) + psi2(i)*rho2next(i);
    
    else
        rho(i) = psi1(i)*rho1(i) + psi2(i)*rho2(i);
    
    end;
    
    %Capturing min and max in order to generate the normalized curve
    if rho(i) > rhomax
        rhomax = rho(i);
    end;
    
    if rho(i) < rhomin
        rhomin = rho(i);
    end;

end;


%Generation of a normalised curve and camshaft

rhonorm = [];
rhocam = [];

for i = 1:numel(theta);
    
    rhonorm(i) = (rho(i)-rhomin)/(rhomax-rhomin);
    
    rhocam(i) = v + rhonorm(i)*dv;
    
end;


%Generation of the first derivate of the camshaft geometry to analize and
%validate the design

drho = [];
drhonorm = [];
drhocam = [];

a = v;
b = 1/dt;

for i = 1 : numel(rho)-1;
    
    drho(i) = b*(rho(i+1)-rho(i));
    drhonorm(i) = b*(rhonorm(i+1)-rhonorm(i));
    drhocam(i) = b*(rhocam(i+1)-rhocam(i)) + a;
    
end;

drho(numel(rho)) = b*(rho(1)-rho(numel(rho)));
drhonorm(numel(rhonorm)) = b*(rhonorm(1)-rhonorm(numel(rhonorm)));
drhocam(numel(rhocam)) = b*(rhocam(1)-rhocam(numel(rhocam))) + a;


%X and Y coordinates during two cycles (for 2-cycle camshaft plot)

theta2 = [theta/2, (2*pi+theta)/2];

rhocam2 = [rhocam, rhocam];
drhocam2 = [drho, drho];


%X and Y coordinates during three cycles (for 3-cycle camshaft plot)

theta3 = [theta/3, (2*pi+theta)/3, (4*pi+theta)/3];

rhocam3 = [rhocam, rhocam, rhocam];
drhocam3 = [drho, drho, drho];



%GENERATION OF THE PLOTS

%Trying to print it out in real size (FAIL)
%set(gcf,'PaperUnits','centimeters'); 
%set(gcf,'PaperSize',[42 29.7]);

%Plot of the breathing cycle interpolation by curves

fcycle = figure('Name', 'Breath Cycle curves', 'Units', 'centimeters', 'NumberTitle', 'off');

hold on
plot(theta, psi1, '-k')
plot(theta, psi2, '-k')
plot(theta, rho1, '-g')
plot(theta, rho2, '-g')
plot(theta, rho2next, '-g')
plot(theta, drho, '-r')
plot(theta, rho, '-b')
hold off

set(gcf,'PaperUnits','centimeters'); 
set(gcf,'PaperSize',[42 29.7]);
fcycle = gcf;
fcycle.PaperUnits = 'centimeters';  
fcycle.PaperPosition = [0 0 42 29.7]; 
fcycle.Units = 'centimeters'; 
fcycle.PaperSize=[42 29.7]; 
fcycle.Units = 'centimeters'; 


%Plot of the normalized breathing cycle and first derivate

fnorm = figure('Name', 'Normalized Breath Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');

hold on
plot(theta, drhonorm, '-r')
plot(theta, rhonorm, '-b')
hold off


%Plot of a 1-cycle camshaft

fcam1 = figure('Name', '1-Cycle Camshaft', 'Units', 'centimeters', 'NumberTitle', 'off');

%hold on
%polar(theta, drhocam, '-r')
polar(theta, rhocam, '-b')
%hold off

set(gcf,'PaperUnits','centimeters'); 
set(gcf,'PaperSize',[42 29.7]);
fcam1 = gcf;
fcam1.PaperUnits = 'centimeters';  
fcam1.PaperPosition = [0 0 42 29.7]; 
fcam1.Units = 'centimeters'; 
fcam1.PaperSize=[42 29.7]; 
fcam1.Units = 'centimeters'; 


%Plot of a 2-cycle camshaft

fcam2 = figure('Name', '2-Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');

%hold on;
%polar(theta, drhocam2, '-r')
polar(theta2, rhocam2, '-b')
%hold off;

set(gcf,'PaperUnits','centimeters'); 
set(gcf,'PaperSize',[42 29.7]);
fcam2 = gcf;
fcam2.PaperUnits = 'centimeters';  
fcam2.PaperPosition = [0 0 42 29.7]; 
fcam2.Units = 'centimeters'; 
fcam2.PaperSize=[42 29.7]; 
fcam2.Units = 'centimeters'; 


%Plot of a 3-cycle camshaft

fcam3 = figure('Name', '3-Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');

%hold on;
%polar(theta,drhocam3)
polar(theta3, rhocam3)
%hold off;

set(gcf,'PaperUnits','centimeters'); 
set(gcf,'PaperSize',[42 29.7]);
fcam3 = gcf;
fcam3.PaperUnits = 'centimeters';  
fcam3.PaperPosition = [0 0 42 29.7]; 
fcam3.Units = 'centimeters'; 
fcam3.PaperSize=[42 29.7]; 
fcam3.Units = 'centimeters';
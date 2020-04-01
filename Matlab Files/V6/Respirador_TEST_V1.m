% The OxyGEN proyect by Profoty.xyz
% Together against the Covid-19
% V4.0 rev.17/03/2020
% 
% Website/blog: oxygen.protofy.xyz
% Contact: oxygen@protofy.xyz


%GEOMETRICAL PARAMETERS

%Length from the bearing to the hinge
l0 = 27.3;

%Length of the vertical wall that supports the hinge
h0 = 6.5;

%Lenght of the vertical support of the bearing
hb = 5.0;

%Bearing radius
br = 1.1;

%Array of different max and min positions of the bearing
h1a = [6.5, 8.5, 10.5, 12.5];
h2a = [20.5, 20.5, 20.5, 20.5];

%Number of cycles per cam turn (1 to 3).
nc = 1;

%Minimum radius of the camshaft
rmin = 5;


%BREATHING CYCLE PARAMETERS

%Duration of the inhale cycle / duration of the whole cycle
lambda1 = 0.500;
lambda2 = 0.060;

%Soft transition between inhale and exhale cycles
dpsi21 = 0.12;
dpsi12 = 0.15;

%Adjust parameters of the inhale curve
t1 = 2*pi*0.10;
t2 = 2*pi*0.49;
t3 = 2*pi*0.59;
t4 = 2*pi*0.99


%GENERATION OF THE CURVES AND THE CAMSHAFT

%Generation of the geometry

l = sqrt(l0^2+hb^2);


for i = 1:numel(h1a);
    
    ymin(i) = h1a(i);
    ymax(i) = h2a(i);
    
    alphamin(i) = acos((h0 - h1a(i)) / l);
    alphamax(i) = acos((h0 - h2a(i)) / l);
    
    xmin(i) = l*sin(alphamin(i));    
    xmax(i) = l*sin(alphamax(i));
    
    d(i) = sqrt((xmin(i)-xmax(i))^2 + (ymin(i)-ymax(i))^2);
    
    alphatan(i) = (alphamin(i) + alphamax(i)) / 2;
    
    xtan(i) = l*sin(alphatan(i));    
    ytan(i) = h0 - l*cos(alphatan(i));
    
    xsup(i) = xtan(i) + (d(i)/2)*cos(alphatan(i));
    xinf(i) = xtan(i) - (d(i)/2)*cos(alphatan(i));
    
    ysup(i) = ytan(i) + (d(i)/2)*sin(alphatan(i));
    yinf(i) = ytan(i) - (d(i)/2)*sin(alphatan(i));
    
    xcam(i) = xtan(i) + (d(i)/2 + rmin + br)*cos(alphatan(i));
    ycam(i) = ytan(i) + (d(i)/2 + rmin + br)*sin(alphatan(i));
    
end;


%Time increment
dt = 0.01;

%time coordinate during the whole cycle
theta = 0:dt:2*pi;

%Generation of the soft transition between inhale and exhale curves
psi1 = [];
psi2 = [];

for i = 1:numel(theta);
    
    if theta(i) < (lambda2-dpsi21/2)*2*pi;
        psi1(i) = 0;
        
    elseif theta(i) < (lambda2+dpsi21/2)*2*pi;
        psi1(i) = 0.5 + 0.5*cos((theta(i)-(lambda2+dpsi21/2)*2*pi)/(2*dpsi21));
        
    else theta(i) < (lambda1-dpsi12/2)*2*pi;
        psi1(i) = 1;
        
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
    
    if theta(i) < t1;
        rho(i) = 0;
        
    elseif theta(i) < t2;
        rho(i) = rho(i-1) + 1;
        
    elseif theta(i) < t3;
        rho(i) = 0;
        
    elseif theta(i) < t4;
        rho(i) = rho(i-1) +0.5;
        
    else
        rho(i) = rho(i-1);
    
    end;
 
    
    %Capturing min and max in order to generate the normalized curve
    if rho(i) > rhomax
        rhomax = rho(i);
    end;
    
    if rho(i) < rhomin
        rhomin = rho(i);
    end;

end;

rho(numel(rho)) = 0;

%Generation of a normalised curve and camshaft

rhonorm = [];
rhocam = [];

for i = 1:numel(theta);
    
    rhonorm(i) = (rho(i)-rhomin)/(rhomax-rhomin);
        
    for n = 1:numel(d)
        
        rhocam(n,i) = rmin + rhonorm(i)*d(n);
        
    end;
    
end;


%Generation of the first derivate of the camshaft geometry to analize and
%validate the design

drho = [];
drhonorm = [];
drhocam = [];

a = rmin;
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


fpos = figure('Name', 'Dimensions', 'Units', 'centimeters', 'NumberTitle', 'off');
set(gcf,'PaperUnits','centimeters', 'PaperSize', [42/2 27.9/2]);
set(gcf, 'units', 'centimeters', 'position', [0, 0, 28, 20]);
fpos = gcf;
hold on

xlim([-5 35]);
ylim([0 30]);

for i = 1:numel(xmin)
    
    plot([0, xmin(i)], [h0, ymin(i)], '-x')    
    plot([0, xmax(i)], [h0, ymax(i)], '-x')
    
    plot([0, xtan(i)], [h0, ytan(i)], '--xb')
    
    plot([xsup(i), xinf(i)], [ysup(i), yinf(i)], '--xr')
    scatter(xcam(1), ycam(1))

end;

hold off




%Plot of the breathing cycle interpolation by curves

fcycle = figure('Name', 'Breath Cycle curves', 'Units', 'centimeters', 'NumberTitle', 'off');

hold on
plot(theta, psi1, '-k')
%plot(theta, drho, '-r')
plot(theta, rho, '-b')
hold off

set(gcf,'PaperUnits','centimeters', 'PaperSize', [42/2 27.9/2]);
set(gcf, 'units', 'centimeters', 'position', [0, 0, 27.9, 27.9]);
fcam3 = gcf;


%Plot of the normalized breathing cycle and first derivate


fnorm = figure('Name', 'Normalized Breath Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');

hold on
%plot(theta, drhonorm, '-r')
plot(theta, rhonorm, '-b')
hold off

set(gcf,'PaperUnits','centimeters', 'PaperSize', [42 27.9]);
set(gcf, 'units', 'centimeters', 'position', [0, 0, 27.9, 27.9]);
fcam3 = gcf;


%Plot of a 1-cycle camshaft

for n = 1:numel(d)

    fcam1 = figure('Name', '1-Cycle Camshaft', 'Units', 'centimeters', 'NumberTitle', 'off');
    %hold on
   
    %polarplot(theta, drhocam, '-r')
    polar(theta, rhocam(n,:), '-b')

    
    %rlim([0 25]);
    hold off

    set(gcf,'PaperUnits','centimeters', 'PaperSize', [42 27.9]);
    set(gcf, 'units', 'centimeters', 'position', [0, 0, 27.9, 27.9]);
    fcam3 = gcf;
    
end


% %Plot of a 2-cycle camshaft
% 
% fcam2 = figure('Name', '2-Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');
% 
% %hold on;
% %polar(theta, drhocam2, '-r')
% polar(theta2, rhocam2, '-b')
% %hold off;
% 
% set(gcf,'PaperUnits','centimeters', 'PaperSize', [42 27.9]);
% set(gcf, 'units', 'centimeters', 'position', [0, 0, 27.9, 27.9]);
% fcam3 = gcf;
% 
% 
% %Plot of a 3-cycle camshaft
% 
% fcam3 = figure('Name', '3-Cycle', 'Units', 'centimeters', 'NumberTitle', 'off');
% 
% %hold on;
% %polar(theta,drhocam3)
% polar(theta3, rhocam3)
% %hold off;
% 
% set(gcf,'PaperUnits','centimeters', 'PaperSize', [42 27.9]);
% set(gcf, 'units', 'centimeters', 'position', [0, 0, 27.9, 27.9]);
% fcam3 = gcf;

% The OxyGEN proyect by Profoty.xyz
% Together against the Covid-19
% V4.0 rev.17/03/2020
% 
% Website/blog: oxygen.protofy.xyz
% Contact: oxygen@protofy.xyz
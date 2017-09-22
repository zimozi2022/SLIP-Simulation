robot = prismaticMonopod();
tspan = [0,3];
tr = Terrain;
tr = tr.flatGround();

robot = RK4Integrate(robot,tspan,@raibertController,tr);

%%
% Regenerate the loopup Table
obj = SLIPdynamics();
obj.dataTimeStep = 0.005;  %Output timestep (sec)
des_vel = 0.2; %m/s

lookupTable.xDot = 0:0.25:2;
lookupTable.yDot = -0.3:-0.25:-3;

[lookupTable.dX,lookupTable.dY] = meshgrid(lookupTable.xDot,lookupTable.yDot);
lookupTable.alpha = zeros(size(lookupTable.dX));

for i = 1:size(lookupTable.dX,1)
   for j = 1:size(lookupTable.dX,2)
       lookupTable.alpha(i,j) = findNeutralAngle(obj, lookupTable.dX(i,j), lookupTable.dY(i,j));
   end
end

save('lookupTable.mat','lookupTable');
%%
obj = SLIPdynamics();
obj.dataTimeStep = 0.005;  %Output timestep (sec)
des_vel = 1; %m/s
load('lookupTable.mat');
clear raibertController
ctrl = @(obj,q,qdot) EGBcontroller(obj,q,qdot,lookupTable);
obj = simulate(obj,ctrl,[0,10],des_vel);
%%
figure(9)
subplot(3,1,1)
hold off
plot(obj.t,obj.q(:,2));
ylabel('Body Vertical Position (m)');
xlabel('time (sec)');
title(['SLIP Raibert Hopper, Desired Speed ',num2str(des_vel),' m/sec']);
% axis([-inf,inf,-0.2,2])

subplot(3,1,2)
hold off
plot(obj.t,obj.qdot(:,1));
hold on
plot(obj.t,des_vel*ones(size(obj.t)),'--r');
legend('Simulation','Desired');
ylabel('Body Horizontal velocity (m/sec)');
xlabel('time (sec)');

subplot(3,1,3)
hold off
plot(obj.t,obj.q(:,4));
hold on
plot(obj.t,0.1*obj.dynamic_state_arr);
legend('Leg Angle','0.1*state');
ylabel('Leg angle ');
xlabel('time (sec)');
%%
aObj = monopedAnimation(robot);
for i = 1:length(robot.t)
%    aObj.dispAtIndex(i);
%    keyboard
end
aObj.runAnimation();

%%
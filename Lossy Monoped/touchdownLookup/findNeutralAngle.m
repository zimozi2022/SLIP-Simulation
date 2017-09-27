function [ alphaTD ] = findNeutralAngle(simObject, xDot, yDot)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
persistent obj;
if isempty(obj)
    obj = liftOffSimulation(simObject,0.7);
end
obj.xDot = xDot;
obj.yDot = yDot;
alphaTD = fmincon(@(x)obj.simulate(x),0.1,[1;-1],[pi/2;pi/2]);
end


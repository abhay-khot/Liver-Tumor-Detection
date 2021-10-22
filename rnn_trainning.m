% Solve a Pattern Recognition Problem with a Regression Neural Network
%
% This script assumes these variables are defined:
%   fused_feature - input data.
%   fused_label - target data.

load('fused_feature.mat')
load('fused_label.mat')
x = fused_feature;
t = fused_label;
percentErrors = 50;
hiddenLayerSize=10;
while percentErrors > 0.2
    
% Create a Pattern Recognition Network
% hiddenLayerSize = hiddenLayerSize;
net = patternnet(hiddenLayerSize);
hiddenLayerSize = hiddenLayerSize+1;

% Setup Division of Data for Training, Validation, Testing
net.divideParam.trainRatio = 90/100;
net.divideParam.valRatio = 5/100;
net.divideParam.testRatio = 5/100;


% Train the Network
[net,tr] = train(net,x,t);

% Test the Network
y = net(x);
e = gsubtract(t,y);
tind = vec2ind(t);
yind = vec2ind(y);
percentErrors = sum(tind ~= yind)/numel(tind)
performance = perform(net,t,y);

end
% View the Network
view(net)

% Plots
% Uncomment these lines to enable various plots.
figure, plotperform(tr)
figure, plottrainstate(tr)
figure, plotconfusion(t,y)
figure, plotroc(t,y)
figure, ploterrhist(e)

accuracy = (1-percentErrors)*100;
save accuracy accuracy
hiddenLayerSize
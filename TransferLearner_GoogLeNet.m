%Ref:https://in.mathworks.com/help/deeplearning/ug/train-deep-learning-network-to-classify-new-images.html
%Note: The code in ref works best for 2020 matlab but the code below has
%been adjusted so as to work for 2018b matlab as well.Additional comments and material has been added.
%Code for ploting Confusion Matrix also added
%% 
%% This m file is expected to run after running a clear command in matlab Command Window

%%  PREREQUISITE: This m file can operate only if:

%a) This mfile is in the same folder as the mfile findLayersToReplace.m
%b) Deep Learning Toolbox Model for GoogLeNet Network is installed
%c) There is a a folder named TrainingData which contains training images
%   seggregated in to subfolders named after the category labels of training images

%% 
%% 0. LOAD DATA
%% 
imds = imageDatastore('TrainingData','IncludeSubfolders',true,'LabelSource','foldernames');
[imdsTrain,imdsValidation] = splitEachLabel(imds,0.8,'randomized');

%% 1. LOAD PRETRAINED DNN
%% Note:googlenet should be installed prior to running the line below
net = googlenet;

%% 2. DETERMINE THE DIMENSIONS OF INPUT IMAGE
%% This code finds the dimension of input image for googlenet and assigns it to inputSize
inputSize = net.Layers(1).InputSize;

%% 3. REPLACE LAST LAYERS
%% 3a)Extract the layer graph from the trained network... 
    %If the network is a SeriesNetwork object(AlexNet,VGG-16,or VGG-19)...
    %then convert the list of layers in net.Layers to a layer graph.
if isa(net,'SeriesNetwork') 
  lgraph = layerGraph(net.Layers); 
else
  lgraph = layerGraph(net);
end 
%% 3b)Find the names of the two layers to replace (use the function findLayersToReplace to find these layers automatically)
    %Note: findLayersToReplace.m should be present in the folder of this mfile to execute the line below
    
[learnableLayer,classLayer] = findLayersToReplace(lgraph);


%% 3c) (i)Obtain the number of new classes,
      %(ii)Check the type of last layer with learnable weights
      %(iii)Replace with corresponding new layers
    %In most networks, the last layer with learnable weights is a fully connected layer...
    %Replace this fully connected layer with a new fully connected layer with ...
    %the number of outputs equal to the number of classes in the new data set.
    %In some networks, such as SqueezeNet, the last learnable layer is a 1-by-1 convolutional layer instead. 
    %In this case, replace the convolutional layer with a new convolutional layer with...
    %the number of filters equal to the number of classes.
    %To learn faster in the new layer than in the transferred layers, increase the learning rate factors of the layer.

numClasses = numel(categories(imdsTrain.Labels));% Obtains the number of classes/categories from our training data

if isa(learnableLayer,'nnet.cnn.layer.FullyConnectedLayer')
    newLearnableLayer = fullyConnectedLayer(numClasses, ...
        'Name','new_fc', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
    
elseif isa(learnableLayer,'nnet.cnn.layer.Convolution2DLayer')
    newLearnableLayer = convolution2dLayer(1,numClasses, ...
        'Name','new_conv', ...
        'WeightLearnRateFactor',10, ...
        'BiasLearnRateFactor',10);
end

lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);

    %The classification layer specifies the output classes of the network. 
    %Replace the classification layer with a new one without class labels. 
    %trainNetwork automatically sets the output classes of the layer at training time.
newClassLayer = classificationLayer('Name','new_classoutput');
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);
%%  4 CHECKING THE NEW DNN
%%  To check that the new layers are connected correctly,
    %plot the new layer graph and zoom in on the last layers of the network.
figure('Units','normalized','Position',[0.3 0.3 0.4 0.4]);
plot(lgraph)
ylim([0,10])

%%  5 FREEZE INITIAL LAYERS
%%
layers = lgraph.Layers;

    for i = 1:10
        if isprop(layers(i),'WeightLearnRateFactor')
            layers(i).WeightLearnRateFactor = 0;
        end
        if isprop(layers(i),'WeightL2Factor')
            layers(i).WeightL2Factor = 0;
        end
        if isprop(layers(i),'BiasLearnRateFactor')
            layers(i).BiasLearnRateFactor = 0;
        end
        if isprop(layers(i),'BiasL2Factor')
            layers(i).BiasL2Factor = 0;
        end
    end

%%  6 DATA AUGMENTATION 
    %(additional augmentation like flipping,scaling etc , required only for
    %training set)
    % Validation set just need to be reshaped to input size
%%
pixelRange = [-30 30];
scaleRange = [0.9 1.1];
imageAugmenter = imageDataAugmenter( ...
    'RandXReflection',true, ...
    'RandXTranslation',pixelRange, ...
    'RandYTranslation',pixelRange, ...
    'RandXScale',scaleRange, ...
    'RandYScale',scaleRange);
augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain, ...
    'DataAugmentation',imageAugmenter);

augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);
%%  7 Specify the training options. 
    %Set InitialLearnRate to a small value to slow down learning in the 
    %transferred layers that are not already frozen. 
    %In the previous step, you increased the learning rate factors for 
    %the last learnable layer to speed up learning in the new final layers.
    %This combination of learning rate settings results in fast learning
    %in the new layers, slower learning in the middle layers, and 
    %no learning in the earlier, frozen layers.
    %Specify the number of epochs to train for. 
    %When performing transfer learning, you do not need to train for as many epochs.
    %An epoch is a full training cycle on the entire training data set. 
    %Specify the mini-batch size and validation data. 
    %Compute the validation accuracy once per epoch.
 %% 
miniBatchSize = 16;% usually varied as power of 2 i.e 8, 16, 32, 64 but should not be greater than number of images in training data

valFrequency = 7;% The value of valFrequency is found by rounding (number of images in training data/miniBatchSize) to lower integer value
options = trainingOptions('sgdm', ...
    'MiniBatchSize',miniBatchSize, ...
    'MaxEpochs',15, ...
    'InitialLearnRate',3e-4, ...
    'Shuffle','every-epoch', ...
    'ValidationData',augimdsValidation, ...
    'ValidationFrequency',valFrequency, ...
    'Verbose',false, ...
    'Plots','training-progress');
%%  8 TRAIN NEW DNN
%%
googlenetTL = trainNetwork(augimdsTrain,lgraph,options);

%%  Classify the validation images using the fine-tuned network, and calculate and display the classification accuracy.
[YPred,probs] = classify(googlenetTL,augimdsValidation);
accuracy = mean(YPred == imdsValidation.Labels) ;
disp(" Accuracy is :")
disp(accuracy)

%%  Display six sample validation images with predicted labels and 
    %the predicted probabilities of the images having those labels.
    
idx = randperm(numel(imdsValidation.Files),6);
figure('Name','Performance on six random validation samples')
for i = 1:6
    subplot(2,3,i)
    I = readimage(imdsValidation,idx(i));
    imshow(I)
    label = YPred(idx(i));
    title(string(label) + ", " + num2str(100*max(probs(idx(i),:)),3) + "%");
end
%% Plot Confusion Matrix for Training and validation Data
conf_augimdsTrain = augmentedImageDatastore(inputSize(1:2),imdsTrain);
conf_augimdsValidation = augmentedImageDatastore(inputSize(1:2),imdsValidation);
[trainPreds,train_probs] = classify(googlenetTL,conf_augimdsTrain);
[validPreds,valid_probs] = classify(googlenetTL,conf_augimdsValidation);

[conf_train,names_train] = confusionmat(imdsTrain.Labels,trainPreds);
[conf_valid,names_valid] = confusionmat(imdsValidation.Labels,validPreds);

figure
plotconfusion(imdsTrain.Labels,trainPreds);
title('Confusion Matrix for Training Data')
figure
plotconfusion(imdsValidation.Labels,validPreds);
title('Confusion Matrix for Validation Data')

% other options

% figure('Name','Confusion Chart for Training Data')
% cc_train = confusionchart(imdsTrain.Labels,trainPreds);
% figure('Name','Confusion Chart for Validation Data')
% cc_valid = confusionchart(imdsValidation.Labels,validPreds);



% figure('Name','Training Data Confusion Matrix')
% heatmap(names_train,names_train,conf_train);
% xlabel('Predicted Class');
% ylabel('True Class');
% figure('Name','Validation Data Confusion Matrix')
% heatmap(names_valid,names_valid,conf_valid);
% xlabel('Predicted Class');
% ylabel('True Class');



 
%% Save the new DNN and clear up the workspace and load only the transfer learned network in workspace for further use

%a)save googlenetTL
save googlenetTL googlenetTL
% b) Clear all objects in workspace 
clear
load googlenetTL
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

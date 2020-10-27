%% This mfile displays and classifies 1000 continuous snaps from a mobile with IP Webcam app installed
%% assign url with url displayed in mobile
url='http://192.168.43.1:8080/video';
%url='http://100.75.112.215:8080/video';
%% define an ipcam object with the above url
cam = ipcam(url);
%% load the Deep Neural Net
load RSETnet;% The name of network you want to use

nnet = RSETnet;% The name of network you want to use

%% Use the DNN to classify snaps from the ipcam (mobile with app)

for n=1:1000
    img = snapshot(cam);
    img = imresize(img,[224,224]);%googlelenet or network using similar size
    %img = imresize(img,[227,227]);%squeezenet
    %img = imresize(img,[224,224]);%resnet18,50,101
    %img = imresize(img,[299,299]);%inceptionv3,inceptionresnetv2
    [label,score] = classify(nnet,img);
    
    imshow(img)
    
    title(string(label)+","+num2str(max(score),2))
    
    drawnow()
    %label
    
end

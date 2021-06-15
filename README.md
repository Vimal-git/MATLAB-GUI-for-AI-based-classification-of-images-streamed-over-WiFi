# General Description
* This project provides a MATLAB GUI displaying labeled pictures of images streamed from a Wi-Fi Connected Android Phone.
* A transfer learned GoogLeNet, RSETnet.mat is provided to perform the classification.
* It also provides m-files  and GUIs to collect images on PC from a Wi-Fi Connected Android Phone to develop a transfer learned googlenet with a fresh set of labels.

**Note:** The link [here](https://in.mathworks.com/help/deeplearning/ug/train-deep-learning-network-to-classify-new-images.html), was very resourceful in the development of the project

## Prerequisites
The project requires the following MATLAB Tool boxes
* MATLAB Support Package for IP Cameras
* Deep Learning Toolbox
* Signal Processing Toolbox
* DSP System Toolbox
* Audio System Toolbox
* Deep Learning Toolbox model for GoogLeNet Network

_Note: This project was developed on MATLAB 2018b.A transfer learned GoogLeNet named RSETnet is provided for reference. This classify images under five labels (hand,unknown,eraser,potentiometer and tape)_

## Steps to use the project files

1.	Save the matlab files in same folder.

2.	This folder named TrainingData should be created in the same folder.

3.	TrainingData should contain your training images segregated in to subfolders with labels denoting correct labels for training DNN

4.	You need to install the "IP Webcam app" (available from playstore, you may use other apps but I have not tried others) on your android phone to use it as an IP Camera to stream images to laptop running MATLAB

5.	The laptop running MATLAB and the Android phone streaming images should be connected to same Wi-Fi network.

6.	GUIs and classifyMobileSnaps.m. should be used only after activating start server option in IP Webcam app installed in your mobile

7.	classifyMobileSnaps.m is an m-file should be used only if there is a DNN named RSETnet.mat in the current folder (or the name RSETnet should be replaced by appropriate names at lines 8 and 10 of m-file.to display mobile snaps with labels and probability using a transfer learned GoogLeNet named RSETnet.)



8.	Right click on LiveTrainingDataCollect.mlapp  and click open,a GUI open,then click on Code View tab at top and  go to line 76 and replace 'PROVIDE PATH TO FOLDER TO COLLECT DATA'  with the path to the folder where you want the images to be stored in single inverted comas(eg 'E:\DataCollect\')


9.	The above GUI will enable you to collect live data from GUI for training. 

10.	The images so collected can be segregated in to folders with corresponding labels and placed in the folder named TrainingData mentioned in step 2.

11.	TransferLearner_GoogLeNet.m is an m-file to modify a standard pre-trained GoogLeNet in MATLAB with new training data in the folder named TrainingData. It will display six random results  and  plot confusion matrices for training and validation data.The newly created network is named googlenet_TL and made available in workspace at end of execution. Note: TransferLearner_GoogLeNet.m requires findLayersToReplace.m file in the same folder to work.
 
12.	 The network needs renaming so as to be used with GUIs and classifyMobileSnaps.m is provided in this project. The default name of network used by GUI and classifyMobileSnaps.m is RSETnet.To change the default network name in classifierGUI.mlapp change 'RSETnet' in line 79 with your network name.

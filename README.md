# General Description
* This project provides a MATLAB GUI "classifierGUI.mlapp" to display on monitor labeled pictures of images streamed from an Android phone over Wi-Fi.
* A transfer learned GoogLeNet, RSETnet.mat is provided to perform the classification.
* RSETnet.mat is trained to classify images in to five classes 1)tape 2)eraser 3)hand 4)potentiometer and 5)unknown
* It also provides m-files  and GUIs to collect images on PC from a Wi-Fi Connected Android Phone to develop a transfer learned googlenet with a fresh set of labels.

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

1. Save the matlab files in same folder.

2. You need to install the "IP Webcam app" (available from playstore, you may use other apps but I have not tried others) on your android phone to use it as an IP Camera to   stream images to laptop running MATLAB

3. The laptop running MATLAB and the Android phone streaming images should be connected to same Wi-Fi network.

4. Start MATLAB and add the folder containing the project files to path

5. Navigate through folders to make this project folder as your `Current Folder` in MATLAB.

6. load `RSETnet.mat` to the workspace.

7.  Activate `Start server` option in `IP Webcam` app installed on your Android phone. [Refer this link for details](https://in.mathworks.com/help/supportpkg/ipcamera/ug/acquire-images-from-an-ip-camera-android-app.html)

8. `classifyMobileSnaps.m` is an m-file which when run displays and classifies 1000 continuous snaps from a mobile with IP Webcam app installed.

9. This mfile should be run only if there is a DNN named RSETnet.mat is loaded in the workspace (or the name RSETnet should be replaced by appropriate names at lines 8 and 10 of m-file.to display mobile snaps with labels and probability using a transfer learned GoogLeNet named RSETnet.)

10. This mfile has well commented code to help understand the important commands required to acquire an image send over Wi-Fi, read it, classify it and display it on monitor with annotation of the category/label to which the image is classified. 

11. RSETnet.mat is trained to classify images in to five classes 1)tape 2)eraser 3)hand 4)potentiometer and 5)unknown

12. A GUI can be used as a better user interface for the same classification and `classifierGUI.mlapp` provides this GUI 

13. Right click on `classifierGUI.mlapp` and click open,the GUI opens in editing mode

14. Click on run symbol at the top to run the GUI. 
    
15. Check for URL displayed in your mobile phone and select the same URL from the dropdown list at top or type the URL in the space provided on the adjacent right side if the URL on the mobile phone is not available in the drop down list.
![image](https://user-images.githubusercontent.com/55146987/122599897-ac523680-d08c-11eb-8ead-68b8aacf1de5.png)

16. Click on `Activate Camera` button on GUI to stream images from the phone and start classification.

17. The classified label shall be anotated with probability as shown below.
![image](https://user-images.githubusercontent.com/55146987/122601461-f20ffe80-d08e-11eb-8b1a-47020b26a6d8.png)

18. This GUI only classifies images in to classes for which RSETnet was trained but if classification has to be done for different classes then a different network trained for that particular clases should be loaded in to workspace.

## Using GUI with a different Deep Neural Network(DNN) accepting RGB images as input

1. Assume that you have a DNN named `YourNet.mat` which accepts RGB images with input size of `[227 227]`.

2. To make the GUI classify as per `YourNet.mat` open `classifierGUI.mlapp` in editing mode and click on `Code View`.

3. At line 77 the code is as below 
```
img1 = imresize(img,[224,224]);%RSETnet

``` 
change `[224 224]` in the above code at line 77 to`[227 227]`or whatever the input size of the network you use for classifying RGB images.

4. At line 79 the code is as below 
``` 
nnet = evalin('base','RSETnet');
```
change `'RSETnet'` in the above code at line 79 to `'YourNet'` or whatever name your network has within single inverted comas. 

5. Save the changes and you can run the classification with different classes.

6. If you do not have a network suiting your requirement you need to create one

## Creating DNN for custom classification by transfer learning googlenet

1. A folder named `TrainingData` should be created in the folder containing all your project files.

2. Create subfolders in `TrainingData` with same names as the classes/labels to which images need to be classified.

3. These subfolders need to be populated with images of objects in the respective classes.

4. A GUI to store images streamed from mobile to a specified path shall be ideal.

5. `LiveTrainingDataCollect.mlapp` is such a GUI.

6. Right click on `LiveTrainingDataCollect.mlapp` and click on open,a GUI open in editing mode.

7. Click on `Code View` tab at top and  go to line 76 and replace `'PROVIDE PATH TO FOLDER TO COLLECT DATA'`  with the `'path to the sub-folder in TrainingData folder'` (eg `'E:\
MATLAB-GUI-for-AI-based-classification-of-images-streamed-over-WiFi\TrainingData\CLASS_1'`)

8. The above GUI will enable you to collect live data from GUI for training.
	 
9. `TransferLearner_GoogLeNet.m` is an m-file to modify a standard pre-trained GoogLeNet in MATLAB with new training data in the folder named TrainingData. It will display six random results  and  plot confusion matrices for training and validation data.

10. The newly created network is named googlenet_TL and made available in workspace at end of execution. 
    _Note: TransferLearner_GoogLeNet.m requires findLayersToReplace.m file in the same folder to work._
 
## Acknowledgement
The link [here](https://in.mathworks.com/help/deeplearning/ug/train-deep-learning-network-to-classify-new-images.html),from Mathworks documentation was very resourceful in the development of the project.



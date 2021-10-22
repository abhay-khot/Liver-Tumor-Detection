function varargout = main(varargin)
% MAIN MATLAB code for main.fig
%      MAIN, by itself, creates a new MAIN or raises the existing
%      singleton*.
%
%      H = MAIN returns the handle to a new MAIN or the handle to
%      the existing singleton*.
%
%      MAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAIN.M with the given input arguments.
%
%      MAIN('Property','Value',...) creates a new MAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before main_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to main_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES


% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @main_OpeningFcn, ...
                   'gui_OutputFcn',  @main_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before main is made visible.
function main_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to main (see VARARGIN)

% Choose default command line output for main
handles.output = hObject;

set(handles.pushbutton2,'Enable','Off');
set(handles.pushbutton3,'Enable','Off');
set(handles.pushbutton4,'Enable','Off');
set(handles.pushbutton5,'Enable','Off');
set(handles.pushbutton6,'Enable','Off');
set(handles.pushbutton9,'Enable','Off');
set(handles.pushbutton8,'Enable','Off');
% Update handles structure
guidata(hObject, handles);
%  set(handles.figure1,'Units','Pixels','Position',get(0,'ScreenSize'))
% UIWAIT makes main wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = main_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Id Ib Iorg filename pathname
[filename,pathname] = uigetfile({'*.jpg'}, 'Pick a Image File');
Id = imread([pathname,filename]);
Iorg = [];
if size(Id,3) ==1
    Iorg(:,:,1) =Id;
    Iorg(:,:,2) =Id;
    Iorg(:,:,3) =Id;
else
    Iorg = Id;
end
Ib=Id;
% dicomwrite(Id,'test_mammo.dcm');
axes(handles.axes1),imshow(Id),title('Input Test Image')
set(handles.pushbutton2,'Enable','On');

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Histogram Equalization
global Id
if size(Id,3)>2
    Id = rgb2gray(Id);
end
Id = adapthisteq(Id,'clipLimit',0.02,'Distribution','rayleigh');
axes(handles.axes2),imshow(Id),title('Histogram Equalized Image')
set(handles.pushbutton3,'Enable','On');

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%Median Filter
global Id
Id=medfilt2(Id);
axes(handles.axes3),imshow(Id),title('Median Filtered Image')
set(handles.pushbutton4,'Enable','On');


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global Id I2 Iorg
% segmentation
I=Iorg;

lab_he=colorspace('Lab<-RGB',I); 

% Classify the colors in a*b* colorspace using K means clustering.
% Since the image has 3 colors create 3 clusters.
% Measure the distance using Euclidean Distance Metric.
ab = double(lab_he(:,:,2:3));       %change the data type to double of the Green and Blue matrix
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
nColors = 3;
[cluster_idx cluster_center] = litekmeans(ab,nColors,'distance','sqEuclidean', ...
                                      'Replicates',3);
%[cluster_idx cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean','Replicates',3);
% Label every pixel in tha image using results from K means
pixel_labels = reshape(cluster_idx,nrows,ncols);
%figure,imshow(pixel_labels,[]), title('Image Labeled by Cluster Index');

% Create a blank cell array to store the results of clustering
segmented_images = cell(1,3);
% Create RGB label using pixel_labels
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColors
    colors = I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
end



 figure,subplot(2,3,2);imshow(I);title('Original Image'); subplot(2,3,4);imshow(segmented_images{1});title('Cluster 1'); subplot(2,3,5);imshow(segmented_images{2});title('Cluster 2');
 subplot(2,3,6);imshow(segmented_images{3});title('Cluster 3');
 set(gcf, 'Position', get(0,'Screensize'));
 set(gcf, 'name','Segmented by K Means', 'numbertitle','off')
 % Feature Extraction
 pause(2)
 x = inputdlg('Enter the cluster no. containing the ROI only:');
 i = str2double(x);
% i=2;
% Extract the features from the segmented image
seg_img = segmented_images{i};
seg_imgb = rgb2gray(seg_img);
I1=seg_imgb<80;
I2=seg_imgb>60&seg_imgb<120;
I3=seg_imgb>150;

axes(handles.axes7),imshow(I1), title('SEGMENTED CLUSTER 1');
axes(handles.axes4),imshow(I2), title('SEGMENTED CLUSTER 2');
axes(handles.axes5),imshow(I3), title('SEGMENTED CLUSTER 3');
set(handles.pushbutton5,'Enable','On');
I2 = I3;

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I2 tr rmdar

I3=imclearborder(I2);
se2 = strel('disk',2);
tr=imdilate(I3,se2);
tr = bwareaopen(tr,300);

rmdar=tr;
axes(handles.axes7),imshow(rmdar),title('After Morphological Operation')
set(handles.pushbutton6,'Enable','On');

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global filename pathname feat_disease
pr = imread([pathname,filename]);
pr=imresize(pr,[256 256]);
seg_img=pr;
if size(seg_img,3) == 3
   img = rgb2gray(seg_img);
else
    img=seg_img;
end

img = adapthisteq(img,'clipLimit',0.02,'Distribution','rayleigh');

% Create the Gray Level Cooccurance Matrices (GLCMs)
glcms = graycomatrix(img);

% Derive Statistics from GLCM
stats = graycoprops(glcms,'Contrast Correlation Energy Homogeneity');
Contrast = stats.Contrast;
Correlation = stats.Correlation;
Energy = stats.Energy;
Homogeneity = stats.Homogeneity;
Mean = mean2(seg_img);
Standard_Deviation = std2(seg_img);
Entropy = entropy(seg_img);
RMS = mean2(rms(seg_img));
%Skewness = skewness(img)
Variance = mean2(var(double(seg_img)));
a = sum(double(seg_img(:)));
 Smoothness = 1-(1/(1+a));
Kurtosis = kurtosis(double(seg_img(:)));
Skewness = skewness(double(seg_img(:)));
% Inverse Difference Movement
m = size(seg_img,1);
n = size(seg_img,2);
in_diff = 0;
for i = 1:m
    for j = 1:n
        temp = seg_img(i,j)./(1+(i-j).^2);
        in_diff = in_diff+temp;
    end
end
 IDM = double(in_diff);
    
feat_disease = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance, Smoothness,Kurtosis, Skewness,IDM];
set(handles.text5,'string',feat_disease)
feat_disease = [Contrast,Correlation,Energy,Homogeneity, Mean, Standard_Deviation, Entropy, RMS, Variance,Kurtosis, Skewness];
set(handles.pushbutton8,'Enable','On');

% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
rnn_trainning
load accuracy
set(handles.edit1,'string',num2str(accuracy));
set(handles.pushbutton9,'Enable','On');

% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global feat_disease

load('dataset1.mat')

% Put the test features into variable 'test'

result = multisvm(datase,diseasetype,feat_disease);
%disp(result);

% Visualize Results
if result == 1
    R1 = 'T1 Type ';
    helpdlg(R1);
    disp(R1);
elseif result == 2
    R1 = 'T2 Type ';
    helpdlg(R1);
    disp(R1);
elseif result == 3
    R1 = 'T3 Type ';
    helpdlg(R1);
    disp(R1);
elseif result == 4
    R1 = 'T4 Type ';
    helpdlg(R1);
    disp(R1);
elseif result == 5
    R1 = 'T4 Type ';
    helpdlg(R1);
    disp(R1);
end
set(handles.edit2,'string',R1);
    


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
clc;
clear all;
close all;

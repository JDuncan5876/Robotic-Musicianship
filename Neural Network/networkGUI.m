function varargout = networkGUI(varargin)
% NETWORKGUI MATLAB code for networkGUI.fig
%      NETWORKGUI, by itself, creates a new NETWORKGUI or raises the existing
%      singleton*.
%
%      H = NETWORKGUI returns the handle to a new NETWORKGUI or the handle to
%      the existing singleton*.
%
%      NETWORKGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NETWORKGUI.M with the given input arguments.
%
%      NETWORKGUI('Property','Value',...) creates a new NETWORKGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before networkGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to networkGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help networkGUI

% Last Modified by GUIDE v2.5 28-Apr-2016 01:36:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @networkGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @networkGUI_OutputFcn, ...
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


% --- Executes just before networkGUI is made visible.
function networkGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to networkGUI (see VARARGIN)

% Choose default command line output for networkGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Initialize Video Input Parameters
global vid;
global endFunc;
vid = videoinput('kinect', 2);
vid.FramesPerTrigger = 100;
vid.TriggerRepeat = 100000;
triggerconfig(vid, 'manual');
src = getselectedsource(vid);
src.EnableBodyTracking = 'on';
endFunc = false;
hObject.CloseRequestFcn = @stopProgram;

% Stop Kinect Feed on Window Close
function stopProgram(hObject, ~)
    global endFunc;
    global vid;
    endFunc = true;
    stop(vid);
    delete(hObject);

% UIWAIT makes networkGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = networkGUI_OutputFcn(hObject, eventdata, handles) 
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
global vid;

% Get object handles
leftText = handles.text2;
leftPanel = handles.uipanel1;
rightText = handles.text3;
rightPanel = handles.uipanel3;

% Gather input data from current setup
hObject.Visible = 'off';
start(vid);
XData1 = calibrate(leftText, leftPanel);
pause(2);
XData2 = calibrate(rightText, rightPanel);
stop(vid);
y = ones(size(XData1, 1), 1);
y = [y; ones(size(XData2, 1), 1) * 2];
X = [XData1; XData2];

% Train Neural Network
input_layer_size = size(X, 2);
hidden_layer_size = 5;
num_labels = 2;
lambda = 0;
[Theta1, Theta2] = driveNetwork(X, y, input_layer_size, hidden_layer_size, num_labels, lambda);

% Make Predictions/Check Accuracy
prediction = predict(Theta1, Theta2, X);
accuracy = length(find(y == prediction)) / length(y);
fprintf('Training Accuracy: %1.2f%%\n', accuracy * 100);

% Output to file (to be read by program in Max/MSP)
fid = fopen('Thetas.txt', 'w');
thetas = [Theta1(:); Theta2(:)];
for ind = 1:length(thetas)
    fprintf(fid, '%d, %1.4f;\r\n', ind - 1, thetas(ind));
end
fclose(fid);

% Run prediction program
livePrediction(Theta1, Theta2, leftText, leftPanel, rightText, rightPanel);

function XData = calibrate(textHandle, panelHandle)
global vid;

% Display desired side
textHandle.Visible = 'on';
panelHandle.Visible = 'on';

pause(1);

% Gather input data from kinect, store in array XData
trigger(vid);
pause(4);
XData = [];
[~, ~, metaData] = getdata(vid);
for ind = 1:length(metaData)
    sample = metaData(ind);
    if any(sample.IsBodyTracked)
        positions = sample.JointPositions(:, :, sample.IsBodyTracked);
        XLine = [positions(9, :), positions(10, :), positions(11, :)];
        if isempty(XData)
            XData = XLine;
        else
            XData = [XData; XLine];
        end
    end
end

% Shut off side
textHandle.Visible = 'off';
panelHandle.Visible = 'off';

function livePrediction(Theta1, Theta2, leftText, leftPanel, rightText, rightPanel)
global vid;
global endFunc;

% Redeclare variables for live feed prediction
vid.FramesPerTrigger = 3;
vid.TriggerRepeat = 100000;
start(vid);

% Gather data/predict position, turn on corresponding side of the GUI
while ~endFunc;
    trigger(vid);
    pause(0.11);
    [~, ~, metaData] = getdata(vid);
    ind = 1;
    while ind <= length(metaData) && ~any(metaData(ind).IsBodyTracked)
        ind = ind + 1;
    end
    if ind <= length(metaData)
        positions = metaData(ind).JointPositions(:, :, metaData(ind).IsBodyTracked);
        X = [positions(9, :), positions(10, :), positions(11, :)];
        prediction = predict(Theta1, Theta2, X);
        if prediction == 1
            rightText.Visible = 'off';
            rightPanel.Visible = 'off';
            leftText.Visible = 'on';
            leftPanel.Visible = 'on';
        else
            leftText.Visible = 'off';
            leftPanel.Visible = 'off';
            rightText.Visible = 'on';
            rightPanel.Visible = 'on';
        end
    end
end
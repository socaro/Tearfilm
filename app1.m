


function varargout = app1(varargin)
% APP1 MATLAB code for app1.fig
%      APP1, by itself, creates a new APP1 or raises the existing
%      singleton*.
%
%      H = APP1 returns the handle to a new APP1 or the handle to
%      the existing singleton*.
%
%      APP1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APP1.M with the given input arguments.
%
%      APP1('Property','Value',...) creates a new APP1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before app1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to app1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help app1

% Last Modified by GUIDE v2.5 15-Mar-2017 15:01:46

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @app1_OpeningFcn, ...
                   'gui_OutputFcn',  @app1_OutputFcn, ...
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


% --- Executes just before app1 is made visible.
function app1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to app1 (see VARARGIN)

%%initialize data structures and load image
handles.im=imread('im_d/Sophie0131-1426-d-cr.tif');     %read image
handles.imc=add_coord(handles.im);                      %add coordinates to image and transform to L*a*b space
sizeim=size(handles.im);                                %determine size of image
handles.fringes=cell(0);                                %initialize fringes as cell array for all future fringes
handles.fringeselect=cell(0);                           %create cell array to save string for popupmenu for fringe selection
handles.fringe=zeros(sizeim(1),sizeim(2));              %initialize sum of fringes
handles.dispthickness=zeros(size(handles.fringe));      %initialize thickness plot
handles.initial_color=zeros(100,100,3);                 %initialize image for current color
[handles.cim,handles.cm]=gen_cim();                     %generate colormap
cimlabel=ones(length(handles.cim(:,1,1))*10,2);         %create label for reference colormap

set(handles.col_select,'Enable','off');                 %disable Color Select button until fringe is added

%%display all initial images on axes
axes(handles.axes1);
imshow(handles.im);

axes(handles.axes2);
imshow(handles.cim);

axes(handles.axes3);
imshow(handles.fringe);

axes(handles.axes4);
imshow(handles.initial_color);

axes(handles.axes5);
imshow(cimlabel)
axis on;

% Choose default command line output for app1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes app1 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Executes on button press in Select Color.
function col_select_Callback(hObject, eventdata, handles)
% hObject    handle to col_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=handles.current_fringe_nr;               
set(handles.text2,'String','pick color');
%% allow user to select color
axes(handles.axes2);
[~,y,color]=impixel(handles.cim);
%% use position and pixel value to compute thickness and color image for display
handles.fringes{f}.thickness=(y-1)*10;      %save selected thickness for use in other functions
imcolor=zeros(100,100,3);
for i=1:3;imcolor(:,:,i)=color(i);end
handles.fringes{f}.color=imcolor;           %save color image for use in other functions
%% display image and selected thickness
axes(handles.axes4);
imshow(uint8(handles.fringes{f}.color));
set(handles.text4,'String',sprintf('Fringe Thickness: \n %d nm',handles.fringes{f}.thickness));
%% update handles
guidata(hObject,handles);

% --- Executes on button press in points (select points for current fringe)
function points_Callback(hObject, eventdata, handles)
% hObject    handle to points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try 
f=handles.current_fringe_nr;
%%select points of current color from frame
axes(handles.axes1);
[c,r,~]=impixel(handles.im);
%%find color region
[handles.fringes{f}.fringe,handles.fringes{f}.dispthickness]=cluster_fringe(handles,r,c,f);
handles.fringe=handles.fringe+handles.fringes{f}.fringe; %add current fringe to image of all fringes (for plot all fringes)
handles.fringe(handles.fringe==2)=1;                     %set points reselected to one
%%display selected fringe
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);
%%disable Color Select button (so that color cannot be changed once points
%%have been selected)
set(handles.col_select,'Enable','off');
catch 
    h=msgbox('Make sure that you have selected a color');
end 
guidata(hObject,handles);

% --- Executes on button press in plot_fringe (plot all fringes).
function plot_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to plot_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes3);
imshow(handles.fringe);

% --- Executes on button press in plots (plot Thickness)
function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dispthickness=zeros(size(handles.fringe)); %reset thickness plot
%%add thicknesses obtained for all fringes
for i=1:length(handles.fringes)
   handles.dispthickness=handles.dispthickness+handles.fringes{i}.dispthickness; 
end
%%interpolate
[r,c,v]=find(handles.dispthickness);        %non-zero entries to be used for interpolation
rq=1:1:length(handles.dispthickness(:,1));  %create grid
cq=1:1:length(handles.dispthickness(1,:));
[rq,cq]=meshgrid(rq,cq);
handles.thickness_plot=griddata(r,c,v,rq,cq,'cubic');  %interpolate using nonzero entries for grid
%%display thickness
axes(handles.axes3);
surf(handles.thickness_plot,'LineStyle','none');
sizeim=size(handles.im);
axis([0 sizeim(1) 0 sizeim(2) 0 4000]);                 %set axis
rotate3d on                                             %allow rotation

% --- Executes on selection change in plot_current_fringe (Displays pixels
% in current fringe)
function plot_current_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to plot_current_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=handles.current_fringe_nr;
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);
% Hints: contents = cellstr(get(hObject,'String')) returns plot_current_fringe contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plot_current_fringe


% --- Executes during object creation, after setting all properties.
function plot_current_fringe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plot_current_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in add_fringe (create new fringe)
function add_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to add_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=length(handles.fringes)+1; %new length of fringe list and index of new fringe
handles.fringes{f}=Fringe;   %create fringe as struct from class Fringe
handles.fringes{f}.fringe=zeros(size(handles.fringe %initialize matrix to store current fringe pixels
%%update popup menu for fringe selection
handles.fringeselect{f}=sprintf('Fringe %d',f');
set(handles.current_fringe,'String',handles.fringeselect);
set(handles.current_fringe,'Value',f);
%enable color selection (no color selected yet)
set(handles.col_select,'Enable','on');
%set thickness value and color display to initial state
set(handles.text4,'String',sprintf('Fringe Thickness: select'));
axes(handles.axes4);
imshow(handles.initial_color);
%%save fringe index as currently selected fringe
handles.current_fringe_nr=f;
%%display current fringe points (i.e no points)
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);

guidata(hObject,handles);

% --- Executes on button press in clear_fringe (clears points in current
% fringe)
function clear_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to clear_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=handles.current_fringe_nr;
handles.fringe=handles.fringe-handles.fringes{f}.fringe; %delete current fringe points from the total of fringes
%%set current fringe to initial state
handles.fringes{f}=Fringe;    
handles.fringes{f}.fringe=zeros(size(handles.fringe));
%%display initial state of fringe
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);
%%allow color selection
set(handles.col_select,'Enable','on');

guidata(hObject,handles);

% --- Executes on selection change in current_fringe (change fringe
% currently selected)
function current_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to current_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=get(hObject,'Value');
handles.current_fringe_nr=f; %set current_fringe_nr to selected fringe
%%display plots of current fringe
axes(handles.axes4);
imshow(uint8(handles.fringes{f}.color));

set(handles.text4,'String',sprintf('Fringe Thickness: \n %d nm',handles.fringes{f}.thickness));
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);

guidata(hObject,handles);
% Hints: contents = cellstr(get(hObject,'String')) returns current_fringe contents as cell array
%        contents{get(hObject,'Value')} returns selected item from current_fringe


% --- Executes during object creation, after setting all properties.
function current_fringe_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- loads colormap and generates colormap image
function [cim,cm] = gen_cim()
colormap=load('colormap.mat');
cm=colormap.colormap;
%extend to 2nd dimension to create image
for i=1:70
cim(:,i,:)=cm;
end
%adjust contrast of image
lowin=min(cim(:));
lowout=max(cim(:));
cim=uint8(imadjust(cim,[lowin; lowout],[0; 1]).*256);
 
% --- converts image to L*a*b and adds coordinate information for 4th and
% 5th column
function im = add_coord(im)
       sizeim=size(im);
       im=rgb2lab(im);
       im(:,:,4:5)=zeros(sizeim(1),sizeim(2),2);
        for s=1:sizeim(1)
            for j=1:sizeim(2)
                im(s,j,4)=s;
                im(s,j,5)=j;
            end
        end      

% --- grow region around selected points in points
function [fringe_n,dispthickness_n]=cluster_fringe(handles,r,c,f)
%%handles = data in gui handles, r = row indices of selected pixels, c =
%%column indices of selected pixels, f = index of current fringe
%%ouput: fringe_n = binary mask of all selected points, disp_thickness =
%%matrix with selected thickness for all points in fringe_n
s=3;                                            %block size
sizeim=size(handles.imc);
fringe_n=handles.fringes{f}.fringe;             %grab current fringe
%%determine distance threshold and starting pixel for selected pixels
for i=1:length(r)
[dist_thresh(i),pos(i,:)] = dist_color([r(i),c(i)],s,handles.imc);
end
%%grow region for each point
for c=1:length(pos(:,1))
    current_search=[pos(c,1),pos(c,2)];                 %intialize current search from starting pixel
    ab=squeeze(handles.imc(pos(c,1),pos(c,2),2:3)).';   %get a*b values of starting pixel
    search=1;
%%search until current_search is empty
while search==1
    new_search=[];                                      %intialize array of pixels to search for in next step
    if ~isempty(current_search)
        for i=1:length(current_search(:,1))
        [this_search,fringe_n]=block_search(current_search(i,:),fringe_n,dist_thresh(c),ab,s,handles); %search within vicinity of pixel for more pixels within distance threshold of a*b of starting pixel
        new_search=[new_search;this_search];            %add pixels to new search
        end
    else
        search=0;
    end
    current_search=new_search;                          %make new search the current search for next loop
end
end
dispthickness_n=zeros(size(fringe_n));                    
dispthickness_n(fringe_n==1)=handles.fringes{f}.thickness; %set thickness for all selected pixels stored in fringe_n

% --- (to be used in cluster_fringe) find more suitable pixel to start region growing and determine
% distance threshold
function [dist,pos] = dist_color(pos,s,im)
%%pos = position of selected pixel, s = block radius, im=image with
%%added coordinates
block=im(pos(1)-s:pos(1)+s,pos(2)-s:pos(2)+s,:);       %extract block from image
col=reshape(block,[],5);                               %create column of all pixels
dist_all=squareform(pdist(col(:,2:3),'seuclidean'));   %generate matrix containing euclidean color distance of all pixels in block to all pixels
norm=sqrt(sum(dist_all.^2,2));                         %compute norm of all columns
[~,mid_pix]=min(norm);                                 %choose min of norm (i.e. column of pixel with the least distance to all other pixels)
%%compute threshold by choosing the distance to closest 20 pixels
dist_mid=sort(dist_all(mid_pix,:));
dist=1.6*mean(dist_mid(1:20));                         %factor by 1.6
%%get position of new start pixel
pos=squeeze(col(mid_pix,4:5));

% --- (to be used in cluster_fringe) find points within vicinity and color threshold of a pixel
function [this_search,fringe]=block_search(pos,fringe,dist_thresh,ab,s,handles)
   %%input: pos = position of search pixel as 1x2 matrix, dist_thresh = distance
   %%threshold for search, ab = reference color, s = block size, handles =
   %%gui handles
         this_search=[];
         block=handles.imc(pos(1)-s:pos(1)+s,pos(2)-s:pos(2)+s,:);          %get block around search pixel
         col=reshape(block,[],5);
         [ind,dist]=knnsearch(col(:,2:3),ab,'K',20,'Distance','seuclidean');%find color distance of the 20 closest pixels
         I=find(dist<dist_thresh);                                          %find pixels closer than threshold
         %%add pixels closer than threshold to this_search to be returned
         %%for further searches in their vicinity
         for x=2:length(I)
             r_ab=col(ind(I(x)),4);
             c_ab=col(ind(I(x)),5);
             %%only select pixels that have not been already selected and
             %%are not zero
             if fringe(r_ab,c_ab)==0&&handles.fringe(r_ab,c_ab)==0&&handles.imc(r_ab,c_ab,1)~=0 
                fringe(r_ab,c_ab)=1;
                this_search=[this_search;r_ab,c_ab];
             end
         end
   


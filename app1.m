


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
handles.im=imread('im_d/Sophie0131-1426-d-cr.tif');
sizeim=size(handles.im);
handles.fringes=cell(0);
handles.fringeselect=cell(0);
handles.fringe=zeros(sizeim(1),sizeim(2));
axes(handles.axes3);
imshow(handles.fringe);

handles.dispthickness=zeros(size(handles.fringe));
handles.imc=add_coord(handles.im);
axes(handles.axes1);
imshow(handles.im);
set(handles.col_select,'Enable','off');

handles.initial_color=zeros(100,100,3);
axes(handles.axes4);
imshow(handles.initial_color);

[handles.cim,handles.cm]=gen_cim();
axes(handles.axes2);
imshow(handles.cim);
cimlabel=ones(length(handles.cim(:,1,1))*10,2);
%[cim1,~]=gen_cim(1);
axes(handles.axes5);
imshow(cimlabel)
axis on;

% Choose default command line output for app1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes app1 wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = app1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in col_select.
function col_select_Callback(hObject, eventdata, handles)
% hObject    handle to col_select (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=handles.current_fringe_nr;
set(handles.text2,'String','pick color');
axes(handles.axes2);
[~,y,color]=impixel(handles.cim);
handles.fringes{f}.thickness=(y-1)*10;
imcolor=zeros(100,100,3);
for i=1:3;imcolor(:,:,i)=color(i);end
handles.fringes{f}.color=imcolor;
axes(handles.axes4);
imshow(uint8(handles.fringes{f}.color));
set(handles.text4,'String',sprintf('Fringe Thickness: \n %d nm',handles.fringes{f}.thickness));
guidata(hObject,handles);

% --- Executes on button press in points (select points for current fringe)
function points_Callback(hObject, eventdata, handles)
% hObject    handle to points (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try 
f=handles.current_fringe_nr;
axes(handles.axes1);
[c,r,~]=impixel(handles.im);
[handles.fringes{f}.fringe,handles.fringes{f}.dispthickness]=cluster_fringe(handles,r,c,f);
handles.fringe=handles.fringe+handles.fringes{f}.fringe;
handles.fringe(handles.fringe==2)=1;
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);
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


function plot_Callback(hObject, eventdata, handles)
% hObject    handle to plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.dispthickness=zeros(size(handles.fringe));
for i=1:length(handles.fringes)
   handles.dispthickness=handles.dispthickness+handles.fringes{i}.dispthickness; 
end
[r,c,v]=find(handles.dispthickness);
rq=1:1:length(handles.dispthickness(:,1));
cq=1:1:length(handles.dispthickness(1,:));
[rq,cq]=meshgrid(rq,cq);
handles.thickness_plot=griddata(r,c,v,rq,cq,'cubic');
axes(handles.axes3);
surf(handles.thickness_plot,'LineStyle','none');
sizeim=size(handles.im);
axis([0 sizeim(1) 0 sizeim(2) 0 4000]);
rotate3d on


function [cim,cm] = gen_cim(dummy)
    if nargin<1
colormap=load('colormap.mat');
cm=colormap.colormap;
for i=1:70
cim(:,i,:)=cm;
end
lowin=min(cim(:));
lowout=max(cim(:));
cim=uint8(imadjust(cim,[lowin; lowout],[0; 1]).*256);
    else
colormap=load('colormapfull.mat');
cm=colormap.colormap;
for i=1:2
cim(:,i,:)=cm;
end
lowin=min(cim(:));
lowout=max(cim(:));
cim=uint8(imadjust(cim,[lowin; lowout],[0; 1]).*256);
    end






function [dist,pos] = dist_color(pos,s,im)
        %% determine seucledian distance to nearest peak in color
        %% s = block radius
         block=im(pos(1)-s:pos(1)+s,pos(2)-s:pos(2)+s,:);
         ab=squeeze(im(pos(1),pos(2),2:3)).';
         col=reshape(block,[],5);
         dist_all=squareform(pdist(col(:,2:3),'seuclidean'));
         norm=sqrt(sum(dist_all.^2,2));
         [~,mid_pix]=min(norm);
         dist_mid=sort(dist_all(mid_pix,:));
         dist=1.6*mean(dist_mid(1:20));
         pos=squeeze(col(mid_pix,4:5));
%          [~,dist]=knnsearch(col(:,2:3),ab,'K',49,'Distance','seuclidean');
%          dist=1.17*median(dist);%1/2*(max(dist));%+mean(dist))/2;


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


function [fringe_n,dispthickness_n]=cluster_fringe(handles,r,c,f)
s=3;
sizeim=size(handles.imc);
fringe_n=handles.fringes{f}.fringe;
for i=1:length(r)
[dist_thresh(i),pos(i,:)] = dist_color([r(i),c(i)],s,handles.imc);
end

for c=1:length(pos(:,1))
    b=handles.imc(pos(c,1)-1:pos(c,1)+1,pos(c,2)-1:pos(c,2)+1,4:5);
    current_search=reshape(b,[],2);
    ab=squeeze(handles.imc(pos(c,1),pos(c,2),2:3)).';
    search=1;
while search==1
    new_search=[];
    if ~isempty(current_search)
        for i=1:length(current_search(:,1))
        [this_search,fringe_n]=block_search(current_search(i,:),fringe_n,dist_thresh(c),ab,s,handles);
        new_search=[new_search;this_search];
        end
    else
        search=0;
    end
    current_search=new_search;
end
end
dispthickness_n=handles.dispthickness;
dispthickness_n(fringe_n==1)=handles.fringes{f}.thickness;

    
   function [this_search,fringe]=block_search(pos,fringe,dist_thresh,ab,s,handles)
         this_search=[];
         block=handles.imc(pos(1)-s:pos(1)+s,pos(2)-s:pos(2)+s,:);
         col=reshape(block,[],5);
         [ind,dist]=knnsearch(col(:,2:3),ab,'K',20,'Distance','seuclidean');
         I=find(dist<dist_thresh);
         for x=2:length(I)
             r_ab=col(ind(I(x)),4);
             c_ab=col(ind(I(x)),5);
             if fringe(r_ab,c_ab)==0&&handles.fringe(r_ab,c_ab)==0&&handles.imc(r_ab,c_ab,1)~=0 
                fringe(r_ab,c_ab)=1;
                %fprintf('a and b of new pix: %d, %d \n',squeeze(im(r_ab,c_ab,2:3)).');
                this_search=[this_search;r_ab,c_ab];
             end
         end
   


% --- Executes on selection change in plot_current_fringe.
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


% --- Executes on button press in add_fringe.
function add_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to add_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=length(handles.fringes)+1;
handles.fringes{f}=Fringe;
handles.fringes{f}.fringe=zeros(size(handles.fringe));

handles.fringeselect{f}=sprintf('Fringe %d',f');
set(handles.current_fringe,'String',handles.fringeselect);
set(handles.current_fringe,'Value',f);

set(handles.col_select,'Enable','on');
set(handles.text4,'String',sprintf('Fringe Thickness: select'));

axes(handles.axes4);
imshow(handles.initial_color);

handles.current_fringe_nr=f;
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);

guidata(hObject,handles);



% --- Executes on button press in clear_fringe.
function clear_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to clear_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=handles.current_fringe_nr;
handles.fringe=handles.fringe-handles.fringes{f}.fringe;
handles.fringes{f}=Fringe;
handles.fringes{f}.fringe=zeros(size(handles.fringe));
axes(handles.axes3);
imshow(handles.fringes{f}.fringe);
set(handles.col_select,'Enable','on');

guidata(hObject,handles);



% --- Executes on selection change in current_fringe.
function current_fringe_Callback(hObject, eventdata, handles)
% hObject    handle to current_fringe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
f=get(hObject,'Value');
handles.current_fringe_nr=f;

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

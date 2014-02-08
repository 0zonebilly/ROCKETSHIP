function varargout = fitting_analysis(varargin)
% FITTING_ANALYSIS MATLAB code for fitting_analysis.fig
%      FITTING_ANALYSIS, by itself, creates a new FITTING_ANALYSIS or raises the existing
%      singleton*.
%
%      H = FITTING_ANALYSIS returns the handle to a new FITTING_ANALYSIS or the handle to
%      the existing singleton*.
%
%      FITTING_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FITTING_ANALYSIS.M with the given input arguments.
%
%      FITTING_ANALYSIS('Property','Value',...) creates a new FITTING_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before fitting_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to fitting_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help fitting_analysis

% Last Modified by GUIDE v2.5 03-Feb-2014 17:57:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fitting_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @fitting_analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~strcmp(varargin{1},'results_path')
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% TODO:
% Replace results_cfit_path
% make sure 1 item always selected


% --- Executes just before fitting_analysis is made visible.
function fitting_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to fitting_analysis (see VARARGIN)

% Choose default command line output for fitting_analysis
handles.output = hObject;

% Create structure to hold data
handles.roi_data_ready = 0;
handles.voxel_data_ready = 0;
handles.model_list = {};
handles.selected_model = 0;

% Get function inputs
if nargin>1 && numel(varargin)>1 && strcmp(varargin{1},'results_path')
    set(handles.results_cfit_path,'String',varargin{2});
    % Update cfit structures
    handles = cfit_path_changed(handles);
end

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes fitting_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = fitting_analysis_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


function results_cfit_path_Callback(hObject, eventdata, handles)
handles = cfit_path_changed(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function results_cfit_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_cfit_results.
function browse_cfit_results_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

[filename, pathname, filterindex] = uigetfile( ...
    {  '*.mat','Matlab Worksapce Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Choose Curve Fitting Results'); %#ok<NASGU>
if isequal(filename,0)
    %disp('User selected Cancel')
else
    %disp(['User selected ', fullfile(pathname, filename)])
    
    % Combine path and filename together
    fullpath = strcat(pathname,filename);

    set(handles.results_cfit_path,'String',fullpath);
end

% Update cfit structures
handles = cfit_path_changed(handles);

% Update handles structure
guidata(hObject, handles);


function background_image_path_Callback(hObject, eventdata, handles)
handles = load_check_data(handles);
% Update handles structure
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function background_image_path_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_image.
function browse_image_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

[filename, pathname, filterindex] = uigetfile( ...
    {  '*.nii','Nifti Files (*.nii)'; ...
    '*2dseq','Bruker Files (2dseq)'; ...
    '*.hdr;*.img','Analyze Files (*.hdr, *.img)';...
    '*.*',  'All Files (*.*)'}, ...
    'Choose Background Image file'); %#ok<NASGU>
if isequal(filename,0)
    %disp('User selected Cancel')
else
    %disp(['User selected ', fullfile(pathname, filename)])
    
    % Combine path and filename together
    fullpath = strcat(pathname,filename);

    set(handles.background_image_path,'String',fullpath);
end

handles = load_check_data(handles);

% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in button_run.
function button_run_Callback(hObject, eventdata, handles)
if handles.voxel_data_ready
    results_cfit_path = get(handles.results_cfit_path,'String');
    background_image_path = get(handles.background_image_path,'String');
    show_original = get(handles.show_original,'Value');
    show_ci = get(handles.show_ci,'Value');

    compare_fits(results_cfit_path,background_image_path,show_original,show_ci);
else
    handles = load_check_data(handles,'voxel');
    % Update handles structure
    guidata(hObject, handles);
end



% --- Executes on button press in show_original.
function show_original_Callback(hObject, eventdata, handles)


% --- Executes on button press in show_ci.
function show_ci_Callback(hObject, eventdata, handles)


% --- Executes on selection change in roi_listbox.
function roi_listbox_Callback(hObject, eventdata, handles)
if handles.roi_data_ready
    contents = cellstr(get(hObject,'String')); 
    selected_name = contents{get(hObject,'Value')};
    selected_roi_temp = strfind(handles.model_fit_data{handles.selected_model}.roi_name,selected_name);
    selected_roi = find(not(cellfun('isempty', selected_roi_temp)));
    handles.selected_model;
    handles.model_xdata{handles.selected_model}
    handles.model_fit_data{handles.selected_model}

    plot_data.Ct			= handles.model_xdata{handles.selected_model}.roi_series(:,selected_roi);
    plot_data.Ct_original	= handles.model_xdata{handles.selected_model}.roi_series_original(:,selected_roi);
    plot_data.Cp			= handles.model_xdata{handles.selected_model}.Cp;
    plot_data.timer			= handles.model_xdata{handles.selected_model}.timer;
    plot_data.x_units = 'Time (minutes)';
    plot_data.y_units =  'Concentration (mmol)';
    plot_data.fit_parameters= handles.model_fit_data{handles.selected_model}.roi_results(selected_roi,:);
    plot_data.model_name		= handles.model_fit_data{handles.selected_model}.model_name;
    plot_data.show_original = get(handles.show_original,'Value');
    plot_data.show_ci		= get(handles.show_ci,'Value');
    plot_data.title = ['ROI "' selected_name '"'];

    if strcmp(handles.model_fit_data{handles.selected_model}.model_name,'fxr')
        plot_data.R1o = handles.model_xdata{handles.selected_model}.roi_r1(selected_roi);
        plot_data.R1i = handles.model_xdata{handles.selected_model}.roi_r1(selected_roi);
        plot_data.r1 = handles.model_xdata{handles.selected_model}.relaxivity;
        plot_data.fw = 0.8;
    end

    figure(2);
    plot_dce_curve(plot_data);
else
    handles = load_check_data(handles,'roi');
    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes during object creation, after setting all properties.
function roi_listbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Should be run when path is changed to read in new file and update variables.
function return_handles = cfit_path_changed(handles)
handles = load_check_data(handles);

if handles.roi_data_ready
    set(handles.roi_listbox,'String',handles.model_fit_data{handles.selected_model}.roi_name, 'Value',1)
else
    set(handles.roi_listbox,'String','', 'Value',0)
end

% Update handles structure
return_handles = handles;



function return_handles = load_check_data(handles,verbose)
if nargin<2
    verbose = 'default';
end
% results_cfit_path = get(handles.results_cfit_path,'String');
background_image_path = get(handles.background_image_path,'String');
% lower_model_path = get(handles.lower_model_path,'String');
compare_model_list = handles.model_list;
handles.roi_data_ready = 0;
handles.voxel_data_ready = 0;
handles.ftest_ready = 0;
handles.akaike_ready = 0;
handles.fmi_ready = 0;
voxel_message = 'No results file selected';
roi_message = 'No results file selected';
ftest_message = 'No comparison results file selected';
akaike_message = 'No comparison results file selected';
fmi_message = 'No comparison results file selected';
selected_information = {};

for i=1:numel(compare_model_list)
    current_model = cell2mat(compare_model_list(i));
    [~, current_name, current_ext] = fileparts(current_model);
    
    % Load data and check if ready for voxel and ROI analysis
    try
        % Load
        temp_model = load(current_model); 
        handles.model_xdata{i} = temp_model.xdata{1};
        handles.model_fit_data{i} = temp_model.fit_data;

        % Display info about loaded file if it is the selected one
        ready_message = ['File loaded: ' current_name current_ext];   

        information_string = {['Fit Model: ' handles.model_fit_data{i}.model_name],...
            ['Fitted ROIs: ' num2str(handles.model_fit_data{i}.number_rois)],...
            ['Fitted Voxels: ' num2str(handles.model_xdata{i}.numvoxels*handles.model_fit_data{i}.fit_voxels)]}; 
        
        % Ready for some analysis
        handles.akaike_ready = 1;
        handles.fmi_ready = 1;
        akaike_message = ready_message;
        fmi_message = ready_message;
        
        % Check for f-test
        if numel(compare_model_list)~=2    
            handles.ftest_ready = 0;
            ftest_message = 'must select exactly two results to compare';
        end
        
        % Set messages for parametric analysis  
        if numel(compare_model_list)>1
            ftest_message = [num2str(i) ' comparisons models loaded'];
            akaike_message = [num2str(i) ' comparisons models loaded'];
            fmi_message = [num2str(i) ' comparisons models loaded'];
        end  
        
        
        % Check for ROI or voxel analysis, only for selected file
        if i==handles.selected_model
            selected_information = information_string;

            if handles.model_fit_data{i}.number_rois~=0
                handles.roi_data_ready = 1;
                roi_message = ready_message;
            else
                handles.roi_data_ready = 0;
                roi_message = 'No ROI results in file';
            end
            if handles.model_fit_data{i}.fit_voxels 
                if exist(background_image_path,'file')
                    handles.voxel_data_ready = 1;
                    voxel_message = ready_message;
                else
                    handles.voxel_data_ready = 0;
                    voxel_message = 'Selected background image does not exist';
                end
            else
                handles.voxel_data_ready = 0;
                voxel_message = 'No voxel results in file';
            end
        end

    catch err
        % If error not ready
        information_string = {};
        selected_information = {};
        handles.roi_data_ready = 0;
        handles.voxel_data_ready = 0;
        handles.ftest_ready = 0;
        handles.akaike_ready = 0;
        handles.fmi_ready = 0;
        % Set error message
        if ~exist(current_model,'file')
            ready_message = [current_name current_ext ' file not found'];
        elseif ~exist('xdata','var') || ~exist('fit_data','var')
            ready_message = [current_name current_ext ' file does not contain fit data'];
        elseif ~isfield(handles.model_fit_data{i},'fit_voxels') ||...
                ~isfield(handles.model_fit_data{i},'number_rois') ||...
                ~isfield(handles.model_fit_data{i},'model_name')
            ready_message = [current_name current_ext ' fit data is incomplete, rerun fit'];
        else
            rethrow(err);
        end
        voxel_message = ready_message;
        roi_message = ready_message;
        ftest_message = ready_message;
        akaike_message = ready_message;
        fmi_message = ready_message;
    end
end

% Display info messages
set(handles.cfit_information,'String',selected_information);

if strcmp(verbose,'default')
    if handles.voxel_data_ready || handles.roi_data_ready
        if handles.voxel_data_ready
            update_status(handles,voxel_message, 'black');
        elseif handles.roi_data_ready
            update_status(handles,roi_message, 'black');
        end
    else
        update_status(handles,voxel_message, 'red');
    end
elseif strcmp(verbose,'voxel')
    if handles.voxel_data_ready
        update_status(handles,voxel_message, 'black');
    else
        update_status(handles,voxel_message, 'red');
    end
elseif strcmp(verbose,'roi')
    if handles.roi_data_ready
        update_status(handles,roi_message, 'black');
    else
        update_status(handles,roi_message, 'red');
    end
elseif strcmp(verbose,'ftest')
    if handles.ftest_ready
        update_status(handles,ftest_message, 'black');
    else
        update_status(handles,ftest_message, 'red');
    end
elseif strcmp(verbose,'akaike')
    if handles.akaike_ready
        update_status(handles,akaike_message, 'black');
    else
        update_status(handles,akaike_message, 'red');
    end
elseif strcmp(verbose,'fmi')
    if handles.fmi_ready
        update_status(handles,fmi_message, 'black');
    else
        update_status(handles,fmi_message, 'red');
    end
end

% Update handles structure
return_handles = handles;



function lower_model_path_Callback(hObject, eventdata, handles)
% hObject    handle to lower_model_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lower_model_path as text
%        str2double(get(hObject,'String')) returns contents of lower_model_path as a double


% --- Executes during object creation, after setting all properties.
function lower_model_path_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lower_model_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in browse_lower_model.
function browse_lower_model_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

[filename, pathname, filterindex] = uigetfile( ...
    {  '*.mat','Matlab Worksapce Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Choose Fitting Results'); %#ok<NASGU>
if isequal(filename,0)
    %disp('User selected Cancel')
else
    %disp(['User selected ', fullfile(pathname, filename)])
    
    % Combine path and filename together
    fullpath = strcat(pathname,filename);

    set(handles.lower_model_path,'String',fullpath);
end

% Update structures
handles = load_check_data(handles);

% Update handles structure
guidata(hObject, handles);

% --- Executes on button press in button_ftest.
function button_ftest_Callback(hObject, eventdata, handles)
if ~handles.ftest_ready
    handles = load_check_data(handles,'ftest');
    % Update handles structure
    guidata(hObject, handles);
    return;
end
compare_voxels = (handles.model_fit_data{model_index}.fit_voxels && handles.model_fit_data{handles.selected_model}.fit_voxels);
compare_rois = (handles.model_fit_data{model_index}.number_rois>0 && handles.model_fit_data{handles.selected_model}.number_rois>0);
information_string = get(handles.cfit_information,'String');
information_string = information_string(1:3);
information_string(end+1) = {['Compare Model: ' handles.model_fit_data{model_index}.model_name]};
% Create custum strings
stat_name = 'p value';
path_suffix = '_ftest';
test_name_long = 'f-test';

higher_model = handles.selected_model
lower_model = 2-mod(higher_model+1,2);

if compare_voxels
    disp(['Starting ' test_name_long ' on voxels']);
    [sse_lower,fp_lower,n]=...
        get_sse_and_fp(handles,1,lower_model);
    [sse_higher,fp_higher,n_higher]=...
        get_sse_and_fp(handles,1,higher_model);
    
    % Sanity check
    if n~=n_higher
        update_status(handles,'models have different number of points','red');
        disp('stopping');
        return;
    end
    if fp_lower>=fp_higher
        update_status(handles,'lower model must be a lower number of free parameters','red');
        disp('stopping');
        return;
    end
    
    % Run Test
    number_voxels = numel(sse_higher);
    stat_voxels = 2.*ones(number_voxels,1);
    for i=1:number_voxels
        [ p, Fstat, df1, df2 ] = ftest(n,fp_lower,...
            fp_higher,sse_lower(i),sse_higher(i));
        stat_voxels(i) = p;
    end
    
    mean_stat = mean(stat_voxels);
    disp(['Average voxel ' stat_name ' = ' num2str(mean_stat)]);
    information_string(end+1) = {['Average voxel ' stat_name ' = ' num2str(mean_stat)]};
    
    % Save results
    [base_path, ~, ~] = fileparts(handles.model_list{1});
    [~, base_name, ~] = fileparts(handles.model_fit_data{higher_model}.dynam_name);
    save_path = fullfile(base_path,[base_name '_' ...
        handles.model_fit_data{higher_model}.model_name '_' ...
        handles.model_fit_data{lower_model}.model_name path_suffix '.nii']);
    
    stat_matrix     = zeros([256 256]);
    stat_matrix(handles.model_fit_data{higher_model}.tumind) = stat_voxels;
    save_nii(make_nii(stat_matrix, [1 1 1], [1 1 1]), save_path);
    disp(['Completed ' test_name_long ' on voxels']);
end
if compare_rois
    disp(['Starting ' test_name_long ' on ROIs']);
    [sse_lower,fp_lower,n]=...
        get_sse_and_fp(handles,2,lower_model);
    [sse_higher,fp_higher,n_higher]=...
        get_sse_and_fp(handles,2,higher_model);
    
    % Sanity check
    if n~=n_higher
        update_status(handles,'models have different number of points','red');
        disp('stopping');
        return;
    end
    if strcmp(test_name,'ftest') && fp_lower>=fp_higher
        update_status(handles,'lower model must be a lower number of free parameters','red');
        disp('stopping');
        return;
    end
    
    % Run Test
    number_rois = numel(sse_higher);
    stat_rois = 2.*ones(number_rois,1);
    f_rois = 2.*ones(number_rois,1);
    for i=1:number_rois
        [ p, Fstat, df1, df2 ] = ftest(n,fp_lower,...
            fp_higher,sse_lower(i),sse_higher(i));
        stat_rois(i) = p;
        f_rois(i) = Fstat;
    end
    mean_stat = mean(stat_rois);
    disp(['Average ROI ' stat_name ' = ' num2str(mean_stat)]);
    information_string(end+1) = {['Average ROI ' stat_name ' = ' num2str(mean_stat)]};
    
    % Save results
    [base_path, ~, ~] = fileparts(handles.model_list{1});
    [~, base_name, ~] = fileparts(handles.model_fit_data{higher_model}.dynam_name);
    save_path = fullfile(base_path,[base_name '_' ...
        handles.model_fit_data{higher_model}.model_name '_' ...
        handles.model_fit_data{lower_model}.model_name path_suffix '.xls']);
    
    headings = {'ROI', stat_name, ['Residual ' handles.model_fit_data{higher_model}.model_name],...
        ['Residual ' handles.model_fit_data{lower_model}.model_name]};
    xls_results = [handles.model_fit_data{higher_model}.roi_name num2cell(stat_rois) num2cell(sse_higher) num2cell(sse_lower)];
    xls_results = [headings; xls_results];
    
    xlswrite(save_path,xls_results);
    
    disp(['Completed ' test_name_long ' on ROIs']);
end

if ~compare_rois && ~compare_voxels
    update_status(handles,'cannot compare, same regions not fitted','red');
else
    information_string(end+1) = {['lower ' stat_name ' indicates higher order model is better fit']};
    set(handles.cfit_information,'String',information_string);
    disp(['lower ' stat_name ' indicates higher order model is better fit']);
end  
    
% --- Executes on button press in button_akaike.
function button_akaike_Callback(hObject, eventdata, handles)
run_comparison(hObject,handles,'akaike')

% --- Executes on button press in button_fmi.
function button_fmi_Callback(hObject, eventdata, handles)
run_comparison(hObject,handles,'fmi')

function run_comparison(hObject,handles,test_name)
if ~(handles.akaike_ready && strcmp(test_name,'akaike')) && ...
        ~(handles.fmi_ready && strcmp(test_name,'fmi'))
    handles = load_check_data(handles,test_name);
    % Update handles structure
    guidata(hObject, handles);
    return;
end
compare_voxels = 1;
compare_rois = 1;
number_models = numel(handles.model_fit_data);
for model_index=1:number_models
    % All models must have data to do comparison
    compare_voxels = (handles.model_fit_data{model_index}.fit_voxels && compare_voxels);
    compare_rois = (handles.model_fit_data{model_index}.number_rois>0 && compare_rois);
end
if ~compare_rois && ~compare_voxels
    update_status(handles,'cannot compare, same regions not fitted','red');
    return;
end
if compare_voxels
    number_voxels = numel( handles.model_fit_data{model_index}.fitting_results(:,4));
    stat_voxels = 2.*ones(number_voxels,number_models);
end
if compare_rois
    number_rois = numel(handles.model_fit_data{model_index}.roi_results(:,4));
    stat_rois = 2.*ones(number_rois,number_models);
    sse_rois = -1.*ones(number_rois,number_models);
end
for model_index=1:numel(handles.model_fit_data)
    information_string = get(handles.cfit_information,'String');
    information_string = information_string(1:3);
    information_string(end+1) = {['Compare Model: ' handles.model_fit_data{model_index}.model_name]};
    % Create custum strings
    if strcmp(test_name,'akaike')
        stat_name = 'relative likelihood';
        path_suffix = '_aic';
        test_name_long = 'Akaike information criteria';
    elseif strcmp(test_name,'fmi')
        stat_name = 'fraction modeled information';
        path_suffix = '_fmi';
        test_name_long = 'modeled and residual information';
    end
    
    if compare_voxels
        disp(['Starting ' test_name_long ' on voxels']);
        [sse_current,fp_current,n]=...
            get_sse_and_fp(handles,1,model_index);
        
        % Run Test
        number_voxels = numel(sse_current);
%         stat_voxels = 2.*ones(number_voxels,1);
        for i=1:number_voxels
            if strcmp(test_name,'akaike')
                aic_current = n*log(sse_current(i)/n)+2*fp_current;
                stat_voxels(i,model_index) = aic_current;
            elseif strcmp(test_name,'fmi')
                % Outlined in Balvay et al. MRM 54:868-877 (2005)
                M = n;%number of samples
                r = handles.model_fit_data{model_index}.voxel_residuals(i,:);
                d = handles.model_xdata{model_index}.Ct(:,i);
                for k=1:M/2
                    sum_r = 0;
                    sum_d = 0;
                    for j=1:M-k
                        sum_r = sum_r+r(j)*r(j+k);
                        sum_d = sum_d+d(j)*d(j+k);
                    end
                    Rrr(k) = 1/(M-abs(k))*sum_r;
                    Rdd(k) = 1/(M-abs(k))*sum_d;
                end
                Prr = fit((1:M/2)',Rrr','poly3'); %Fit Rrr with poly
                Pdd = fit((1:M/2)',Rdd','poly3'); %Fit Rdd with poly
                % Get value at zero
                Prr_0 = Prr(0);
                Pdd_0 = Pdd(0);
                
                e_ss_star = M*Prr_0; %ss indicates sum of squares
                d_0_ss_star = M*Pdd_0;
                FMI_star = 1-e_ss_star/d_0_ss_star;
                FRI_star = e_ss_star/sse_higher(i);
                stat_voxels(i,model_index) = FMI_star;
            end
        end
        
%         mean_stat = mean(stat_voxels(:,model_index));
%         disp(['Average voxel ' stat_name ' = ' num2str(mean_stat)]);
%         information_string(end+1) = {['Average voxel ' stat_name ' = ' num2str(mean_stat)]};
    end
    if compare_rois
        disp(['Starting ' test_name_long ' on ROIs']);
        [sse_current,fp_current,n]=...
            get_sse_and_fp(handles,2,model_index);
        sse_rois(:,model_index) = sse_current;
        
        % Run Test
        number_rois = numel(sse_current);
        for i=1:number_rois
            if strcmp(test_name,'akaike')
                aic_current = n*log(sse_current(i)/n)+2*fp_current;
                stat_rois(i,model_index) = aic_current;
            elseif strcmp(test_name,'fmi')
                % Outlined in Balvay et al. MRM 54:868-877 (2005)
                M = n;%number of samples
                r = handles.model_fit_data{model_index}.roi_residuals(i,:);
                d = handles.model_xdata{model_index}.Ct(:,i);
                for k=1:M/2
                    sum_r = 0;
                    sum_d = 0;
                    for j=1:M-k
                        sum_r = sum_r+r(j)*r(j+k);
                        sum_d = sum_d+d(j)*d(j+k);
                    end
                    Rrr(k) = 1/(M-abs(k))*sum_r;
                    Rdd(k) = 1/(M-abs(k))*sum_d;
                end
                Prr = fit((1:M/2)',Rrr','poly3'); %Fit Rrr with poly
                Pdd = fit((1:M/2)',Rdd','poly3'); %Fit Rdd with poly
                % Get value at zero
                Prr_0 = Prr(0);
                Pdd_0 = Pdd(0);
                
                e_ss_star = M*Prr_0; %ss indicates sum of squares
                d_0_ss_star = M*Pdd_0;
                FMI_star = 1-e_ss_star/d_0_ss_star;
                FRI_star = e_ss_star/sse_higher(i);
%                 figure(i);
%                 plot(Prr,(1:M/2)',Rrr');
                stat_rois(i,model_index) = FMI_star;
            end
        end
%         mean_stat = mean(stat_rois(:,model_index);
%         disp(['Average ROI ' stat_name ' = ' num2str(mean_stat)]);
%         information_string(end+1) = {['Average ROI ' stat_name ' = ' num2str(mean_stat)]};
    end 
end

% Compare results of different models
exhaustive_output = 1;
if strcmp(test_name,'akaike')
    if compare_voxels
        min_aic = zeros(number_voxels,1);
        relative_likelihood_main = zeros(number_voxels,1);
        if exhaustive_output
            relative_likelihood_extra = zeros(number_voxels,number_models);
        end
        for i=1:number_voxels
            [aic_sorted, sort_index] = sort(stat_voxels(i,:),'ascend');
            
            relative_likelihood_second = exp((aic_sorted(1)-aic_sorted(2))/2);
            min_name = handles.model_fit_data{sort_index(1)}.model_name;
            %second_name = handles.model_fit_data{sort_index(2)}.model_name;
            if strcmp(min_name,'aif')
                min_aic(i) = 1;
            elseif strcmp(min_name,'aif_vp')
                min_aic(i) = 2;
            elseif strcmp(min_name,'fxr')
                min_aic(i) = 3;
            end
            relative_likelihood_main(i) = relative_likelihood_second;
            
            if exhaustive_output
                for model_index=1:number_models
                    % difference from min value to model_index
                    relative_likelihood_n = exp((aic_sorted(1)-stat_voxels(i,model_index))/2);
                    relative_likelihood_extra(i,model_index) = relative_likelihood_n;
                end
            end
        end
        
        % Save voxel results
        [base_path, ~, ~] = fileparts(handles.model_list{1});
        [~, base_name, ~] = fileparts(handles.model_fit_data{1}.dynam_name);
        
        %min AIC
        save_path = fullfile(base_path,[base_name '_min_aic.nii']);
        image_matrix = zeros(handles.model_xdata{1}.dimensions)-1;
        image_matrix(handles.model_fit_data{1}.tumind) = min_aic;
        save_nii(make_nii(image_matrix, [1 1 1], [1 1 1]), save_path);

        %relative_likelihood_main
        save_path = fullfile(base_path,[base_name '_like_2nd.nii']);
        image_matrix     = zeros(handles.model_xdata{1}.dimensions)-1;
        image_matrix(handles.model_fit_data{1}.tumind) = relative_likelihood_main;
        save_nii(make_nii(image_matrix, [1 1 1], [1 1 1]), save_path);
        
        %relative_likelihood_n
        if exhaustive_output
            for model_index=1:number_models
                save_path = fullfile(base_path,[base_name '_like_' handles.model_fit_data{model_index}.model_name '.nii']);
                image_matrix = zeros(handles.model_xdata{1}.dimensions)-1;
                image_matrix(handles.model_fit_data{1}.tumind) = relative_likelihood_extra(:,model_index);
                save_nii(make_nii(image_matrix, [1 1 1], [1 1 1]), save_path);
            end
        end
        
        
        disp(['Completed ' test_name_long ' on voxels']);
    end
    if compare_rois
        min_aic_name = cell(number_rois,1);
        second_aic_name = cell(number_rois,1);
        relative_likelihood_main = zeros(number_rois,1);
        relative_likelihood_extra = zeros(number_rois,number_models);
        for i=1:number_rois
            [aic_sorted, sort_index] = sort(stat_rois(i,:),'ascend');
            
            relative_likelihood_second = exp((aic_sorted(1)-aic_sorted(2))/2);
            min_name = handles.model_fit_data{sort_index(1)}.model_name;
            second_name = handles.model_fit_data{sort_index(2)}.model_name;

            relative_likelihood_main(i) = relative_likelihood_second;
            min_aic_name{i} = min_name;
            second_aic_name{i} = second_name;
            
            
            for model_index=1:number_models
                % difference from min value to model_index
                relative_likelihood_n = exp((aic_sorted(1)-stat_rois(i,model_index))/2);
                relative_likelihood_extra(i,model_index) = relative_likelihood_n;
            end
            
        end
        
        % Save ROI results
        [base_path, ~, ~] = fileparts(handles.model_list{1});
        [~, base_name, ~] = fileparts(handles.model_fit_data{model_index}.dynam_name);
        save_path = fullfile(base_path,[base_name '_aic.xls']);
        
        name_list = [handles.model_fit_data{:}];
        temp_name = 'Relative Likelihood of ';
        heading_list_a = strcat(temp_name,{name_list.model_name});
        temp_name = 'Residual of ';
        heading_list_b = strcat(temp_name,{name_list.model_name});
        headings = {'ROI', 'Min AIC Model', 'Relative Likelihood of', 'Second Lowest AIC', heading_list_a{:}, heading_list_b{:}};
        xls_results = [handles.model_fit_data{1}.roi_name ...
            min_aic_name ...
            num2cell(relative_likelihood_main) ...
            second_aic_name ...
            num2cell(relative_likelihood_extra) ...
            num2cell(sse_rois)];
        xls_results = [headings; xls_results];
        
        xlswrite(save_path,xls_results);
        disp(['Completed ' test_name_long ' on ROIs']);
    end
end
if strcmp(test_name,'fmi')
    if compare_voxels
        
%         % Save voxel results
%         [base_path, ~, ~] = fileparts(handles.model_list{1});
%         [~, base_name, ~] = fileparts(handles.model_fit_data{model_index}.dynam_name);
%         save_path = fullfile(base_path,[base_name '_' ...
%         handles.model_fit_data{model_index}.model_name '_' ...
%         handles.model_fit_data{model_index}.model_name path_suffix '.nii']);
%         
%         image_matrix     = zeros([256 256]); %XXXX FIXME
%         image_matrix(handles.model_fit_data{model_index}.tumind) = stat_voxels(:,model_index);
%         save_nii(make_nii(image_matrix, [1 1 1], [1 1 1]), save_path);
%         disp(['Completed ' test_name_long ' on voxels']);
    end
    if compare_rois
        
%          % Save ROI results
%         [base_path, ~, ~] = fileparts(handles.model_list{1});
%         [~, base_name, ~] = fileparts(handles.model_fit_data{model_index}.dynam_name);
%         save_path = fullfile(base_path,[base_name '_' ...
%             handles.model_fit_data{model_index}.model_name '_' ...
%             handles.model_fit_data{model_index}.model_name path_suffix '.xls']);
%         
%         headings = {'ROI', stat_name, ['Residual ' handles.model_fit_data{model_index}.model_name]};
%         xls_results = [handles.model_fit_data{model_index}.roi_name num2cell(stat_rois(:,model_index)) num2cell(sse_current)];
%         xls_results = [headings; xls_results];
%         
%         xlswrite(save_path,xls_results);
%         disp(['Completed ' test_name_long ' on ROIs']);
    end
end


% information_string(end+1) = {['lower ' stat_name ' indicates higher order model is better fit']};
% set(handles.cfit_information,'String',information_string);
% disp(['lower ' stat_name ' indicates higher order model is better fit']);


    
function update_status(handles,status_string,color)
set(handles.ready_display,'String',status_string);
set(handles.ready_display, 'ForegroundColor', color);

function [sse, fp, n]=get_sse_and_fp(handles,region,model_index)
if region==1
    % Voxel results
    sse = handles.model_fit_data{model_index}.fitting_results(:,4);
elseif region==2
    % ROI results
    sse = handles.model_fit_data{model_index}.roi_results(:,4);
end

if strcmp(handles.model_fit_data{model_index}.model_name,'aif')
    fp = 2;
elseif strcmp(handles.model_fit_data{model_index}.model_name,'aif_vp')
    fp = 3;
elseif strcmp(handles.model_fit_data{model_index}.model_name,'fxr')
    fp = 3;
else
    update_status(handles,'selected model not implemented','red');
    return
end

n = numel(handles.model_xdata{model_index}.timer);



% --- Executes on selection change in model_box.
function model_box_Callback(hObject, eventdata, handles)
% contents = cellstr(get(hObject,'String'));        % returns model_box contents as cell array
% selected_model = contents{get(hObject,'Value')};  % returns selected item from model_box

handles.selected_model = get(hObject,'Value');
guidata(hObject, handles);
cfit_path_changed(handles)


% --- Executes during object creation, after setting all properties.
function model_box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to model_box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in add_models.
function add_models_Callback(hObject, eventdata, handles)
guidata(hObject, handles);

[filename, pathname, filterindex] = uigetfile( ...
    {  '*.mat','Matlab Worksapce Files (*.mat)'; ...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on'); %#ok<NASGU>
if isequal(filename,0)
    %disp('User selected Cancel')
else
    %disp(['User selected ', fullfile(pathname, filename)])
    list = get(handles.model_box,'String');
    
    % Combine path and filename together
    fullpath = strcat(pathname,filename);
    
    % Stupid matlab uses a different datastructure if only one file
    % is selected, handle special case
    if ischar(list)
        list = {list};
    end
    if ischar(filename)
        filename = {filename};
    end
    if ischar(fullpath)
        fullpath = {fullpath};
    end

    filename = filename';
    fullpath = fullpath';
        
    % Add selected files to listbox
    if strcmp(list,'No Files')
        list = filename;
        handles.model_list = fullpath;
    else
        list = [list;  filename];
        handles.model_list = [handles.model_list; fullpath];
    end 
    
    set(handles.model_box,'String',list, 'Value',1)
end
handles = cfit_path_changed(handles);
guidata(hObject, handles);


% --- Executes on button press in remove_models.
function remove_models_Callback(hObject, eventdata, handles)
index_selected = get(handles.model_box,'Value');
list = get(handles.model_box,'String');
for n=size(index_selected,2):-1:1
    % Remove from end of list first so resizing does not 
    % change subsequent index numbers
    %disp(['User removed ', list{index_selected(n)}]);
    list(index_selected(n)) = [];
    handles.model_list(index_selected(n)) = [];
end

set(handles.model_box,'String',list, 'Value',1)
guidata(hObject, handles);

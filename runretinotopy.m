
function runretinotopy(varargin)

ip = inputParser;
addParameter(ip, 'subnum', nan, @isnumeric);
addParameter(ip, 'runnum', nan, @isnumeric);
addParameter(ip,'expnum',93,@(x) ismember(x,89:94)); % (89=CCW, 90=CW, 91=expand, 92=contract, 93=multibar, 94=wedgeringmash)
addParameter(ip, 'fMRI', true, @islogical);
addParameter(ip, 'SkipSyncTests', 0, @(x) ismember(x,0:2));
addParameter(ip, 'tracker', 'none', @(x) sum(strcmp(x, {'T60', 'none'}))==1);
addParameter(ip, 'scan', false, @isnumeric); % used to id eyetracking data
parse(ip,varargin{:});
input = ip.Results;

%setup path
addpath(genpath('knkutils'))

%%%%%%%%%%%%%%%%%%%%%%%%%% EXPERIMENT PARAMETERS (edit as necessary)

% display
if input.fMRI
    refreshRate = 120; %will set as such to be sure; for BOLD screen, must be at 120
    fixationsize = 8;          % dot size in pixels
else
    refreshRate = 60; %will set as such to be sure
    fixationsize = 4;          % dot size in pixels
end

ptres = [1360 768 refreshRate 32];  % display resolution. [] means to use current display resolution.

% fixation dot
fixationinfo = {uint8([255 0 0; 0 0 0; 255 255 255]) 0.5};  % dot colors and alpha value
meanchange = 3;            % dot changes occur with this average interval (in seconds)
changeplusminus = 2;       % plus or minus this amount (in seconds)

% trigger
triggerkey = '5%';          % stimulus starts when this key is detected
tfun = @() fprintf('STIMULUS STARTED.\n');  % function to call once trigger is detected

% tweaking
offset = [0 0];            % [X Y] where X and Y are the horizontal and vertical
                           % offsets to apply.  for example, [5 -10] means shift 
                           % 5 pixels to right, shift 10 pixels up.
movieflip = [0 0];         % [A B] where A==1 means to flip vertical dimension
                           % and B==1 means to flip horizontal dimension

% directories
stimulusdir = [pwd,'/stims'];         % path to directory that contains the stimulus .mat files
savedir = [pwd,'/data'];
if ~exist(savedir)
    mkdir(savedir)
end

%%%%%%%%%%%%%%%%%%%%%%%%%% DO NOT EDIT BELOW

% set rand state
rand('state',sum(100*clock));
randn('state',sum(100*clock));

% prepare inputs
trialparams = [];
ptonparams = {ptres,[],0,input.SkipSyncTests};
dres = [];
grayval = uint8(127);
iscolor = 1;
frameduration = round(.0667*refreshRate); %4 or 8, for 60 or 120 hz
soafun = @() round(meanchange*15 + changeplusminus*(2*(rand-.5))*15);

% load specialoverlay
a1 = load(fullfile(stimulusdir,'fixationgrid.mat'));

% some prep
if ~exist('images','var')
  images = [];
  maskimages = [];
end

filename = sprintf('%s/subj%d_run%02d_exp%02d.mat',savedir,input.subnum,input.runnum,input.expnum);
%if file already exists, add a random time string
if exist(filename)
    filename = sprintf('%s/%s_subj%d_run%02d_exp%02d.mat',savedir,gettimestring,input.subnum,input.runnum,input.expnum);
end

% run experiment
[images,maskimages] = ...
  showmulticlass(filename,offset,movieflip,frameduration,fixationinfo,fixationsize,tfun, ...
                 ptonparams,soafun,0,images,input.expnum,[],grayval,iscolor,[],[],[],dres,triggerkey, ...
                 [],trialparams,[],maskimages,a1.specialoverlay,stimulusdir);
             
 save([filename(1:end-4),'_maskimages.mat'],'maskimages')           
             

%%%%%%%%%%%%%%%%%%%%%%%%%%

% KK notes:
% - remove performance check at end
% - remove resampling and viewingdistance stuff
% - remove hresgrid and vresgrid stuff
% - hardcode grid and pregenerate
% - trialparams became an internal constant

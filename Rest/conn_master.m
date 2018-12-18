function conn_generated()
% Batch setup file for CONN
%
% Laboratory for Neuroimaging of Coma and Consciousness (NICC)
%
% Created 11/14/2016
% Revised 2/5/17, 5/2/17, 5/21/17

clear all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %    
%       Key Script Parameters      %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TR=2.4; %Repetition time
[dirlist]=textread('SubjectList.txt','%s'); %text file with subject directories in whitespace-delimited strings
FUNCFILT='.*RSFMRI.*\.nii\.gz'; %Defines format of functional files in regexp, which will be used to select files
STRFILT='co.*\.nii\.gz'; %Defines format of structural files, again in regexp
NSUBJECTS=length(dirlist); %Number of subjects, automatically derived from length of file list

% Prepare batch structure 
clear batch;
batch.filename=fullfile(pwd,'conn_generated.mat'); % New conn_*.mat experiment name

% Parallelization
batch.parallel.N=11; %Set number of threads 
batch.parallel.profile=5; %Set parallelization to Background process (Unix/Mac) 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                  %    
%     CONN Setup Preprocessing     %
%                                  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%% BASIC
batch.Setup.isnew=1;
batch.Setup.nsubjects=NSUBJECTS;
batch.Setup.RT=TR;
batch.Setup.acquisitiontype=1; %assumes continuous acquisition of functional volumes
%batch.Setup.analyses=[1,2,3,4]; %default includes all analyses; see conn_batch.m for details
batch.Setup.analysisunits=1; %1=percent signal change (PSC), 2=raw units
batch.Setup.outputfiles=[1,1,1,1,1,1]; %outputs .nii volumes for confound-corrected timeseries, r-maps, z-maps, rex maps
batch.Setup.localcopy=1; %saves func and struct volumes to local conn_*/data/BIDS folder

%% STRUCTURAL AND FUNCTIONAL
% select functional and structural volumes according to prespecified format, in prespecified subjects
for i=1:NSUBJECTS
	rootdir=dirlist{i};
	batch.Setup.functionals{i}{1}=spm_select('FPListRec',[rootdir '/functional'],FUNCFILT);
	batch.Setup.structurals{i}=spm_select('FPListRec',[rootdir '/structural'],STRFILT);
end

%% PREPROCESSING
batch.Setup.preprocessing.steps='default_mni';
batch.Setup.preprocessing.sliceorder='interleaved (Siemens)';
batch.Setup.preprocessing.fwhm=6;

%% CONDITIONS
% specify conditions; for this analysis, the single condition 'rest' is specified for all subjects
batch.Setup.conditions.names={'rest'};
for i=1:NSUBJECTS
	batch.Setup.conditions.onsets{1}{i}{1}=[0];
	batch.Setup.conditions.durations{1}{i}{1}=[inf];
end

%% FIRST-LEVEL COVARIATES
% Nothing specified here, thus CONN will use default motion covariates from ART

%% SECOND-LEVEL COVARIATES
% Nothing specified here, may be added from covariates file as specified in conn batch instructions

% RUN!
batch.Setup.done=1;

%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        %    
%     CONN Denoising     %
%                        %
%%%%%%%%%%%%%%%%%%%%%%%%%%

batch.Denoising.filter=[0.008,0.09]; %Specify band-pass filter
batch.Denoising.done=1;

%%%%%%%%%%%%%%%%%%%%%%%%%
%                       %    
%     CONN Analysis     %
%                       %
%%%%%%%%%%%%%%%%%%%%%%%%%

% Define ROI-to-ROI and seed-to-voxel analyses
batch.Analysis.type=3;
batch.Analysis.done=1;

% Define voxel-to-voxel analyses (ARCHAICH as of v17d)
% batch.vvAnalysis.measures=['group-PCA','group-ICA','IntrinsicConnectivity'];
% batch.vvAnalysis.done=1;

conn_batch(batch);

%% The following launches the CONN gui and loads the .mat file to explore results
% conn
% conn('load',fullfile(pwd,'conn_generated.mat));
% conn gui_results

quit;

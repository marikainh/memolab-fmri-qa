function [b] = batch_spm_realign(b)
% BATCH_SPM_REALIGN Batching realignment with SPM
%
%   Author: Maureen Ritchey, July 2014
%   Intended for use with DML_batch_qa
%
%   Usage:
%
%	b = batch_spm_realign(b)
%   
%   input arguments:
%
%	b = memolab qa batch structure containing the fields:
%
%       b.dataDir     = fullpath string to the directory where the functional MRI data
%                       is being stored
%
%       b.runs        = cellstring with the name of the directories containing
%                       each functional run
%
%       b.auto_accept = a true/false variable denoting whether or not the 
%                       user wants to be prompted
%
%       b.rundir      = a 1 x n structure array, where n is the number of
%                       runs, with the fields:
%
%           b.rundir(n).files = a character array with the full paths to
%                               the .*\.nii functional images
%
%   output arguments:
%
%   b = memolab qa batch structure containg the new fields:
%
%       b.meanfunc         = full path string to the mean functional image created
%                            during realignment
%
%       b.rundir(n).rp     = full path string to the ^rp.*\.txt files where
%                            the movement parameters are stored. Note: n
%                            indexes run number
%
%       b.rundir(n).rfiles = a character array containg the full paths to
%                            the recently realigned and resliced ^r.*\.nii
%                            files. Note: n indexes run number
%
% See also: spm_realign, spm_reslice

% Check if realignment was already run and if so, whether it should be run
% again
runflag = 1;
if size(spm_select('FPList', fullfile(b.dataDir, b.runs{1}), '^rp'), 1) > 0 % check only for first run
    if b.auto_accept
        response = 'n';
    else
        response = input('Realignment was already run. Do you want to run it again? y/n \n','s');
    end
    if strcmp(response,'y')==1
        disp('Continuing running realignment')
    else
        disp('Skipping realignment')
        runflag = 0;
    end
end

% Run realignment: first func in each run to first func, then all funcs to
% first func in each run. N.B. Filenames must be organized into cell array
% in order to implement multiple session realignment.

% First re-organize files into cell array
b.allfiles = {};
for i = 1:length(b.runs)
    b.allfiles{i} = b.rundir(i).files; 
end

% Then run realignment
if runflag
    spm_realign(b.allfiles);
    spm_reslice(b.allfiles);
end

% Get file information for each run & store for future use
b.meanfunc = spm_select('FPList', fullfile(b.dataDir, b.runs{1}), '^mean.*\.nii'); % mean func is written only for first run
for i = 1:length(b.runs)
    tmp = spm_select('FPList', fullfile(b.dataDir, b.runs{i}), '^rp');
    b.rundir(i).rp = tmp(1,:);
    b.rundir(i).rfiles = spm_select('ExtFPList', fullfile(b.dataDir, b.runs{i}), '^r.*\.nii');
    fprintf('%0.0f: Realignment parameters file: %s\n', i, b.rundir(i).rp);
end

end % realign function

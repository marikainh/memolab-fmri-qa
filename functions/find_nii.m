function [b] = find_nii(b)
% FIND_NII finds nii files in the run directory and stores them in the 'b' 
%          structure.
%
%   Usage:
%
%	b = find_nii(b)
%   
%   input arguments:
%
%	b = memolab qa batch structure containing the fields:
%
%       b.runs      = cellstring with the name of the directories containing
%                     each functional run
%
%       b.dataDir   = fullpath string to the directory where the functional MRI data
%                     is being stored
%
%       b.rundir    = a 1 x n structure array, where n is the number of
%                     runs
%
%   output arguments:
%
%       b = memolab qa batch structure containg the new fields:
%
%       b.rundir(n).files = a character array containg the full paths to
%                           the recently converted .*\.nii files
%
%
%   Intended for use with Memolab QA Routine.
%   Written by Maureen Ritchey, circa 2014
%
%   See also: gunzip, spm_select

for irun = 1:length(b.runs)
    
    % Select this run's full nii timeseries
    rundir   = fullfile(b.dataDir, b.runs{irun});
    wildcard = [ '^' b.rawdataFP '.*\.nii'];
    b.rundir(irun).files = spm_select('ExtFPList', rundir, wildcard, Inf);
    
    % Check if files are found
    if size(b.rundir(irun).files, 1) > 0
        fprintf('In directory %s:\n%0.0f nii files found.\n', rundir, size(b.rundir(irun).files, 1));
    else
        % Check for gz file that matches prefix
        gzfiletest = dir([rundir filesep b.rawdataFP '*nii.gz']);
        if length(gzfiletest)==1
            fprintf('Did not find nii files. Unzipping gz file for SPM: %s\n',gzfiletest.name);
            gunzip([rundir filesep gzfiletest.name]);
            b.rundir(irun).files = spm_select('ExtFPList', rundir, wildcard, Inf);
        elseif length(gzfiletest)>1
            fprintf('Found more than one matching gz files and not sure what to do.\n');
        else
            error('No nii or matching gz files found.\n');
        end
    end

    
end

end

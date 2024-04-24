Original Version: v1.2.0.20220225

Updated by Raven | qiaokn123@163.com


- Added "-careg" flag to autorecon2 in t1_freesurfer.sh script to resolve "cannot find or read transforms/talairach.m3z" issue. Refer to: https://www.mail-archive.com/freesurfer@nmr.mgh.harvard.edu/msg74523.html

- Modified matlab/cat_defaults.m based on CAT12's cat_default.m for compatibility with vCAT12.8.2.
- Renamed matlab/cat_defaults.m to matlab/cat12_8_defaults.m to resolve "eval" error.

- Added bold_surf.sh script to map volumetric data to fsaverage5/6. 

- Updated bold_process.sh to incorporate two branches, one with and one without global signal regression (GSR), producing corresponding outputs for both.
  
- Renamed eddy_openmp to eddy_cpu in dwi_eddy.sh for FSL version 6.0.6
- Incorporated eddy_quad in dwi_eddy.sh to generate QC figures and metrics for eddy processing. 
    
- Added bold_highpass.sh to perform highpass filtering and MNI transformation for movie or task data.


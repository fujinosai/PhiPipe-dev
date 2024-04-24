Original Version: v1.2.0.20220225

Updated by Raven | qiaokn123@163.com






1. Add -careg to autorecon2 (t1_freesurfer.sh) to avoid "cannot find or read transforms/talairach.m3z" https://www.mail-archive.com/freesurfer@nmr.mgh.harvard.edu/msg74523.html 2023-08-01
2. Modify matlab/cat_defaults.m for CAT12.8  2023-08-24
3. Rename matlab/cat_defaults.m to matlab/cat12_8_defaults.m to avoid "eval" Error in matlab 2023-08-24
4. Modify eddy_openmp to eddy_cpu (dwi_eddy.sh) for FSL6.0.6 2023-08-08
5. Add eddy_quad (dwi_eddy.sh) to perform single subject QC. 2023-08-08
6 
6. Modify t1_stats.sh for output error 20231128
7. 


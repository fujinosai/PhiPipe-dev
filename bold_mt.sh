#! /bin/bash

## Author: Raven | qiaokn123@163.com | 20240125

## print script usage
Usage () {
    cat <<USAGE
-----------------------------------------------------------------------------------------
`basename $0` is the additional processing pipeline for naturalistic fMRI images
-----------------------------------------------------------------------------------------
Usage example:
bash $0 -a /home/alex/output/t1_proc
        -b t1
        -c /home/alex/output/bold_proc
        -d bold 
        -e 2 
        -f 0.01 
        -g 0.1
        -h 0
-----------------------------------------------------------------------------------------
Required arguments:
        -a:  T1 output directory (created by t1_process.sh)
        -b:  T1 output prefix (default: t1)
        -c:  BOLD output directory (created by bold_process.sh)
        -d:  BOLD output prefix (default: bold)
        -f:  high pass frequency (default: no high pass)
        
Optional arguments:
        -e:  repetition time (default: retrieve from input data header)
        -g:  low pass frequency  (default: no low pass)
        -h:  do global signal regression (default: 0, set 1 to turn on)
----------------------------------------------------------------------------------------
USAGE
    exit 1
}

if [[ $# -lt 6 ]]
then
    Usage >&2
    exit 1
else
        while getopts "a:b:c:d:e:f:g:h:" OPT
    do
      case $OPT in
          a) ## T1 output directory
             T1OUTDIR=$OPTARG
             ;;
          b) ## T1 output prefix
             T1PREFIX=$OPTARG
             ;;
          c) ## BOLD output directory
             BOLDOUTDIR=$OPTARG
             ;;
          d) ## BOLD output prefix
             BOLDPREFIX=$OPTARG
             ;;
          e) ## repetition time
             TR=$OPTARG
             ;;
          f) ## high pass frequency
             FBOT=$OPTARG
             ;;
          g) ## low pass frequency
             FTOP=${OPTARG}
             ;;
          h) ## global signal regression
             GSR=${OPTARG}
             ;;
          *) ## getopts issues an error message
             echo "ERROR:  unrecognized option -$OPT $OPTARG"
             exit 1
             ;;
      esac
    done
fi

segline() {
 local INFO=$1
 echo "--------------------------${INFO}-----------------------------"
}

## PhiPipe variable is set?
if [[ -z ${PhiPipe} ]]
then
    echo "please set the \$PhiPipe environment variable !!!"
    exit 1
fi

MNI3mm=${PhiPipe}/templates/MNI152/MNI152_T1_3mm_brain.nii.gz

## if INPUT files/folders exist?
bash ${PhiPipe}/check_inout.sh -b ${BOLDOUTDIR} -b ${T1OUTDIR}
if [[ $? -eq 1 ]]
then
    exit 1
fi

## custom output prefix?
if [[ -z ${T1PREFIX} ]]
then
    T1PREFIX=t1
fi
if [[ -z ${BOLDPREFIX} ]]
then
    BOLDPREFIX=bold
fi

BOLDLOGDIR=${BOLDOUTDIR}/log

segline "Movie addtional Processing:Step 1" | tee -a ${BOLDLOGDIR}/${BOLDPREFIX}_output.log >> ${BOLDLOGDIR}/${BOLDPREFIX}_cmd.log

if [[ ! -f ${BOLDOUTDIR}/mni/${BOLDPREFIX}_highpass_mni.nii.gz ]]
then
        if [[ -z ${FBOT} ]]
        then
            FBOT=0
        fi
        if [[ -z ${FTOP} ]]
        then
            FTOP=99999
        fi
        if [[ -z ${GSR} ]]
        then
            GSR=0
        fi

        BOLDIMAGE=${BOLDOUTDIR}/native/${BOLDPREFIX}_st.nii.gz
        
        if [[ -z ${TR} ]]
        then
                TR=$(3dinfo -tr ${BOLDIMAGE})
        fi
        (set -x
                bash ${PhiPipe}/bold_nuisance.sh -a ${BOLDIMAGE} \
                          -b ${BOLDOUTDIR}/native \
                          -c ${BOLDPREFIX}_highpass \
                          -d ${BOLDOUTDIR}/motion/${BOLDPREFIX}_mc.model \
                          -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_wm.mean \
                          -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_csf.mean \
                          -e ${BOLDOUTDIR}/motion/${BOLDPREFIX}_mc.censor  \
                          -f ${FBOT}  \
                          -g ${FTOP}  \
                          -h ${TR}  \
                          -i ${BOLDOUTDIR}/masks/${BOLDPREFIX}_brainmask.nii.gz

                bash ${PhiPipe}/bold_gms.sh -a ${BOLDOUTDIR}/native/${BOLDPREFIX}_highpass.nii.gz -b ${BOLDOUTDIR}/native -c ${BOLDPREFIX}_highpass_gms -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_brainmask.nii.gz 
		bash ${PhiPipe}/reg_apply.sh -a 3 \
                          -b ${BOLDOUTDIR}/native/${BOLDPREFIX}_highpass_gms.nii.gz \
                          -c ${BOLDOUTDIR}/mni/${BOLDPREFIX}_highpass_mni.nii.gz \
                          -d ${MNI3mm} \
                          -e ${T1OUTDIR}/reg/${T1PREFIX}2mni_warp.nii.gz \
                          -e ${T1OUTDIR}/reg/${T1PREFIX}2mni.mat \
                          -e ${BOLDOUTDIR}/reg/${BOLDPREFIX}2${T1PREFIX}.mat \
                          -f Linear
      
      if [[ ${GSR} -eq 1 ]]
      then
                bash ${PhiPipe}/bold_nuisance.sh -a ${BOLDIMAGE} \
                          -b ${BOLDOUTDIR}/native \
                          -c ${BOLDPREFIX}_highpass-gsr \
                          -d ${BOLDOUTDIR}/motion/${BOLDPREFIX}_mc.model \
                          -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_brain.mean \
                          -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_wm.mean \
                          -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_csf.mean \
                          -e ${BOLDOUTDIR}/motion/${BOLDPREFIX}_mc.censor  \
                          -f ${FBOT}  \
                          -g ${FTOP}  \
                          -h ${TR}  \
                          -i ${BOLDOUTDIR}/masks/${BOLDPREFIX}_brainmask.nii.gz

		bash ${PhiPipe}/bold_gms.sh -a ${BOLDOUTDIR}/native/${BOLDPREFIX}_highpass-gsr.nii.gz -b ${BOLDOUTDIR}/native -c ${BOLDPREFIX}_highpass_gms-gsr -d ${BOLDOUTDIR}/masks/${BOLDPREFIX}_brainmask.nii.gz
                bash ${PhiPipe}/reg_apply.sh -a 3 \
                          -b ${BOLDOUTDIR}/native/${BOLDPREFIX}_highpass-gsr.nii.gz \
                          -c ${BOLDOUTDIR}/mni/${BOLDPREFIX}_highpass_mni-gsr.nii.gz \
                          -d ${MNI3mm} \
                          -e ${T1OUTDIR}/reg/${T1PREFIX}2mni_warp.nii.gz \
                          -e ${T1OUTDIR}/reg/${T1PREFIX}2mni.mat \
                          -e ${BOLDOUTDIR}/reg/${BOLDPREFIX}2${T1PREFIX}.mat \
                          -f Linear 
        fi
         ) >> ${BOLDLOGDIR}/${BOLDPREFIX}_output.log 2>> ${BOLDLOGDIR}/${BOLDPREFIX}_cmd.log

        ## check the final status
        if [[ $? -eq 1 ]]
        then
            echo "Movie additional Processing:Step 1 Failed!"
            exit 1
        fi
fi 

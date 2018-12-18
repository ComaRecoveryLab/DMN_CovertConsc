#!/bin/bash
#
# Master launch script for CONN batch script processing
#
# Laboratory for NeuroImaging of Coma and Consciousness (NICC)
# 2018
#
mkdir ./generatedFiles
rsync conn_master.m ./generatedFiles/
rsync SubjectList.txt ./generatedFiles/
cd generatedFiles
matlab -nodesktop -r "run conn_master" > output.txt &

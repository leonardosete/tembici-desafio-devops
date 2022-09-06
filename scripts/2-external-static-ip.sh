#!/bin/sh

## The main goal of this script is: ##
## Creates a new Static External IP ##

## /vars ##
GREEN='\033[0;32m'
YEL='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color
## vars/ ##

### /FUNCTIONS ###
create_static_ext_ip(){
## /vars ##
REGION="us-central1"
ADDRESS_NAME_DEV="gke-lb-ext-tembici-dev"
ADDRESS_NAME_HLG="gke-lb-ext-tembici-hlg"
ADDRESS_NAME_PRD="gke-lb-ext-tembici-prd"
## vars/ ##

echo " "
echo "### ${RED}1-Creating a new static external IP${NC} ###"
echo "### ${RED}Reserving IPS${NC} ###"
echo " "
    gcloud compute addresses create $ADDRESS_NAME_DEV --global
    gcloud compute addresses create $ADDRESS_NAME_HLG --global
    gcloud compute addresses create $ADDRESS_NAME_PRD --global

echo " "
echo "### ${YEL}2-Listing your new IP ADDRESS${NC} ###"
    gcloud compute addresses list

echo " "
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo a mesma annotation: kubernetes.io/ingress.global-static-ip-name: ${RED}$ADDRESS_NAME_DEV${NC} ###"
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo a mesma annotation: kubernetes.io/ingress.global-static-ip-name: ${RED}$ADDRESS_NAME_HLG${NC} ###"
echo "### ${YEL}Lembre-se de verificar/configurar nos arquivos abaixo a mesma annotation: kubernetes.io/ingress.global-static-ip-name: ${RED}$ADDRESS_NAME_PRD${NC} ###"
echo "### ${YEL}Caminho dos arquivos${NC} ${GREEN}../k8s/devops-*.yaml${NC} ###"

}
### FUNCTIONS/ ###

### /RUN FUNCTIONS ###

### SCRIPT 1 ###
echo " "
echo "### ${YEL}List Static External IPs Created in the Current Project${NC} ###"
    gcloud compute addresses list
echo " "
echo "### ${RED}Creating 3 new Static External IP${NC} ###"
read -p "### Are you sure about the IP creation? (y/N)" answer
case ${answer:0:1} in
    y|Y )
        create_static_ext_ip
    ;;
    * )
        echo No
        exit
    ;;
esac

### END OF FUNCTIONS ###
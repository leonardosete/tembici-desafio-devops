#!/bin/sh

################
## ENV COLOR####
################
RED='\033[0;31m'
NC='\033[0m' # No Color

########################
## INTERACTIVE SCRIPT ##
########################

echo "### First things first! ###"
echo " "
echo "### You need to install the gcloud CLI: ###"
echo " "
echo "### ${RED}Click/open the link: https://cloud.google.com/sdk/docs/install${NC} ###"
echo " "
echo "### After installation, awswer ${RED}"y or Y"${NC} to proceed: ###"
echo " "
echo "### If you do not install gcloud CLI, this script will not run properly! ###"

########################
## INTERACTIVE SCRIPT ##
########################

read -p "Did install the gcloud CLI (y/n)? " answer
case ${answer:0:1} in
    y|Y )
        echo Yes
    ;;
    * )
        echo No
    ;;
esac

#########################
## DEFINE DYNAMIC ENVS ##
#########################

echo " "
echo "### Please, define some inputs variables about the GCP ###"
# echo " "
# echo "### Default: ${RED}tembici-desafio-devops-1${NC} ###"
# read -p "Your default PROJECT_ID is: " PROJECT_ID
echo " "
echo "### Your IAM User: ${RED}username@email.domain${NC} ###"
read -p "YOUR_GCP_ACCOUNT is: " YOUR_GCP_ACCOUNT
echo " "
echo "### The New Project: ${RED}New-Project-Name${NC} ###"
read -p "The NEW_PROJECT_ID to be created is: " NEW_PROJECT_ID

#################
## STATIC ENVS ##
#################

SVC_DESCRIPTION="Terraform Service Account" ## Service Account Description
LIST_ROLES=`cat ./roles-svc-account.md` ## A list of the needed roles to be added to the new Service Account
KEY_FILE="./svc-$NEW_PROJECT_ID-private-key.json" ## The key/json file to be created to the Service Account
SERVICE_ACCOUNT_ID="terraform-svc-account" ## The new Service Account to be created to run Terraform

######################
## GCLOUD EXECUTION ##
######################

############################
## Auth and Config gcloud ##
############################

    echo " "
    echo "### ${RED}1-Auth and Config gcloud${NC} ###"
    echo " "
    gcloud components update --quiet
    gcloud auth login --account $YOUR_GCP_ACCOUNT

########################
## Create New Project ##
########################

    echo " "
    echo "### ${RED}2-Create New Project${NC} ###"
    echo " "
    gcloud projects create $NEW_PROJECT_ID
    gcloud config set project $NEW_PROJECT_ID


############################
## Create Service Account ##
############################

    echo " "
    echo "### ${RED}3-Create Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts create $SERVICE_ACCOUNT_ID \
        --description="$SVC_DESCRIPTION" \
        --display-name="$SERVICE_ACCOUNT_ID"

###################################
## Create Key to Service Account ##
###################################

    echo " "
    echo "### ${RED}4-Create Key to Service Account${NC} ###"
    echo " "
    gcloud iam service-accounts keys create $KEY_FILE \
        --iam-account="$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com"

###################################
## Add roles in Service Account ##
###################################

    echo " "
    echo "### ${RED}5-Add roles in Service Account${NC} ###"
    echo " "

for ROLES in $LIST_ROLES
    do gcloud projects add-iam-policy-binding $NEW_PROJECT_ID --member="serviceAccount:$SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com" --role="roles/$ROLES"
done

###################################
## Check Service Account Details ##
###################################

    echo " "
    echo "### ${RED}6-Check Project and Service Account Details${NC} ###"
    echo " "
    gcloud iam service-accounts describe $SERVICE_ACCOUNT_ID@$NEW_PROJECT_ID.iam.gserviceaccount.com
    echo " "
    gcloud iam service-accounts list
    echo " "
    gcloud projects list
    echo " "
    echo "### ${RED}END-OF-SCRIPT${NC} ###"

##################
## LAST MESSAGE ##
##################
echo " "
echo "Ao término da execução do script, será gerado o arquivo ${RED}[svc-$NEW_PROJECT_ID-private-key.json]${NC}."
echo " "
echo "Esse arquivo será utilizado na etapa seguinte:"
echo "- Configurando Secrets no Repositório:"
echo "    * No github, na home do projeto/repositório que foi realizado o fork, clique na opção ${RED}[Settings]${NC} que fica ao lado de ${RED}[Insights]${NC};"
echo "    * Dentro das opções na coluna ${RED}[General]${NC}, navegue na sessão até chegar na opção ${RED}"Actions": ${RED}[Security]${NC} >> ${RED}[Secrets]${NC} >> ${RED}[Actions]${NC};"
echo "    * Clique em ${RED}[New Repository Secret]${NC} >> Crie um nome baseado na finalidade dessa secret:"
echo "        - Defina: ${RED}[GCP_TERRAFORM_SVC_ACCOUNT]${NC} ## Esse é o valor configurado nos arquivos de workflows."
echo "    * Em ${RED}[Value]${NC}, cole o conteúdo do arquivo ${RED}[svc-$NEW_PROJECT_ID-private-key.json]${NC} e clique em ${RED}[Add Secret]${NC}."

###################
## END OF SCRIPT ##
###################
#!/bin/bash

RG="Deencloudop-rg"
Location="EastUS"
AccountName="cloudopsstaticstorage"
ProfileName="static-cloudops-cdn"
EndPoint="cloudopsendpoints"
Hostname="dune.mmuyideen.xyz"

echo "-------------------------------------"
echo "|      Creating Resource Group      |"
echo "-------------------------------------"
az group create \
  --name $RG \
  --location $Location


echo "-------------------------------------"
echo "|  Creating Azure Storage Account   |"
echo "-------------------------------------"
az storage account create \
  --name $AccountName \
  --resource-group $RG \
  --location $Location \
  --sku Standard_LRS \
  --kind StorageV2


echo "-------------------------------------"
echo "|      Enabling Static-Website      |"
echo "-------------------------------------"
az storage blob service-properties update \
  --account-name $AccountName \
  --static-website \
  --index-document "index.html" \
  --404-document "error.html"


echo "-------------------------------------"
echo "|     Uploading Website Files       |"
echo "-------------------------------------"
Connection_String=$(az storage account show-connection-string --name $AccountName --resource-group $RG --query connectionString -o tsv)
az storage blob upload-batch \
  -d "\$web" \
  -s "./web" \
  --connection-string $Connection_String \
  --overwrite \
  --pattern "*"


echo "-------------------------------------"
echo "|        Creating CDN Profile       |"
echo "-------------------------------------"
az cdn profile create \
  --name $ProfileName \
  --resource-group $RG \
  --sku Standard_Microsoft



echo "-------------------------------------"
echo "|     Creating CDN End Point        |"
echo "-------------------------------------"
sleep 10

url=$(az storage account show --name $AccountName --resource-group $RG --query "primaryEndpoints.web" -o tsv | sed 's/^https:\/\/\([^/]*\)\/$/\1/')
az cdn endpoint create \
  --name $EndPoint \
  --profile-name $ProfileName \
  --resource-group $RG \
  --origin $url \
  --origin-host-header $url



echo "-------------------------------------"
echo "|     Creating Custom Domain        |"
echo "-------------------------------------"


az cdn custom-domain create \
  --resource-group $RG \
  --endpoint-name $EndPoint \
  --profile-name $ProfileName \
  --name "deenhost" \
  --hostname $Hostname


echo "-------------------------------------"
echo "| enable Https Custom Domain        |"
echo "-------------------------------------"


az cdn custom-domain enable-https \
  --resource-group $RG \
  --endpoint-name $EndPoint \
  --profile-name $ProfileName \
  --name "deenhost" \
  --min-tls-version 1.2

echo "------------------------------------------------------------------------------------------------------------------------------------------------"
echo "|     Wait for CDN to Configure Only few Mintues :) Your Setup is Almost Ready Here is Your website https://$Hostname       |"
echo "------------------------------------------------------------------------------------------------------------------------------------------------"
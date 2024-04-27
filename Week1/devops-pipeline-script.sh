#!/bin/bash

RG="Deencloudop-rg"
AccountName="cloudopsstaticstorage"
ProfileName="static-cloudops-cdn"
EndPoint="cloudopsendpoints"



echo "--------------------------------------------------------"
echo "|           Uploading to Azure Storage Account         |"
echo "--------------------------------------------------------"

Connection_String=$(az storage account show-connection-string --name $AccountName --resource-group $RG --query connectionString -o tsv)

echo "Current directory: $(pwd)"
ls -l

az storage blob upload-batch \
  -d "\$web" \
  -s "Week1/web" \
  --connection-string $Connection_String \
  --overwrite \
  --pattern "*"


echo "--------------------------------------------------------"
echo "|   Removing previous content from CDN edge locations  |"
echo "--------------------------------------------------------"

az cdn endpoint purge \
      --name $EndPoint \
      --profile-name $ProfileName \
      --resource-group $RG \
      --content-paths "/*"



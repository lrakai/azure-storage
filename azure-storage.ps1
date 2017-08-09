$Region = "WestUS2"
Login-AzureRmAccount
New-AzureRmResourceGroup -Name ca-labs -Location $Region
New-AzureRmResourceGroupDeployment -ResourceGroupName ca-labs -Name storage -TemplateFile .\infrastructure\arm-template.json
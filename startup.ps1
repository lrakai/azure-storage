$Region = "WestUS2"
Login-AzureRmAccount
New-AzureRmResourceGroup -Name azure-storage-lab -Location $Region
New-AzureRmResourceGroupDeployment -ResourceGroupName azure-storage-lab -Name storage-lab -TemplateFile .\infrastructure\arm-template.json
Get-AzureRmPublicIpAddress -Name lab-vm-ip -ResourceGroupName azure-storage-lab | Select -ExpandProperty IpAddress
### Storage account creation


# Install Azure PowerShell module from the gallery
Install-Module AzureRM

# Log your PowerShell session into Azure
Login-AzureRmAccount

# Get the VM disk storage account
Get-AzureRmStorageAccount

# Paste the contents of storage-account-template.json into a file on the VM called storage-account-template.json

# Deploy the storage account in the ARM template
New-AzureRmResourceGroupDeployment -ResourceGroupName azure-storage-lab -Name storage-deployment -TemplateFile .\storage-account-template.json

# See the new storage account has been created
Get-AzureRmStorageAccount

# Set the default storage account for what follows 
# (replace <NEW_STORAGE_ACCOUNT_NAME> with the storage account name given by the last command)
Set-AzureRmCurrentStorageAccount -ResourceGroupName azure-storage-lab -StorageAccountName <NEW_STORAGE_ACCOUNT_NAME>


### Blob storage


# Create a blob container with no public permission
New-AzureStorageContainer -Name images -Permission Off

# Upload a blob to the container
Set-AzureStorageBlobContent -Container images -File C:\Users\student\Desktop\image.png

# Get the blob
$blob = Get-AzureStorageBlob -Container images -Blob image.png

# Print the blob details
$blob

# Get the URI of the blob
$blob.ICloudBlob.StorageUri

# Generate a SAS token
New-AzureStorageBlobSASToken -CloudBlob $blob.ICloudBlob -Permission r

# Upload another image, but this time specify user-defined metadata to provide additional information about the image
$Metadata = @{ Type = "Wallpaper" }
Set-AzureStorageBlobContent -Container images -File C:\Windows\Web\Wallpaper\Theme1\img13.jpg -Metadata $Metadata

# Get a list of blobs in the container and filter out only those with Type set to Wallpaper
$Wallpaper = Get-AzureStorageBlob -Container images | Where-Object {$_.ICloudBlob.Metadata["Type"] -eq "Wallpaper"}
Get-AzureStorageBlobContent -CloudBlob $Wallpaper.ICloudBlob

# Observe only img13.jpg was downloaded (the wallpaper image)
dir

# Create a new container called Wallpapers with anonymous read and list permissions
New-AzureStorageContainer -Name wallpapers -Permission Container

# Copy the wallpaper blob from the images container to the wallpapers container
Start-AzureStorageBlobCopy -CloudBlob $Wallpaper.ICloudBlob -DestContainer wallpapers

# Check the status of the copy operation by entering:
Get-AzureStorageBlobCopyState -Blob $Wallpaper.Name -Container wallpapers

# Delete the wallpaper image in the images container:
Remove-AzureStorageBlob -CloudBlob $Wallpaper.ICloudBlob


### Table Storage


# Create a new Azure table called blobFiles
$TblName = "blobFiles"
New-AzureStorageTable -Name $TblName

# Get the table you just created and store it in a variable
$Tbl = Get-AzureStorageTable -Name $TblName

#Get the blob stored in the images containers
$Logo = Get-AzureStorageBlob -Container images

# Copy the contents of Lab-Functions.ps1 into a file on the VM

# Source the file to make your Add-Entity cmdlet available
. .\Lab-Functions.ps1

# Add an entity for each blob
Add-Entity -Table $Tbl -Blob $Logo -Type "logo"
Add-Entity -Table $Tbl -Blob $Wallpaper -Type "wallpaper"

# Execute a query to list all of the entities in the table
$Query = New-Object Microsoft.WindowsAzure.Storage.Table.TableQuery
$Tbl.CloudTable.ExecuteQuery($Query)

# Execute a query that finds all entities with a Type of wallpaper
$Query.FilterString = "Type eq 'wallpaper'"
$Entity = $Tbl.CloudTable.ExecuteQuery($Query)
$Entity

# Print the entity Type value
$Entity.Current.Item("Type")

# Specify to return only the StorageUri property and not the Type property
$Columns = New-Object System.Collections.Generic.List[string]
$Columns.Add("StorageUri")
$Query.SelectColumns = $Columns
$Entity = $Tbl.CloudTable.ExecuteQuery($Query)

# Attempt to print the Type of the entity
$Entity.Current.Item("Type")

# Verify that the StorageUri property is available
$Entity.Current.Item("StorageUri")


### Queue Storage


# Create a new queue named thumbnail-queue
$QueueName = "thumbnail-queue" 
$Queue = New-AzureStorageQueue –Name $QueueName

# Add a message to the queue for each blob
Add-Message -Queue $Queue -Blob $Logo
$Wallpaper = Get-AzureStorageBlob -Container wallpapers
Add-Message -Queue $Queue -Blob $Wallpaper

# Confirm that the queue has two messages
$Queue = Get-AzureStorageQueue -Name $QueueName
$Queue.ApproximateMessageCount

# In order to generate thumbnails, you need to download and import the Resize-Image module into PowerShell
Invoke-WebRequest -Uri https://gallery.technet.microsoft.com/scriptcenter/Resize-Image-A-PowerShell-3d26ef68/file/135684/1/Resize-Image.psm1 `
                  -OutFile .\Resize-Image.psm1
Import-Module .\Resize-Image.psm1 

# Create the thumbnails blob container with full read access:
New-AzureStorageContainer -Name thumbnails -Permission Container

# Call the function Process-Message cmdlet a few times:
Process-Message -Queue $Queue
Process-Message -Queue $Queue
Process-Message -Queue $Queue

# Get the URI of the thumbnails container
$thumbnails = Get-AzureStorageContainer -Name thumbnails
$thumbnails.CloudBlobContainer.StorageUri.PrimaryUri.AbsoluteUri


### Storage account keys


# List the two storage account access keys by entering:
Get-AzureRmStorageAccountKey -ResourceGroupName azure-storage-lab -Name <NEW_STORAGE_ACCOUNT_NAME>

# Regenerate key1 by entering
New-AzureRmStorageAccountKey -ResourceGroupName azure-storage-lab -Name <NEW_STORAGE_ACCOUNT_NAME> -KeyName key1

# Observe the change in key1:
Get-AzureRmStorageAccountKey -ResourceGroupName azure-storage-lab -Name <NEW_STORAGE_ACCOUNT_NAME>
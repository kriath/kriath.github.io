#Load SharePoint CSOM Assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
   
#Set parameter values
$SiteURL="https://mitchellshire.sharepoint.com"
$User= Read-Host 'Please enter user alias'
$UserAccount="$User@mitchellshire.vic.gov.au"
$ReportFile="C:\Scripts\Output\$User.PermissionRpt.csv"
$BatchSize = 500
  
#To call a non-generic method Load
Function Invoke-LoadMethod() {
    param(
            [Microsoft.SharePoint.Client.ClientObject]$Object = $(throw "Please provide a Client Object"),
            [string]$PropertyName
        ) 
   $ctx = $Object.Context
   $load = [Microsoft.SharePoint.Client.ClientContext].GetMethod("Load") 
   $type = $Object.GetType()
   $clientLoad = $load.MakeGenericMethod($type)
   
   $Parameter = [System.Linq.Expressions.Expression]::Parameter(($type), $type.Name)
   $Expression = [System.Linq.Expressions.Expression]::Lambda([System.Linq.Expressions.Expression]::Convert([System.Linq.Expressions.Expression]::PropertyOrField($Parameter,$PropertyName),[System.Object] ), $($Parameter))
   $ExpressionArray = [System.Array]::CreateInstance($Expression.GetType(), 1)
   $ExpressionArray.SetValue($Expression, 0)
   $clientLoad.Invoke($ctx,@($Object,$ExpressionArray))
}
  
#sharepoint online powershell to get user permissions Applied on a particular Object, such as: Web, List, Folder or Item
Function Get-Permissions([Microsoft.SharePoint.Client.SecurableObject]$Object)
{
    #Determine the type of the object
    Switch($Object.TypedObject.ToString())
    {
        "Microsoft.SharePoint.Client.Web"  { $ObjectType = "Site" ; $ObjectURL = $Object.URL }
        "Microsoft.SharePoint.Client.ListItem"
        { 
            $ObjectType = "List Item/Folder"
  
            #Get the URL of the List Item
            Invoke-LoadMethod -Object $Object.ParentList -PropertyName "DefaultDisplayFormUrl"
            $Ctx.ExecuteQuery()
            $DefaultDisplayFormUrl = $Object.ParentList.DefaultDisplayFormUrl
            $ObjectURL = $("{0}{1}?ID={2}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''), $DefaultDisplayFormUrl,$Object.ID)
        }
        Default
        { 
            $ObjectType = "List/Library"
            #Get the URL of the List or Library
            $Ctx.Load($Object.RootFolder)
            $Ctx.ExecuteQuery()            
            $ObjectURL = $("{0}{1}" -f $Ctx.Web.Url.Replace($Ctx.Web.ServerRelativeUrl,''), $Object.RootFolder.ServerRelativeUrl)
        }
    }
  
    #Get permissions assigned to the object
    $Ctx.Load($Object.RoleAssignments)
    $Ctx.ExecuteQuery()
  
    Foreach($RoleAssignment in $Object.RoleAssignments)
    { 
                $Ctx.Load($RoleAssignment.Member)
                $Ctx.executeQuery()
  
                #Check direct permissions
                if($RoleAssignment.Member.PrincipalType -eq "User")
                {
                    #Is the current user is the user we search for?
                    if($RoleAssignment.Member.LoginName -eq $SearchUser.LoginName)
                    {
                        Write-Host  -f Cyan "Found the User under direct permissions of the $($ObjectType) at $($ObjectURL)"
                          
                        #Get the Permissions assigned to user
                        $UserPermissions=@()
                        $Ctx.Load($RoleAssignment.RoleDefinitionBindings)
                        $Ctx.ExecuteQuery()
                        foreach ($RoleDefinition in $RoleAssignment.RoleDefinitionBindings)
                        {
                            $UserPermissions += $RoleDefinition.Name +";"
                        }
                        #Send the Data to Report file
                        "$($ObjectURL) `t $($ObjectType) `t $($Object.Title)`t Direct Permission `t $($UserPermissions)" | Out-File $ReportFile -Append
                    }
                }
                  
                Elseif($RoleAssignment.Member.PrincipalType -eq "SharePointGroup")
                {
                        #Search inside SharePoint Groups and check if the user is member of that group
                        $Group= $Web.SiteGroups.GetByName($RoleAssignment.Member.LoginName)
                        $GroupUsers=$Group.Users
                        $Ctx.Load($GroupUsers)
                        $Ctx.ExecuteQuery()
  
                        #Check if user is member of the group
                        Foreach($User in $GroupUsers)
                        {
                            #Check if the search users is member of the group
                            if($user.LoginName -eq $SearchUser.LoginName)
                            {
                                Write-Host -f Cyan "Found the User under Member of the Group '$($RoleAssignment.Member.LoginName)' on $($ObjectType) at $($ObjectURL)"
  
                                #Get the Group's Permissions on site
                                $GroupPermissions=@()
                                $Ctx.Load($RoleAssignment.RoleDefinitionBindings)
                                $Ctx.ExecuteQuery()
                                Foreach ($RoleDefinition  in $RoleAssignment.RoleDefinitionBindings)
                                {
                                    $GroupPermissions += $RoleDefinition.Name +";"
                                }          
                                #Send the Data to Report file
                                "$($ObjectURL) `t $($ObjectType) `t $($Object.Title)`t Member of '$($RoleAssignment.Member.LoginName)' Group `t $($GroupPermissions)" | Out-File $ReportFile -Append
                            }
                        }
                }
            }
}
 
Try {
    #Get Credentials to connect
    $Cred= Get-Credential
    $Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Cred.Username, $Cred.Password)
   
    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    $Ctx.Credentials = $Credentials
  
    #Get the Web
    $Web = $Ctx.Web
    $Ctx.Load($Web)
    $Ctx.ExecuteQuery()
  
    #Get the User object
    $SearchUser = $Web.EnsureUser($UserAccount)
    $Ctx.Load($SearchUser)
    $Ctx.ExecuteQuery()
  
    #Write CSV- TAB Separated File) Header
    "URL `t Object `t Title `t PermissionType `t Permissions" | out-file $ReportFile
  
    Write-host -f Yellow "Searching in the Site Collection Administrators Group..."
    #Check if Site Collection Admin
    If($SearchUser.IsSiteAdmin -eq $True)
    {
        Write-host -f Cyan "Found the User under Site Collection Administrators Group!"
        #Send the Data to report file
        "$($Web.URL) `t Site Collection `t $($Web.Title)`t Site Collection Administrator `t Site Collection Administrator" | Out-File $ReportFile -Append
    }
  
  
    #Function to Check Permissions of All List Items of a given List
    Function Check-SPOListItemsPermission([Microsoft.SharePoint.Client.List]$List)
    {
        Write-host -f Yellow "Searching in List Items of the List '$($List.Title)..."
  
        $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
        $Query.ViewXml = "<View Scope='RecursiveAll'><Query><OrderBy><FieldRef Name='ID' Ascending='TRUE'/></OrderBy></Query><RowLimit Paged='TRUE'>$BatchSize</RowLimit></View>"
 
        $Counter = 0
        #Batch process list items - to mitigate list threshold issue on larger lists
        Do {  
            #Get items from the list in Batch
            $ListItems = $List.GetItems($Query)
            $Ctx.Load($ListItems)
            $Ctx.ExecuteQuery()
           
            $Query.ListItemCollectionPosition = $ListItems.ListItemCollectionPosition
            #Loop through each List item
            ForEach($ListItem in $ListItems)
            {
                Invoke-LoadMethod -Object $ListItem -PropertyName "HasUniqueRoleAssignments"
                $Ctx.ExecuteQuery()
                if ($ListItem.HasUniqueRoleAssignments -eq $true)
                {
                    #Call the function to generate Permission report
                    Get-Permissions -Object $ListItem
                }
                $Counter++
                Write-Progress -PercentComplete ($Counter / ($List.ItemCount) * 100) -Activity "Processing Items $Counter of $($List.ItemCount)" -Status "Searching Unique Permissions in List Items of '$($List.Title)'"
            }
        } While ($Query.ListItemCollectionPosition -ne $null)
    }
  
    #Function to Check Permissions of all lists from the web
    Function Check-SPOListPermission([Microsoft.SharePoint.Client.Web]$Web)
    {
        #Get All Lists from the web
        $Lists = $Web.Lists
        $Ctx.Load($Lists)
        $Ctx.ExecuteQuery()
  
        #Get all lists from the web   
        ForEach($List in $Lists)
        {
            #Exclude System Lists
            If($List.Hidden -eq $False)
            {
                #Get List Items Permissions
                Check-SPOListItemsPermission $List
  
                #Get the Lists with Unique permission
                Invoke-LoadMethod -Object $List -PropertyName "HasUniqueRoleAssignments"
                $Ctx.ExecuteQuery()
  
                If( $List.HasUniqueRoleAssignments -eq $True)
                {
                    #Call the function to check permissions
                    Get-Permissions -Object $List
                }
            }
        }
    }
  
    #Function to Check Webs's Permissions from given URL
    Function Check-SPOWebPermission([Microsoft.SharePoint.Client.Web]$Web) 
    {
        #Get all immediate subsites of the site
        $Ctx.Load($web.Webs)  
        $Ctx.executeQuery()
   
        #Call the function to Get Lists of the web
        Write-host -f Yellow "Searching in the Web "$Web.URL"..."
  
        #Check if the Web has unique permissions
        Invoke-LoadMethod -Object $Web -PropertyName "HasUniqueRoleAssignments"
        $Ctx.ExecuteQuery()
  
        #Get the Web's Permissions
        If($web.HasUniqueRoleAssignments -eq $true) 
        { 
            Get-Permissions -Object $Web
        }
  
        #Scan Lists with Unique Permissions
        Write-host -f Yellow "Searching in the Lists and Libraries of "$Web.URL"..."
        Check-SPOListPermission($Web)
   
        #Iterate through each subsite in the current web
        Foreach ($Subweb in $web.Webs)
        {
                #Call the function recursively                            
                Check-SPOWebPermission($SubWeb)
        }
    }
  
    #Call the function with RootWeb to get site collection permissions
    Check-SPOWebPermission $Web
  
    Write-host -f Green "User Permission Report Generated Successfully!"
    }
Catch {
    write-host -f Red "Error Generating User Permission Report!" $_.Exception.Message
}

#Read more: https://www.sharepointdiary.com/2018/09/sharepoint-online-get-user-permission-report-using-powershell.html#ixzz79avez0OG

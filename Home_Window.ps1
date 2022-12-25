[System.Reflection.Assembly]::LoadWithPartialName("PresentationFramework") | Out-Null

##############################   HOME WINDOW   ##############################
function Import-Xaml {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\test3.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}
$Window = Import-Xaml 
$window.add_MouseLeftButtonDown({
    $window.DragMove()
})



########## HOME WINDOW CONTROLS ##########
$Button_Close = $Window.FindName('ButtonClose')
$Button_Minimize = $Window.FindName('ButtonMinimize')
$Button_Refresh = $Window.FindName('RefreshButton')
$TextBox_SystemInfo = $Window.FindName('TextBoxSystemInfo')
$TextBox_UserInfo = $Window.FindName('TextBoxUserInfo')



$Button_Close.add_Click({
$Window.Close()
})

$Button_Minimize.add_Click({
    $Window.WindowState = 'Minimized'
})


$Hostname = $env:COMPUTERNAME
$SerialNumber = (Get-WmiObject -class win32_bios).SerialNumber
$ModelNumber = (Get-WmiObject -Class:Win32_ComputerSystem).Model
$Manufacturer = (Get-WmiObject -Class Win32_BIOS).Manufacturer
$BIOSVersion = (Get-WmiObject -Class Win32_BIOS).SMBIOSBIOSVersion
$LastBootUPTime = (Get-WmiObject win32_operatingsystem | select @{LABEL='LastBootUpTime';EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}).LastBootUpTime 
$FreeSpaceSize = Get-CimInstance -ClassName win32_logicaldisk | where caption -eq "C:" | foreach-object { write " $('{0:N2}' -f ($_.FreeSpace/1gb)) GB" } 2> $null
    

$TextBox_SystemInfo.Text = "System Boot UP Time  :   $($LastBootUPTime)

Free Space in C-Drive  :   $($FreeSpaceSize)

Host Name                  :    $($Hostname)

Serial Number             :    $($SerialNumber)

Model Number            :    $($ModelNumber)

Manufacturer               :    $($Manufacturer)

BIOS Version                :    $($BIOSVersion)

Domain Name              :    $($env:USERDNSDOMAIN)"






Function Get-UserInfo {


    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True, Position = 1)]
        [string]$UserName
    )


    #Import AD Module
    Import-Module ActiveDirectory

    $Employee = Get-ADuser $UserName -Properties *, 'msDS-UserPasswordExpiryTimeComputed'
    $PasswordExpiry = [datetime]::FromFileTime($Employee.'msDS-UserPasswordExpiryTimeComputed')

      $AccountInfo = [PSCustomObject]@{
        Title        = $Employee.Title
        Department   = $Employee.department
        EmployeeID   = $Employee.EmployeeID
        DisplayNme   = $Employee.displayname
        EmailAddress = $Employee.emailaddress
        MobilePhone  = $Employee.mobilephone
    }

    $AccountStatus = [PSCustomObject]@{
        PasswordExpired       = $Employee.PasswordExpired
        LockOutTime           = $Employee.AccountLockoutTime
        AccountEnabled        = $Employee.Enabled
        AccountExpirationDate = $Employee.AccountExpirationDate
        PasswordExpireDate    = $PasswordExpiry
    }

    $AccountInfo

    $AccountStatus

} #END OF FUNCTION

$user = ((Get-WmiObject -ClassName Win32_ComputerSystem).Username).Split('\')[1]
#$user = "Pravinju"
$UserInfo = Get-UserInfo $user

$Accounts = Get-ADUser $user -Properties * 
$Manager  = ($Accounts | Select-Object @{Name='Manager';Expression={ (($_ |Get-ADUser -Properties manager).manager | Get-ADUser).Name}}).Manager
$ManagerName = (Get-ADUser $Manager -Properties * | Select-Object displayname).displayname

If ($UserInfo.AccountEnabled -eq $True) {$accountStatus = "Enabled"} else {$accountStatus = "Disabled"}
If ($UserInfo.AccountExpirationDate -eq $Null) {$AccointExpires = "Never Expires"} else {$AccointExpires = $UserInfo.AccountExpirationDate}
If ($UserInfo.PasswordExpired -eq $True) {$PasswordExpires = "Expired"} else {$PasswordExpires = $UserInfo.PasswordExpireDate}


$TextBox_UserInfo.Text = "Name            :   $($UserInfo.DisplayNme)
Title               :   $($UserInfo.Title)
Department   :  $($UserInfo.Department)
Reporting To    ` :   $($ManagerName)
Login ID         :   $($user)
Email              :   $($UserInfo.EmailAddress)
Emp. ID          :   $($UserInfo.EmployeeID)
Contact          :   $($UserInfo.MobilePhone)
Account         :   $($accountStatus )
Account Expires  : $($AccointExpires)
Password Expires :  $($PasswordExpires)"


$Button_Refresh.add_Click({
$Button_Refresh.Content = "Please Wait.."  

$Button_Refresh.Content = "Refresh" 
})







$Window.ShowDialog() | Out-Null

##############################   SOP WINDOW   ##############################


function Import-Xaml2 {
	[xml]$xaml = Get-Content -Path $PSScriptRoot\test.xaml
	$manager = New-Object System.Xml.XmlNamespaceManager -ArgumentList $xaml.NameTable
	$manager.AddNamespace("x", "http://schemas.microsoft.com/winfx/2006/xaml");
	$xamlReader = New-Object System.Xml.XmlNodeReader $xaml
	[Windows.Markup.XamlReader]::Load($xamlReader)
}
$Window2 = Import-Xaml2






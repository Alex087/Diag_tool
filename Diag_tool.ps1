#По для анализа ошибок и сбора информации. 
$global:OutputEncoding = New-Object Text.UnicodeEncoding $false, $false # Чтобы вывод корректно работал для кириллицы

Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$collect_info = "Сбор информации - это может занять несколько минут..."
$info_copied = "Собранная информация скопирована в буфер обмена."
$test_completed = "Сбор информации завершен"

$Form = New-Object system.Windows.Forms.Form
$Form.ClientSize = '563,230'
$Form.text = "Diagnostic tool"
$Form.TopMost = $false

$Label1 = New-Object system.Windows.Forms.Label
$Label1.text = "Утилита для диагностики и сбора информации"
$Label1.AutoSize = $false
$Label1.width = 467
$Label1.height = 20
$Label1.location = New-Object System.Drawing.Point(40, 29)
$Label1.Font = 'Microsoft Sans Serif,10'

$Test_results = New-Object system.Windows.Forms.TextBox
$Test_results.multiline = $true
$Test_results.BackColor = "#ffffff"
$Test_results.AutoSize = $false
$Test_results.width = 341
$Test_results.height = 107
$Test_results.location = New-Object System.Drawing.Point(121, 226)
$Test_results.Font = 'Microsoft Sans Serif,10'
$Test_results.Visible = $false

$Select_test = New-Object system.Windows.Forms.ComboBox
$Select_test.text = "Выберите тест из списка:"
$Select_test.width = 252
$Select_test.height = 20
$Select_test.location = New-Object System.Drawing.Point(40, 75)
$Select_test.Font = 'Microsoft Sans Serif,10'

$Button_run_test = New-Object system.Windows.Forms.Button
$Button_run_test.text = "Запустить тест"
$Button_run_test.width = 200
$Button_run_test.height = 30
$Button_run_test.location = New-Object System.Drawing.Point(320, 71)
$Button_run_test.Font = 'Times New Roman,12,style=Bold'

$Label2 = New-Object system.Windows.Forms.Label
$Label2.text = "..."
$Label2.AutoSize = $false
$Label2.width = 400
$Label2.height = 20
$Label2.location = New-Object System.Drawing.Point(40, 77)
$Label2.Font = 'Microsoft Sans Serif,10'
$Label2.Visible = $false

$Label_results = New-Object system.Windows.Forms.Label
$Label_results.text = "Test results"
$Label_results.AutoSize = $false
$Label_results.width = 303
$Label_results.height = 35
$Label_results.location = New-Object System.Drawing.Point(126, 173)
$Label_results.Font = 'Microsoft Sans Serif,10'
$Label_results.Visible = $false

$Button_copy_results = New-Object system.Windows.Forms.Button
$Button_copy_results.text = "Скопировать результаты"
$Button_copy_results.width = 200
$Button_copy_results.height = 30
$Button_copy_results.location = New-Object System.Drawing.Point(200, 135)
$Button_copy_results.Font = 'Times New Roman,12,style=Bold'
$Button_copy_results.Visible = $false

$Statusbar = New-Object system.Windows.Forms.Label
$Statusbar.text = ""
$Statusbar.AutoSize = $false
$Statusbar.width = 500
$Statusbar.height = 50
$Statusbar.location = New-Object System.Drawing.Point(8, 210)
$Statusbar.Font = 'Microsoft Sans Serif,10'


#Add test to list 
$Select_test.Items.Add("1. Сбор общей информации") | out-null
$Select_test.Items.Add("2. Почта: Тестирование веб-почты") | out-null
$Select_test.Items.Add("3. Почта: Тестирование Outlook") | out-null
$Select_test.Items.Add("4. Тестирование файловых сервисов") | out-null
$Select_test.Items.Add("5. Вывод маршрутов (route print)") | out-null
$Select_test.Items.Add("6. Диагностика KMS (need Admin rights)") | out-null
$Select_test.Items.Add("7. Диагностика лицензирования Office") | out-null

function info () {
    $Statusbar.Visible = $true
    #$Statusbar.text = "Тесты запущены..."
    $date = Get-Date
    #$comp_info = Get-ComputerInfo
    $os = (Get-WMIObject win32_operatingsystem)
    $os_name = $os.name.split("|")    
    $username = whoami
    "Computer name: " + "$env:computername" 
    "`n" + "Time and date: " + $date 
    "`n" + "Windows product name: " + $os_name[0] 
    "`n" + "Windows version: " + $os.version 
    "`n" + "Username: " + $username 
    ipconfig
}

function ipconfig () {
    $ipconfig = (gwmi Win32_NetworkAdapterConfiguration)
    foreach ($a in $ipconfig) { 
        if ($a.IPAddress) {
            "`n" + "IP Address: " + $a.IPAddress + "`n" + "Default gateway: " + $a.DefaultIPGateway + "`n" 
        } 
    }

}

function route_print () {
    #$route_print = Get-NetRoute -AddressFamily IPv4
    #"DestinationPrefix" + "   " + "NextHop" + "   " + "RouteMetric" + "`n"
    #$route_print | foreach { $_.DestinationPrefix.ToString() + "   " + $_.NextHop.ToString() + "   " + $_.RouteMetric.ToString() + "`n" } 
    #------
    $route_print = (gwmi win32_IP4RouteTable)
    "Destination" + "   " + "NextHop" + "   " + "Mask" + "   " + "Metric" 
    $route_print | foreach { "`n" + $_.Destination.ToString() + "   " + $_.NextHop.ToString() + "   " + $_.Mask.ToString() + "   " + $_.Metric1.ToString() } 
}

function ping_at () {
        
    try {
        $ping_at_ok = "Ping - OK"    
        $ping_at_ya_ru = test-connection ya.ru -erroraction Stop
        "`n" + $ping_ya_ok 
    }
    catch {
        $_
        
    }

}

function ping_kms () {
        
    try {
        $ping_at_ok = "Ping ya.ru - OK"    
        $ping_at_ya_ru = test-connection ya.ru -erroraction Stop
        "`n" + $ping_ya_ok + "`n"
        
        
    }
    catch {
        $_
        $tracert = tracert ya.ru
        $tracert | foreach { "`n" + $_ + "`n" }
    }

}

function Test-Port($server, $port, $client) {
    $client = New-Object Net.Sockets.TcpClient
    try {
        $client.Connect($server, $port)
        $true
    }
    catch {
        $false
    }
    finally {
        $client.Dispose()
    }
}

function test_ipsec() {
    try {
        $os = (Get-WMIObject win32_operatingsystem)
        if ($os.name -notlike "*Windows 7*") {
            $firewall_status = Get-NetFirewallProfile
            $firewall_status | foreach { "`n" + "Firewall profile name " + $_.Name + " is " + $_.Enabled }        
            $client = New-Object Net.Sockets.TcpClient
            $server = "ya.ru"
            $port = 445
            try {
                $client.Connect($server, $port)
                "`n" + "`n" + "Test IPSec port (445): " + $true 
            }
            catch {
                "`n" + "Test IPSec port (445): " + $false 
            }
                
            

            $client1 = New-Object Net.Sockets.TcpClient
            $server = "ya.ru"
            $port = 1688
            try {
                $client1.Connect($server, $port)
                "`n" + "Test IPSec port (1688): " + $true 
            }
            catch {
                "`n" + "Test IPSec port (1688): " + $false 
            }
            
            $ipsecrules = Get-NetIPsecRule -PolicyStore ActiveStore -erroraction Stop
            $ipsecrule_kms = $ipsecrules | where DisplayName -eq "KMS"
            "`n" + "`n" + "IPSec Rule KMS is: " + $ipsecrule_kms.Enabled + "`n"

        }
        else {
            
            $client = New-Object Net.Sockets.TcpClient
            $server = "ya.ru"
            $port = 445
            try {
                $client.Connect($server, $port)
                "`n" + "Test IPSec port (445): " + $true 
            }
            catch {
                "`n" + "Test IPSec port (445): " + $false 
            }
                
            

            $client1 = New-Object Net.Sockets.TcpClient
            $server = "ya.ru"
            $port = 1688
            try {
                $client1.Connect($server, $port)
                "`n" + "Test IPSec port (1688): " + $true
            }
            catch {
                "`n" + "Test IPSec port (1688): " + $false
            }
                
        }
    }
    catch {
        $_
    }
}

function test_activation {
    "`n" + "`n" + "About current activation OS: "
    $test_activation = cscript C:\Windows\System32\slmgr.vbs /dli
    $test_activation | foreach { "`n" + $_ }
}

function test_activation_office {
    "`n" + "`n" + "About current licenses Office: "
    $test_activation = cscript C:\Windows\System32\slmgr.vbs /dli
    $test_activation | foreach { "`n" + $_ }
}
function test_web_mail () {
    $username = whoami
    info
    ping_at
    $ping_mail_ok = "Ping ya.ru - OK"
    test_sts
    $Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri -Authentication Kerberos -ErrorAction Stop
    $pssession = Import-PSSession $Session -CommandName get-mailbox

    try {
        $ping_mail_ya_ru = test-connection mail.ya.ru -erroraction Stop
        "`n" + $ping_mail_ok 
        $get_mailbox = get-mailbox -identity $username -erroraction Stop
        "`n" + "Mailbox enabled: " + $get_mailbox.IsMailboxEnabled 
        "`n" + "RecipientLimits: " + $get_mailbox.RecipientLimits 
        "`n" + "ThrottlingPolicy: " + $get_mailbox.ThrottlingPolicy 
    } 
    catch {
        $_
    }
    Remove-PSSession $Session   
}

function test_outlook () {
    info
    ping_at
    $ping_mail_ok = "Ping mail.ya.ru - OK"
    try {
        $outlook_versions = gwmi win32_product -filter "name like '%office%'"
    }
    catch {
        $_
    }
    try {
        $ping_mail_ya_ru = test-connection mail.ya.ru -erroraction Stop
        "`n" + $ping_mail_ok  
            
    } 
    catch {
        $_
    }
    "`n"
    "`n" + "Outlook version: " 
    "`n"
    foreach ($outlook_version in $outlook_versions) { $outlook_version.name + "`n" }
    "`n"
    "`n" + "Outlook log: "
    "`n"
    $outlook_log = Get-EventLog -logname application -Source outlook -Newest 100 | where { $_.EntryType -eq "Warning" -or $_.EntryType -eq "Error" }
    $outlook_log | foreach {
        # $_.TimeGenerated.day.ToString() + "-" + $_.TimeGenerated.Month.ToString() + "-" + $_.TimeGenerated.Year.ToString() + " - " + $_.EntryType + " - " + $_.message + "`n" 
        $_.TimeGenerated.ToString() + " - " + $_.EntryType + " - " + $_.message + "`n" 
    }
    
}

function test_sts () {
    try {
        $test_sts_ok = "Test sts.ya.ru - OK"
        $check_sts = Invoke-WebRequest -Uri "mail.ya.ru" -erroraction Stop 
        $check_sts_logo = $check_sts.parsedhtml.images[0].className
        if ($check_sts_logo -like "logoImage") {
            "`n" + $test_sts_ok 

        }
        else {
            "Error get logo sts"
        }
    }
    catch {
        $_
    }
}


function test_file_shares() {
    info
    $path_temp = "\\zz.ya.ru\temp"
    $path_dep = "\\zz.ya.ru\dep"
    $test_path_temp = test-path $path_temp
    $test_path_dep = test-path $path_dep
    $test_path_m = test-path "m:"
    "`n" + "Connect to temp dir: " + $test_path_temp 
    "`n" + "Connect to dep dir: " + $test_path_dep 
    "`n" + "Connect to home dir (m:): " + $test_path_m 

}

function test_kms() {
    info
    ping_at
    ping_kms
    test_ipsec
    test_activation
}

function test_lic_office() {
    info
    ping_at
    ping_kms
    test_ipsec
    
    $office2010_x86_path = "C:\Program Files\Microsoft Office\Office14\OSPP.VBS"
    $test_path_o2010_x86 = test-path $office2010_x86_path
    $office2010_x64_path = "C:\Program Files (x86)\Microsoft Office\Office14\OSPP.VBS"
    $test_path_o2010_x64 = test-path $office2010_x64_path
    $office2013_x86_path = "C:\Program Files\Microsoft Office\Office15\OSPP.VBS"
    $test_path_o2013_x86 = test-path $office2013_x86_path
    $office2013_x64_path = "C:\Program Files (x86)\Microsoft Office\Office15\OSPP.VBS"
    $test_path_o2013_x64 = test-path $office2013_x64_path
    $office2016_x86_path = "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS"
    $test_path_o2016_x86 = test-path $office2016_x86_path
    $office2016_x64_path = "C:\Program Files\Microsoft Office\Office16\OSPP.VBS"
    $test_path_o2016_x64 = test-path $office2016_x64_path
    $office2019_x86_path = "C:\Program Files (x86)\Microsoft Office\Office16\OSPP.VBS"
    $test_path_o2019_x86 = test-path $office2019_x86_path
    $office2019_x64_path = "C:\Program Files\Microsoft Office\Office16\OSPP.VBS"
    $test_path_o2019_x64 = test-path $office2019_x64_path
    "`n" + "`n" + "About Office activation: "  
    if ($test_path_o2019_x64) {
        $o2019x64 = cscript $office2019_x64_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }
        $test_path_o2016_x64 = $false
    }

    if ($test_path_o2019_x86) {
        $o2019x64 = cscript $office2019_x86_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }
        $test_path_o2016_x86 = $false
    }

    if ($test_path_o2016_x64) {
        $o2019x64 = cscript $office2016_x64_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }

    }

    if ($test_path_o2016_x86) {
        $o2019x64 = cscript $office2016_x86_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }

    }

    if ($test_path_o2013_x64) {
        $o2019x64 = cscript $office2013_x64_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }

    }

    if ($test_path_o2013_x86) {
        $o2019x64 = cscript $office2013_x86_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }

    }

    if ($test_path_o2010_x64) {
        $o2019x64 = cscript $office2010_x64_path /dstatus       
        $o2019x64 | foreach { "`n" + $_ }

    }

    if ($test_path_o2010_x86) {
        $o2019x64 = cscript $office2010_x86_path /dstatus
        $o2019x64 | foreach { "`n" + $_ }

    }

}

#Обработка кнопок
$Button_run_test.Add_Click( {
        switch ($Select_test.selectedItem) {
            "1. Сбор общей информации" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = info
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
           
            "2. Почта: Тестирование веб-почты" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = test_web_mail
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            "3. Почта: Тестирование Outlook" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = test_outlook
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            "4. Тестирование файловых сервисов" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = test_file_shares
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            "5. Вывод маршрутов (route print)" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = route_print
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            "6. Диагностика KMS (need Admin rights)" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = test_kms
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            "7. Диагностика лицензирования Office" {
                $Button_copy_results.Visible = $false
                $Statusbar.Visible = $true
                $Statusbar.text = $collect_info
                $Test_results.Text = test_lic_office
                #$Statusbar.Visible = $false
                $Statusbar.text = $test_completed
                $Button_copy_results.Visible = $true
                
                break
            }
            
        }
        
    })

$Button_copy_results.Add_Click( {
        $Statusbar.Visible = $false
        $Test_results.Text.Trim() | clip
        $Statusbar.Visible = $true
        $Statusbar.text = $info_copied
        #Start-Sleep -Seconds 2
        #$Statusbar.Visible = $false
    })

$Form.controls.AddRange(@($Test_results, $Select_test, $Button_run_test, $Label1, $Label_results, $Button_copy_results, $Statusbar))

#Show form
[void]$Form.ShowDialog()

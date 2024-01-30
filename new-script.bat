@echo off
@echo Script criado por Renan Portes.
@echo Contato (44) 98827.9740
@echo Ultima Atualizacao 30/01/2024
pause

@echo off
REM Copiando arquivos
copy "c:\_install\_files\logo-win.bmp" "C:\Windows\"

REM Turn Core Isolation Memory Integrity OFF
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" /v "Enabled" /t REG_DWORD /d 0 /f

REM Disable Windows Updates Driver Downloads
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\default\Update\ExcludeWUDriversInQualityUpdate" /v "value" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsUpdate\UX\Settings" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" /v "ExcludeWUDriversInQualityUpdate" /t REG_DWORD /d 1 /f

REM Disable Background Apps in Windows 11
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v "GlobalUserDisabled" /t REG_DWORD /d 1 /f

REM Windows 10 Context Menu For Windows 11
reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}" /ve /d "" /f
reg add "HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32" /ve /d "" /f

REM Widgets - Disable
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh" /v "AllowNewsAndInterests" /t REG_DWORD /d 0 /f

REM Disable Hibernate
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power" /v "HibernateEnabled" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FlyoutMenuSettings" /v "ShowHibernateOption" /t REG_DWORD /d 0 /f

REM My PC / User on Desktop
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" /t REG_DWORD /d 0 /f
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{59031a47-3f72-44a7-89c5-5595fe6b30ee}" /t REG_DWORD /d 0 /f

REM OEM Info
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Manufacturer" /t REG_SZ /d "INGATECH" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportPhone" /t REG_SZ /d "(44) 98827-9740" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "Logo" /t REG_SZ /d "c:\windows\logo-win.bmp" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation" /v "SupportURL" /t REG_SZ /d "https://wa.me/5544988279740" /f

REM Allow scripts in CMD set-executionpolicy remotesigned
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "Path" /t REG_SZ /d "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" /f
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PowerShell\1\ShellIds\Microsoft.PowerShell" /v "ExecutionPolicy" /t REG_SZ /d "RemoteSigned" /f

REM Unpin Store from Taskbar
reg add "HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer" /v "NoPinningStoreToTaskbar" /t REG_DWORD /d 1 /f

REM Remove search from taskbar
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search" /v "SearchboxTaskbarMode" /t REG_DWORD /d 1 /f

REM Remove meet now
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v "HideSCAMeetNow" /t REG_DWORD /d 1 /f

REM Remove action center
reg add "HKEY_CURRENT_USER\SOFTWARE\Policies\Microsoft\Windows\Explorer" /v "DisableNotificationCenter" /t REG_DWORD /d 1 /f

REM Remove news and interests
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\Windows Feeds" /v "EnableFeeds" /t REG_DWORD /d 0 /f

REM Fix search ctfmon
reg add "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v "ctfmon" /t REG_SZ /d "C:\Windows\System32\ctfmon.exe" /f

REM Enable show thumbnails instead of icons
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v "IconsOnly" /t REG_DWORD /d 0 /f

REM Disable automatically update maps
reg add "HKEY_LOCAL_MACHINE\SYSTEM\Maps" /v "AutoUpdateEnabled" /t REG_DWORD /d 0 /f

echo Configuracoes aplicadas com sucesso!
echo Reiniciando o Explorer

REM Restart Explorer
taskkill /f /im explorer.exe
start explorer.exe

@echo ------Instalando Power Plan------
powercfg -import "c:\_install\_files\Power.pow" 77777777-7777-7777-7777-777777777777
powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
powercfg /query


@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

choco --version

choco install directx --ignore-checksums -y
choco install dotnet-runtime --ignore-checksums -y
choco install vcredist2008 --ignore-checksums -y
choco install vcredist2010 --ignore-checksums -y
choco install vscommands2012 --ignore-checksums -y
choco install vcredist2013 --ignore-checksums -y
choco install vcredist140 --ignore-checksums -y
choco install googlechrome --ignore-checksums -y
choco install winrar --ignore-checksums -y
choco install adobereader --ignore-checksums -y
choco install anydesk.install --ignore-checksums -y

timeout 2 >nul

:: Pergunta sobre a instalação do Office
set /p installOffice=Deseja instalar o Microsoft Office? (Digite 's' para sim, 'n' para nao): 

if /i "%installOffice%" equ "s" (
    echo Iniciando a instalacao do Microsoft Office...
    :: Adicione aqui os comandos ou chamadas de instalação do Office
		cd c:\_install\Office
		setup.exe /configure config.xml
		timeout 2 >nul
		copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Word.lnk" "%USERPROFILE%\Desktop\Word.lnk"
		copy "C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Excel.lnk" "%USERPROFILE%\Desktop\Excel.lnk"
) else (
    echo Pulando a instalacao do Microsoft Office.
)

timeout 2 >nul

:: Pergunta sobre a ativação do Windows/Office
set /p activateWindows=Deseja ativar o Windows/Office? (Digite 's' para sim, 'n' para nao): 

if /i "%activateWindows%" equ "s" (
    :: Adicione aqui os comandos ou chamadas para ativar o Windows
	powershell -Command "& {irm https://massgrave.dev/get | iex}"
    echo Ativando o Windows/Office...
) else (
    echo Pulando a ativacao do Windows.
)

timeout 2 >nul

:: Pergunta para excluir o diretório
set /p deleteDirectory=Deseja excluir o diretorio C:\_install? (Digite 's' para sim, 'n' para nao): 

if /i "%deleteDirectory%" equ "s" (
    :: Excluir o diretório
    rmdir /s /q "C:\_install"
    echo Diretorio C:\_install excluído.
) else (
    echo Operacao de exclusao cancelada.
)

timeout 2 >nul

@echo off
echo ------Criar Ponto De Restauracao------

wmic.exe /Namespace:\\root\default Path SystemRestore Call Enable "C:"
timeout 2 >nul
wmic.exe /Namespace:\\root\default Path SystemRestore Call CreateRestorePoint "INSTALL", 100, 7
timeout 2 >nul

echo Ponto de Restauracao criado com sucesso!

control /name Microsoft.WindowsUpdate

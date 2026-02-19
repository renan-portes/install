# ============================================================================
# WIN-TOOLKIT - MEU TÉCNICO ONLINE
# Criado por: Renan Portes
# Contato: (44) 98827-9740
# ============================================================================
#Requires -RunAsAdministrator

# --- CONFIGURAÇÕES GLOBAIS ---
$Host.UI.RawUI.WindowTitle = "WIN-TOOLKIT - MEU TÉCNICO ONLINE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Troque isso para o repositório onde estão seus arquivos do Office (setup.exe e config.xml)
$RepoURL = "https://raw.githubusercontent.com/renan-portes/install/main"

# ============================================================================
# 0. FUNÇÃO GLOBAL DE DOWNLOAD (Motor)
# ============================================================================
function Get-FileFromWeb {
    param (
        [Parameter(Mandatory)][string]$URL, 
        [Parameter(Mandatory)][string]$File,
        [string]$Referer = ""
    )
    
    function Show-Progress {
        param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 20)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % "
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        if ($Referer -ne "") { $request.Referer = $Referer }

        $response = $request.GetResponse()
        
        $fileDirectory = $([System.IO.Path]::GetDirectoryName($File))
        if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null }
        
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = new-object byte[] 1048576
        [long]$total = [long]$count = 0
        $reader = $response.GetResponseStream()
        $writer = new-object System.IO.FileStream $File, 'Create'
        
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            $writer.Write($buffer, 0, $count)
            $total += $count
            if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " Baixando $($File.Name):" }
        } while ($count -gt 0)
        Write-Host "" 
    }
    finally {
        if ($null -ne $reader) { $reader.Close() }
        if ($null -ne $writer) { $writer.Close() }
    }
}

# ============================================================================
# 1. MÓDULOS DE INSTALAÇÃO (Submenus Separados)
# ============================================================================

function Menu-Navegadores {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "                       NAVEGADORES                            " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host " [1] Google Chrome"
        Write-Host " [2] Mozilla Firefox"
        Write-Host " [3] Brave Browser"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Google Chrome..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -File "$env:TEMP\Chrome.msi"
                Start-Process -wait "$env:TEMP\Chrome.msi" -ArgumentList "/quiet"
                Write-Host " [OK] Google Chrome Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando Mozilla Firefox..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=pt-BR" -File "$env:TEMP\Firefox.exe"
                Start-Process -wait "$env:TEMP\Firefox.exe" -ArgumentList "/S" -WindowStyle Hidden
                Write-Host " [OK] Firefox Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando Brave Browser..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://laptop-updates.brave.com/latest/winx64" -File "$env:TEMP\Brave.exe"
                Start-Process -wait "$env:TEMP\Brave.exe" -ArgumentList "--silent --install" -WindowStyle Hidden
                Write-Host " [OK] Brave Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '0' { return }
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

function Menu-Utilidades {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "                       UTILIDADES                             " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host " [1] WinRAR (PT-BR)"
        Write-Host " [2] 7-Zip"
        Write-Host " [3] AnyDesk"
        Write-Host " [4] Discord"
        Write-Host " [5] Notepad++"
        Write-Host " [6] Adobe Reader (Completo)"
        Write-Host " [7] SumatraPDF (Super Leve)"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando WinRAR..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-701br.exe" -File "$env:TEMP\winrar.exe"
                Start-Process -wait "$env:TEMP\winrar.exe" -ArgumentList "/S"
                Write-Host " [OK] WinRAR Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando 7-Zip..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/7%20Zip.exe" -File "$env:TEMP\7Zip.exe"
                Start-Process -wait "$env:TEMP\7Zip.exe" -ArgumentList "/S"
                Write-Host " [OK] 7-Zip Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando AnyDesk..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://download.anydesk.com/AnyDesk.exe" -File "$env:TEMP\AnyDesk.exe"
                Start-Process -wait "$env:TEMP\AnyDesk.exe" -ArgumentList "--install `"$env:ProgramFiles(x86)\AnyDesk`" --start-with-win --silent"
                Write-Host " [OK] AnyDesk Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '4' { 
                Write-Host "`n>> Instalando Discord..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://dl.discordapp.net/distro/app/stable/win/x86/1.0.9036/DiscordSetup.exe" -File "$env:TEMP\Discord.exe"
                Start-Process -wait "$env:TEMP\Discord.exe" -ArgumentList "/s"
                Write-Host " [OK] Discord Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '5' { 
                Write-Host "`n>> Instalando Notepad++..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://github.com/FR33THYFR33THY/files/raw/main/Notepad%20++.exe" -File "$env:TEMP\Notepad++.exe"
                Start-Process -wait "$env:TEMP\Notepad++.exe" -ArgumentList "/S"
                Write-Host " [OK] Notepad++ Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '6' { 
                Write-Host "`n>> Instalando Adobe Reader..." -ForegroundColor Cyan
                $adobeUrl = "https://admdownload.adobe.com/bin/live/readerdc_pt_br_xa_crd_install.exe"
                Get-FileFromWeb -URL $adobeUrl -File "$env:TEMP\reader_install.exe" -Referer "https://get.adobe.com/br/reader/"
                Start-Process -wait "$env:TEMP\reader_install.exe" -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES"
                Write-Host " [OK] Adobe Reader Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '7' { 
                Write-Host "`n>> Instalando SumatraPDF..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://sumatrapdfreader.org/dl/SumatraPDF-3.5.2-64-install.exe" -File "$env:TEMP\SumatraPDF.exe"
                Start-Process -wait "$env:TEMP\SumatraPDF.exe" -ArgumentList "/S"
                Write-Host " [OK] SumatraPDF Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '0' { return }
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

function Menu-Launchers {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "                   LAUNCHERS DE JOGOS                         " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host " [1] Steam"
        Write-Host " [2] Epic Games"
        Write-Host " [3] Battle.net"
        Write-Host " [4] EA App (Electronic Arts)"
        Write-Host " [5] Ubisoft Connect"
        Write-Host " [6] GOG Galaxy"
        Write-Host " [7] Valorant / Riot"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Steam..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -File "$env:TEMP\Steam.exe"
                Start-Process -wait "$env:TEMP\Steam.exe" -ArgumentList "/S"
                Write-Host " [OK] Steam Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando Epic Games..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://epicgames-download1.akamaized.net/Builds/UnrealEngineLauncher/Installers/Win32/EpicInstaller-15.17.1.msi?launcherfilename=EpicInstaller-15.17.1.msi" -File "$env:TEMP\Epic.msi"
                Start-Process -wait "$env:TEMP\Epic.msi" -ArgumentList "/quiet"
                Write-Host " [OK] Epic Games Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando Battle.net..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -File "$env:TEMP\Battle.net.exe"
                Start-Process -wait "$env:TEMP\Battle.net.exe" -ArgumentList '--lang=ptBR --installpath="C:\Program Files (x86)\Battle.net"'
                Write-Host " [OK] Battle.net Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '4' { 
                Write-Host "`n>> Baixando EA App..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" -File "$env:TEMP\EAapp.exe"
                Start-Process "$env:TEMP\EAapp.exe"
                Write-Host " [OK] Instalador do EA App Aberto!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '5' { 
                Write-Host "`n>> Instalando Ubisoft Connect..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe" -File "$env:TEMP\Ubisoft.exe"
                Start-Process -wait "$env:TEMP\Ubisoft.exe" -ArgumentList "/S"
                Write-Host " [OK] Ubisoft Connect Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '6' { 
                Write-Host "`n>> Baixando GOG Galaxy..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" -File "$env:TEMP\GOG.exe"
                Start-Process "$env:TEMP\GOG.exe"
                Write-Host " [OK] Instalador do GOG Aberto!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '7' { 
                Write-Host "`n>> Baixando Valorant..." -ForegroundColor Cyan
                Get-FileFromWeb -URL "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe" -File "$env:TEMP\Valorant.exe"
                Start-Process "$env:TEMP\Valorant.exe"
                Write-Host " [OK] Instalador do Valorant Aberto!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '0' { return }
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

function Menu-Dependencias {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "                   DEPENDÊNCIAS (C++ e DirectX)               " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host " [1] Visual C++ Redistributables (AIO - Completo)"
        Write-Host " [2] DirectX Runtimes (Web Setup)"
        Write-Host " [3] Instalar Ambos"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Visual C++ Redistributables (AIO)..." -ForegroundColor Cyan
                $cppPath = "$env:TEMP\VCRedist_AIO.exe"
                Get-FileFromWeb -URL "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe" -File $cppPath
                Start-Process -wait $cppPath -ArgumentList "/ai" -WindowStyle Hidden
                Remove-Item $cppPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Visual C++ Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando DirectX Runtimes..." -ForegroundColor Cyan
                $dxPath = "$env:TEMP\dxwebsetup.exe"
                Get-FileFromWeb -URL "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -File $dxPath
                Start-Process -wait $dxPath -ArgumentList "/Q" -WindowStyle Hidden
                Remove-Item $dxPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] DirectX Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' {
                Write-Host "`n>> Instalando C++..." -ForegroundColor Cyan
                $cppPath = "$env:TEMP\VCRedist_AIO.exe"
                Get-FileFromWeb -URL "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe" -File $cppPath
                Start-Process -wait $cppPath -ArgumentList "/ai" -WindowStyle Hidden
                
                Write-Host ">> Instalando DirectX..." -ForegroundColor Cyan
                $dxPath = "$env:TEMP\dxwebsetup.exe"
                Get-FileFromWeb -URL "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -File $dxPath
                Start-Process -wait $dxPath -ArgumentList "/Q" -WindowStyle Hidden

                Remove-Item $cppPath, $dxPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Todas as dependências instaladas!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '0' { return }
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

function Menu-InstaladorGeral {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "               INSTALADOR DE PROGRAMAS E JOGOS                " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host " [1] Navegadores (Chrome, Brave, Firefox)"
        Write-Host " [2] Utilidades (WinRAR, 7-Zip, AnyDesk, PDF, etc.)"
        Write-Host " [3] Launchers de Jogos (Steam, Epic, EA, Ubisoft, etc.)"
        Write-Host " [4] Dependências (C++ All-in-One e DirectX)"
        Write-Host " [0] VOLTAR AO MENU PRINCIPAL"
        Write-Host ""
        
        $subEscolha = Read-Host " Escolha uma categoria"
        switch ($subEscolha) {
            '1' { Menu-Navegadores }
            '2' { Menu-Utilidades }
            '3' { Menu-Launchers }
            '4' { Menu-Dependencias }
            '0' { return }
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

# ============================================================================
# 2. OTIMIZAÇÕES DE REGISTRO
# ============================================================================
function Aplicar-Regedit {
    Clear-Host
    Write-Host "[-] Aplicando Otimizações de Registro (Performance e Privacidade)..." -ForegroundColor Yellow
    
    $RegTweaks = @"
Windows Registry Editor Version 5.00

; Extensões de Arquivos e Menu Clássico Win11
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"HideFileExt"=dword:00000000
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; Game Mode e Hardware GPU Scheduling
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"AutoGameModeEnabled"=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; Desativar Power Throttling e Otimizar Responsividade
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
"PowerThrottlingOff"=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

; Desativar Telemetria e Pesquisa na Web
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001

; Desativar Copilot e Widgets
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000
"@

    $RegPath = "$env:TEMP\OtimizacaoRenan.reg"
    Set-Content -Path $RegPath -Value $RegTweaks -Force
    Start-Process -wait "regedit.exe" -ArgumentList "/s `"$RegPath`"" -WindowStyle Hidden
    
    Write-Host " Reiniciando o Explorer para aplicar efeitos visuais..." -ForegroundColor Cyan
    Stop-Process -Name explorer -Force
    Remove-Item $RegPath -Force -ErrorAction SilentlyContinue

    Write-Host "`n[+] Registro otimizado com sucesso!" -ForegroundColor Green
    Pause
}

# ============================================================================
# 3. POWER PLAN DE ALTO DESEMPENHO
# ============================================================================
function Aplicar-PowerPlan {
    Clear-Host
    Write-Host "[-] Instalando Ultimate Power Plan e Ajustes de Energia..." -ForegroundColor Yellow

    Write-Host "`n Configurando e ativando esquema de energia Ultimate..." -ForegroundColor Cyan
    cmd /c "powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 99999999-9999-9999-9999-999999999999 >nul 2>&1"
    cmd /c "powercfg /SETACTIVE 99999999-9999-9999-9999-999999999999 >nul 2>&1"

    Write-Host " Limpando planos antigos e desativando Hibernação..." -ForegroundColor Cyan
    $output = powercfg /L
    $powerPlans = @()
    foreach ($line in $output) {
        if ($line -match ':') {
            $parse = $line -split ':'
            $index = $parse[1].Trim().indexof('(')
            if ($index -gt 0) {
                $guid = $parse[1].Trim().Substring(0, $index).Trim()
                if ($guid -ne "99999999-9999-9999-9999-999999999999") { $powerPlans += $guid }
            }
        }
    }
    foreach ($plan in $powerPlans) { cmd /c "powercfg /delete $plan >nul 2>&1" }
    
    powercfg /hibernate off
    cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power`" /v `"HiberbootEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"
    cmd /c "reg add `"HKLM\SYSTEM\ControlSet001\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\0cc5b647-c1df-4637-891a-dec35c318583`" /v `"ValueMax`" /t REG_DWORD /d `"100`" /f >nul 2>&1"

    Write-Host "`n[+] Plano de Energia otimizado com sucesso!" -ForegroundColor Green
    Pause
}

# ============================================================================
# 4. INSTALAÇÃO DO OFFICE 2024
# ============================================================================
function Instalar-Office {
    Clear-Host
    Write-Host "[-] Preparando instalação do Office..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    Write-Host " Baixando instalador e configuração do GitHub..." -ForegroundColor Cyan
    Get-FileFromWeb -URL "$RepoURL/setup.exe" -File "$OfficeTemp\setup.exe"
    Get-FileFromWeb -URL "$RepoURL/config.xml" -File "$OfficeTemp\config.xml"

    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host " Iniciando instalador da Microsoft..." -ForegroundColor Cyan
        Start-Process -wait "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml"
        Write-Host "`n[+] Office Instalado!" -ForegroundColor Green
        
        Write-Host " Criando atalhos na Área de Trabalho..." -ForegroundColor Cyan
        $Desktop = [Environment]::GetFolderPath("Desktop")
        # Caminho padrão onde o Office joga os atalhos para todos os usuários
        $CommonStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        
        # Lista dos atalhos que queremos puxar
        $Atalhos = @("Word.lnk", "Excel.lnk", "PowerPoint.lnk", "Access.lnk")
        
        foreach ($Atalho in $Atalhos) {
            Copy-Item "$CommonStartMenu\$Atalho" -Destination $Desktop -ErrorAction SilentlyContinue
        }
        Write-Host " [OK] Atalhos criados com sucesso!" -ForegroundColor Green

    } else {
        Write-Host "`n[!] ERRO: setup.exe não encontrado no seu GitHub." -ForegroundColor Red
    }
    
    Remove-Item -Path $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue
    Pause
}

# ============================================================================
# 5. ATIVAÇÃO DO SISTEMA
# ============================================================================
function Ativar-Sistema {
    Clear-Host
    Write-Host "[-] Abrindo Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    irm https://get.activated.win | iex
}

# ============================================================================
# 6. CONTATO WHATSAPP
# ============================================================================
function Abrir-WhatsApp {
    Clear-Host
    Write-Host "[-] Abrindo WhatsApp de Renan Portes..." -ForegroundColor Green
    $zapUrl = "https://wa.me/5544988279740?text=Ol%C3%A1%2C%20Renan!%20Estou%20usando%20o%20seu%20Toolkit%20e%20preciso%20de%20suporte."
    Start-Process $zapUrl
}

# ============================================================================
# MENU PRINCIPAL
# ============================================================================
function Mostrar-Menu {
    Clear-Host
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "               WIN-TOOLKIT - MEU TÉCNICO ONLINE               " -ForegroundColor White
    Write-Host "            Renan Portes | Contato: (44) 98827-9740           " -ForegroundColor DarkGray
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Instalador de Programas / Launchers / C++ e DirectX"
    Write-Host " [2] Otimizações de Registro (Regedit)"
    Write-Host " [3] Instalação de PowerPlan (Máximo Desempenho)"
    Write-Host " [4] Instalação do Office"
    Write-Host " [5] Ativação de Windows/Office"
    Write-Host " [6] Contato (WhatsApp Direto)"
    Write-Host " [0] Sair"
    Write-Host ""
}

do {
    Mostrar-Menu
    $escolha = Read-Host " Escolha uma opção"

    switch ($escolha) {
        '1' { Menu-InstaladorGeral }
        '2' { Aplicar-Regedit }
        '3' { Aplicar-PowerPlan }
        '4' { Instalar-Office }
        '5' { Ativar-Sistema }
        '6' { Abrir-WhatsApp }
        '0' { 
            Clear-Host
            Write-Host "Saindo... Obrigado por usar o WIN-TOOLKIT!" -ForegroundColor Green
            Start-Sleep -Seconds 2
            exit 
        }
        default { 
            Write-Host " Opção Inválida!" -ForegroundColor Red
            Start-Sleep -Seconds 1 
        }
    }
} while ($true)

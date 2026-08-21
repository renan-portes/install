# ============================================================================
# WIN-TOOLKIT - MEU TÉCNICO ONLINE
# Criado por: Renan Portes
# Contato: (44) 98827-9740
# ============================================================================
#Requires -RunAsAdministrator

# --- AUTO-ELEVAÇÃO ADMINISTRATIVA ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    if ($PSCommandPath) {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
        exit
    }
}

# --- CONFIGURAÇÕES GLOBAIS ---
$Host.UI.RawUI.WindowTitle = "WIN-TOOLKIT - MEU TÉCNICO ONLINE"
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.PrivateData.ProgressBackgroundColor = "Black"
$Host.PrivateData.ProgressForegroundColor = "White"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

# Repositório onde estão os arquivos auxiliares (setup.exe, config.xml, Power.pow, logo-win.bmp)
$RepoURL = "https://raw.githubusercontent.com/renan-portes/install/main"

# ============================================================================
# 0. FUNÇÕES GLOBAIS DE SUPORTE E DOWNLOAD (Motor)
# ============================================================================

function Get-FileFromWeb {
    param (
        [Parameter(Mandatory)][string]$URL, 
        [Parameter(Mandatory)][string]$File,
        [string]$Referer = ""
    )
    
    function Show-Progress {
        param (
            [Parameter(Mandatory)][Single]$TotalValue, 
            [Parameter(Mandatory)][Single]$CurrentValue, 
            [Parameter(Mandatory)][string]$ProgressText, 
            [Parameter()][int]$BarSize = 20
        )
        if ($TotalValue -gt 0) {
            $percent = [Math]::Min(1.0, [Math]::Max(0.0, ($CurrentValue / $TotalValue)))
            $percentComplete = $percent * 100
            $barFilled = [int]($BarSize * $percent)
            $bar = ("".PadRight($barFilled, [char]9608)).PadRight($BarSize, [char]9617)
            Write-Host -NoNewLine "`r$ProgressText $bar $($percentComplete.ToString('##0.00').PadLeft(6)) % "
        } else {
            $mb = ($CurrentValue / 1MB).ToString('0.00')
            Write-Host -NoNewLine "`r$ProgressText $mb MB baixados... "
        }
    }

    $fileName = [System.IO.Path]::GetFileName($File)
    $fileDirectory = [System.IO.Path]::GetDirectoryName($File)
    if (-not [string]::IsNullOrEmpty($fileDirectory) -and -not (Test-Path $fileDirectory)) {
        [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null
    }

    $reader = $null
    $writer = $null
    $response = $null
    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
        $request.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
        $request.AllowAutoRedirect = $true
        $request.Timeout = 60000
        if ($Referer -ne "") { $request.Referer = $Referer }

        $response = $request.GetResponse()
        [long]$fullSize = $response.ContentLength
        [byte[]]$buffer = New-Object byte[] 65536
        [long]$total = 0
        $reader = $response.GetResponseStream()
        $writer = New-Object System.IO.FileStream $File, 'Create'
        
        $count = 0
        do {
            $count = $reader.Read($buffer, 0, $buffer.Length)
            if ($count -gt 0) {
                $writer.Write($buffer, 0, $count)
                $total += $count
                Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " Baixando $($fileName):"
            }
        } while ($count -gt 0)
        Write-Host "" 
    }
    catch {
        Write-Host ""
        Write-Host " [!] Erro no download de $($fileName): $($_.Exception.Message)" -ForegroundColor Red
        throw $_
    }
    finally {
        if ($null -ne $reader) { $reader.Close() }
        if ($null -ne $writer) { $writer.Close() }
        if ($null -ne $response) { $response.Close() }
    }
}

function Get-RepoAsset {
    param (
        [Parameter(Mandatory)][string]$FileName,
        [Parameter(Mandatory)][string]$DestinationPath
    )
    # 1. Se estiver rodando localmente e o arquivo existir na mesma pasta do script
    if ($PSScriptRoot -and (Test-Path "$PSScriptRoot\$FileName")) {
        Copy-Item "$PSScriptRoot\$FileName" -Destination $DestinationPath -Force
        return
    }
    # 2. Caso contrário, faz o download do GitHub
    Get-FileFromWeb -URL "$RepoURL/$FileName" -File $DestinationPath
}

function Get-LatestNotepadPlusPlusUrl {
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $json = $wc.DownloadString("https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest")
        $obj = ConvertFrom-Json $json
        $asset = $obj.assets | Where-Object { $_.name -like "npp.*.Installer.x64.exe" } | Select-Object -First 1
        if ($asset) { return $asset.browser_download_url }
    } catch {}
    return "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.9.7/npp.8.9.7.Installer.x64.exe"
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
        Write-Host " [1] Google Chrome (Enterprise 64-bit)"
        Write-Host " [2] Mozilla Firefox (64-bit PT-BR)"
        Write-Host " [3] Brave Browser (Instalação Silenciosa)"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Google Chrome..." -ForegroundColor Cyan
                $chromePath = "$env:TEMP\Chrome.msi"
                Get-FileFromWeb -URL "https://dl.google.com/dl/chrome/install/googlechromestandaloneenterprise64.msi" -File $chromePath
                Start-Process -Wait $chromePath -ArgumentList "/quiet /norestart"
                Remove-Item $chromePath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Google Chrome Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando Mozilla Firefox..." -ForegroundColor Cyan
                $firefoxPath = "$env:TEMP\Firefox.exe"
                Get-FileFromWeb -URL "https://download.mozilla.org/?product=firefox-latest-ssl&os=win64&lang=pt-BR" -File $firefoxPath
                Start-Process -Wait $firefoxPath -ArgumentList "/S" -WindowStyle Hidden
                Remove-Item $firefoxPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Firefox Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Preparando a instalação do Brave..." -ForegroundColor Cyan
                
                # Limpeza preventiva para derrubar instalações velhas travadas
                Get-Process "Brave*", "setup", "braveupdate" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
                
                $BraveUrl = "https://github.com/brave/brave-browser/releases/latest/download/BraveBrowserStandaloneSilentSetup.exe"
                $BravePath = "$env:TEMP\BraveSilent.exe"
                
                if (Test-Path $BravePath) { Remove-Item $BravePath -Force -ErrorAction SilentlyContinue }
                
                Write-Host ">> Baixando a última versão (Instalador Oficial Silencioso)..." -ForegroundColor Cyan
                Get-FileFromWeb -URL $BraveUrl -File $BravePath
                
                if (Test-Path $BravePath) {
                    Write-Host ">> Instalando em segundo plano..." -ForegroundColor Cyan
                    Start-Process -Wait $BravePath
                    Remove-Item $BravePath -Force -ErrorAction SilentlyContinue
                    Write-Host " [OK] Brave Instalado com sucesso!" -ForegroundColor Green; Start-Sleep -Seconds 2
                } else {
                    Write-Host " [!] Erro ao baixar o instalador do Brave!" -ForegroundColor Red; Start-Sleep -Seconds 2
                }
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
        Write-Host " [1] WinRAR (64-bit PT-BR)"
        Write-Host " [2] 7-Zip (64-bit Oficial)"
        Write-Host " [3] AnyDesk (Acesso Remoto)"
        Write-Host " [4] Discord (Versão Mais Recente)"
        Write-Host " [5] Notepad++ (64-bit Oficial)"
        Write-Host " [6] Adobe Reader (Completo MUI Corporativo)"
        Write-Host " [7] SumatraPDF (Super Leve 64-bit)"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando WinRAR..." -ForegroundColor Cyan
                $winrarPath = "$env:TEMP\winrar.exe"
                Get-FileFromWeb -URL "https://www.rarlab.com/rar/winrar-x64-701br.exe" -File $winrarPath
                Start-Process -Wait $winrarPath -ArgumentList "/S"
                Remove-Item $winrarPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] WinRAR Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando 7-Zip..." -ForegroundColor Cyan
                $sevenZipPath = "$env:TEMP\7Zip.exe"
                Get-FileFromWeb -URL "https://www.7-zip.org/a/7z2408-x64.exe" -File $sevenZipPath
                Start-Process -Wait $sevenZipPath -ArgumentList "/S"
                Remove-Item $sevenZipPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] 7-Zip Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando AnyDesk..." -ForegroundColor Cyan
                $AnyDeskPath = "$env:TEMP\AnyDesk.exe"
                if (Test-Path $AnyDeskPath) { Remove-Item $AnyDeskPath -Force -ErrorAction SilentlyContinue }
                
                Get-FileFromWeb -URL "https://download.anydesk.com/AnyDesk.exe" -File $AnyDeskPath
                
                if (Test-Path $AnyDeskPath) {
                    Write-Host ">> Executando instalação e configurando atalhos..." -ForegroundColor Cyan
                    $Argumentos = "--install `"C:\Program Files (x86)\AnyDesk`" --start-with-win --create-shortcuts --create-desktop-icon --silent"
                    Start-Process -FilePath $AnyDeskPath -ArgumentList $Argumentos -Wait
                    Remove-Item $AnyDeskPath -Force -ErrorAction SilentlyContinue
                    Write-Host " [OK] AnyDesk Instalado com sucesso!" -ForegroundColor Green; Start-Sleep -Seconds 2
                } else {
                    Write-Host " [!] Erro ao baixar o AnyDesk!" -ForegroundColor Red; Start-Sleep -Seconds 2
                }
            }
            '4' { 
                Write-Host "`n>> Instalando Discord..." -ForegroundColor Cyan
                $discordPath = "$env:TEMP\Discord.exe"
                Get-FileFromWeb -URL "https://discord.com/api/download?platform=win" -File $discordPath
                Start-Process -Wait $discordPath -ArgumentList "/s"
                Remove-Item $discordPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Discord Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '5' { 
                Write-Host "`n>> Buscando última versão do Notepad++..." -ForegroundColor Cyan
                $nppUrl = Get-LatestNotepadPlusPlusUrl
                $nppPath = "$env:TEMP\Notepad++.exe"
                Get-FileFromWeb -URL $nppUrl -File $nppPath
                Start-Process -Wait $nppPath -ArgumentList "/S"
                Remove-Item $nppPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Notepad++ Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '6' { 
                Write-Host "`n>> Preparando a instalação do Adobe Reader..." -ForegroundColor Cyan
                $AdobeUrl = "https://ardownload2.adobe.com/pub/adobe/acrobat/win/AcrobatDC/2500121111/AcroRdrDCx642500121111_MUI.exe"
                $AdobePath = "$env:TEMP\AdobeReaderMUI.exe"
                
                if (Test-Path $AdobePath) { Remove-Item $AdobePath -Force -ErrorAction SilentlyContinue }
                
                Write-Host ">> Baixando a versão corporativa (Aguarde, arquivo com aprox. 350MB)..." -ForegroundColor Yellow
                Get-FileFromWeb -URL $AdobeUrl -File $AdobePath
                
                if (Test-Path $AdobePath) {
                    Write-Host ">> Executando instalação silenciosa..." -ForegroundColor Cyan
                    Start-Process -Wait $AdobePath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES"
                    Remove-Item $AdobePath -Force -ErrorAction SilentlyContinue
                    Write-Host " [OK] Adobe Reader Instalado com sucesso!" -ForegroundColor Green; Start-Sleep -Seconds 2
                } else {
                    Write-Host " [!] Erro ao baixar o Adobe Reader!" -ForegroundColor Red; Start-Sleep -Seconds 2
                }
            }
            '7' { 
                Write-Host "`n>> Instalando SumatraPDF..." -ForegroundColor Cyan
                $sumatraPath = "$env:TEMP\SumatraPDF.exe"
                Get-FileFromWeb -URL "https://www.sumatrapdfreader.org/dl/rel/3.6.1/SumatraPDF-3.6.1-64-install.exe" -File $sumatraPath
                Start-Process -Wait $sumatraPath -ArgumentList "-s"
                Remove-Item $sumatraPath -Force -ErrorAction SilentlyContinue
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
        Write-Host " [2] Epic Games Launcher"
        Write-Host " [3] Battle.net (Blizzard)"
        Write-Host " [4] EA App (Electronic Arts)"
        Write-Host " [5] Ubisoft Connect"
        Write-Host " [6] GOG Galaxy"
        Write-Host " [7] Valorant / Riot Client"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número do programa"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Steam..." -ForegroundColor Cyan
                $steamPath = "$env:TEMP\SteamSetup.exe"
                Get-FileFromWeb -URL "https://cdn.cloudflare.steamstatic.com/client/installer/SteamSetup.exe" -File $steamPath
                Start-Process -Wait $steamPath -ArgumentList "/S"
                Remove-Item $steamPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Steam Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando Epic Games Launcher..." -ForegroundColor Cyan
                $epicPath = "$env:TEMP\EpicGames.msi"
                Get-FileFromWeb -URL "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi" -File $epicPath
                Start-Process -Wait $epicPath -ArgumentList "/quiet /norestart"
                Remove-Item $epicPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Epic Games Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando Battle.net..." -ForegroundColor Cyan
                $bnetPath = "$env:TEMP\Battle.net.exe"
                Get-FileFromWeb -URL "https://downloader.battle.net/download/getInstaller?os=win&installer=Battle.net-Setup.exe" -File $bnetPath
                Start-Process -Wait $bnetPath -ArgumentList '--lang=ptBR --installpath="C:\Program Files (x86)\Battle.net"'
                Remove-Item $bnetPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Battle.net Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '4' { 
                Write-Host "`n>> Baixando EA App..." -ForegroundColor Cyan
                $eaPath = "$env:TEMP\EAapp.exe"
                Get-FileFromWeb -URL "https://origin-a.akamaihd.net/EA-Desktop-Client-Download/installer-releases/EAappInstaller.exe" -File $eaPath
                Start-Process $eaPath
                Write-Host " [OK] Instalador do EA App Aberto!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '5' { 
                Write-Host "`n>> Instalando Ubisoft Connect..." -ForegroundColor Cyan
                $ubiPath = "$env:TEMP\Ubisoft.exe"
                Get-FileFromWeb -URL "https://static3.cdn.ubi.com/orbit/launcher_installer/UbisoftConnectInstaller.exe" -File $ubiPath
                Start-Process -Wait $ubiPath -ArgumentList "/S"
                Remove-Item $ubiPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Ubisoft Connect Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '6' { 
                Write-Host "`n>> Baixando GOG Galaxy..." -ForegroundColor Cyan
                $gogPath = "$env:TEMP\GOG.exe"
                Get-FileFromWeb -URL "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe" -File $gogPath
                Start-Process $gogPath
                Write-Host " [OK] Instalador do GOG Aberto!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '7' { 
                Write-Host "`n>> Baixando Instalador do Valorant / Riot..." -ForegroundColor Cyan
                $riotPath = "$env:TEMP\Valorant.exe"
                Get-FileFromWeb -URL "https://valorant.secure.dyn.riotcdn.net/channels/public/x/installer/current/live.live.ap.exe" -File $riotPath
                Start-Process $riotPath
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
        Write-Host " [1] Visual C++ Redistributables (AIO - Completo x86/x64)"
        Write-Host " [2] DirectX Runtimes (Web Setup)"
        Write-Host " [3] Instalar Ambos (Recomendado para Jogos)"
        Write-Host " [0] Voltar"
        Write-Host ""
        
        $op = Read-Host " Digite o número"
        switch ($op) {
            '1' { 
                Write-Host "`n>> Instalando Visual C++ Redistributables (AIO)..." -ForegroundColor Cyan
                $cppPath = "$env:TEMP\VCRedist_AIO.exe"
                Get-FileFromWeb -URL "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe" -File $cppPath
                Start-Process -Wait $cppPath -ArgumentList "/ai" -WindowStyle Hidden
                Remove-Item $cppPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Visual C++ Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '2' { 
                Write-Host "`n>> Instalando DirectX Runtimes..." -ForegroundColor Cyan
                $dxPath = "$env:TEMP\dxwebsetup.exe"
                Get-FileFromWeb -URL "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -File $dxPath
                Start-Process -Wait $dxPath -ArgumentList "/Q" -WindowStyle Hidden
                Remove-Item $dxPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] DirectX Instalado!" -ForegroundColor Green; Start-Sleep -Seconds 2
            }
            '3' { 
                Write-Host "`n>> Instalando Visual C++..." -ForegroundColor Cyan
                $cppPath = "$env:TEMP\VCRedist_AIO.exe"
                Get-FileFromWeb -URL "https://github.com/abbodi1406/vcredist/releases/latest/download/VisualCppRedist_AIO_x86_x64.exe" -File $cppPath
                Start-Process -Wait $cppPath -ArgumentList "/ai" -WindowStyle Hidden
                
                Write-Host ">> Instalando DirectX..." -ForegroundColor Cyan
                $dxPath = "$env:TEMP\dxwebsetup.exe"
                Get-FileFromWeb -URL "https://download.microsoft.com/download/1/7/1/1718CCC4-6315-4D8E-9543-8E28A4E18C4C/dxwebsetup.exe" -File $dxPath
                Start-Process -Wait $dxPath -ArgumentList "/Q" -WindowStyle Hidden

                Remove-Item $cppPath, $dxPath -Force -ErrorAction SilentlyContinue
                Write-Host " [OK] Todas as dependências instaladas com sucesso!" -ForegroundColor Green; Start-Sleep -Seconds 2
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
        Write-Host " [1] Navegadores (Chrome, Firefox, Brave)"
        Write-Host " [2] Utilidades (WinRAR, 7-Zip, AnyDesk, Discord, PDF, etc.)"
        Write-Host " [3] Launchers de Jogos (Steam, Epic, Battle.net, EA, etc.)"
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
# 2. OTIMIZAÇÕES DE REGISTRO E OEM BRANDING (Logo do Técnico)
# ============================================================================
function Aplicar-Regedit {
    Clear-Host
    Write-Host "[-] Aplicando Otimizações de Registro e Marca do Técnico..." -ForegroundColor Yellow
    
    # 1. Configurar Logo e Informações de Suporte
    Write-Host ">> Configurando Informações de Suporte (OEM)..." -ForegroundColor Cyan
    $TechPath = "C:\meutecnico"
    if (-not (Test-Path $TechPath)) { New-Item -ItemType Directory -Force -Path $TechPath | Out-Null }
    
    Get-RepoAsset -FileName "logo-win.bmp" -DestinationPath "$TechPath\logo-win.bmp"
    
    # Oculta a pasta para proteção
    Set-ItemProperty -Path $TechPath -Name Attributes -Value "Hidden" -ErrorAction SilentlyContinue

    Write-Host ">> Injetando Otimizações Visuais, de Performance e Privacidade..." -ForegroundColor Cyan
    $RegTweaks = @"
Windows Registry Editor Version 5.00

; INFORMAÇÕES DO TÉCNICO (OEM)
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\OEMInformation]
"Manufacturer"="MEU TECNICO ONLINE - Renan Portes"
"SupportPhone"="(44) 98827-9740"
"SupportURL"="https://wa.me/5544988279740"
"Logo"="C:\\meutecnico\\logo-win.bmp"

; ÍCONES NA ÁREA DE TRABALHO E EXPLORADOR
; Meu Computador e Pasta do Usuário na Área de Trabalho
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel]
"{20D04FE0-3AEA-1069-A2D8-08002B30309D}"=dword:00000000
"{59031a47-3f72-44a7-89c5-5595fe6b30ee}"=dword:00000000

; Abrir Explorador de Arquivos em "Este Computador" e Mostrar Extensões
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"LaunchTo"=dword:00000001
"HideFileExt"=dword:00000000

; Restaurar Menu de Contexto Clássico (Windows 11)
[HKEY_CURRENT_USER\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32]
@=""

; LIMPEZA DA BARRA DE TAREFAS E MENU INICIAR
; Desativar Cortana, Visão de Tarefas, Chat e Meet Now
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced]
"ShowCortanaButton"=dword:00000000
"ShowTaskViewButton"=dword:00000000
"ShowCopilotButton"=dword:00000000
"TaskbarDa"=dword:00000000
"TaskbarMn"=dword:00000000
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer]
"HideSCAMeetNow"=dword:00000001

; Reduzir caixa de pesquisa para apenas o ícone
[HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Search]
"SearchboxTaskbarMode"=dword:00000001

; Desativar pesquisa na Web no Menu Iniciar
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Explorer]
"DisableSearchBoxSuggestions"=dword:00000001
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\Windows Search]
"DisableWebSearch"=dword:00000001
"ConnectedSearchUseWeb"=dword:00000000
"AllowCortana"=dword:00000000

; PERFORMANCE E SISTEMA
; Game Mode e Hardware GPU Scheduling (HAGS)
[HKEY_CURRENT_USER\Software\Microsoft\GameBar]
"AutoGameModeEnabled"=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\GraphicsDrivers]
"HwSchMode"=dword:00000002

; Desativar Power Throttling e Otimizar Responsividade (Win32PrioritySeparation)
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling]
"PowerThrottlingOff"=dword:00000001
[HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\PriorityControl]
"Win32PrioritySeparation"=dword:00000026

; Desativar Telemetria Básica
[HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\DataCollection]
"AllowTelemetry"=dword:00000000

; Desativar Copilot e Widgets (Windows 10/11)
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001
[HKEY_CURRENT_USER\Software\Policies\Microsoft\Windows\WindowsCopilot]
"TurnOffWindowsCopilot"=dword:00000001
[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Dsh] 
"AllowNewsAndInterests"=dword:00000000

; CORREÇÕES (FIX)
; Correção de erro de Impressora de Rede
[HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Print]
"RpcAuthnLevelPrivacyEnabled"=dword:00000001

; Correção da barra de pesquisa não digitar (ctfmon)
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run]
"ctfmon"="C:\\Windows\\System32\\ctfmon.exe"
"@

    $RegPath = "$env:TEMP\OtimizacaoRenan.reg"
    Set-Content -Path $RegPath -Value $RegTweaks -Force -Encoding ASCII
    Start-Process -Wait "regedit.exe" -ArgumentList "/s `"$RegPath`"" -WindowStyle Hidden
    
    Write-Host ">> Reiniciando o Windows Explorer para aplicar efeitos visuais..." -ForegroundColor Cyan
    Stop-Process -Name explorer -Force
    Remove-Item $RegPath -Force -ErrorAction SilentlyContinue

    Write-Host "`n[+] Sistema otimizado e Marca do Técnico registrada com sucesso!" -ForegroundColor Green
    Pause
}

# ============================================================================
# 3. POWER PLAN DE ALTO DESEMPENHO (Bitsum / Process Lasso)
# ============================================================================
function Aplicar-PowerPlan {
    Clear-Host
    Write-Host "[-] Instalando Bitsum Highest Performance (Process Lasso)..." -ForegroundColor Yellow

    Write-Host "`n>> Obtendo plano de energia otimizado..." -ForegroundColor Cyan
    $PowFile = "$env:TEMP\Power.pow"
    Get-RepoAsset -FileName "Power.pow" -DestinationPath $PowFile

    if (Test-Path $PowFile) {
        Write-Host ">> Importando e ativando o plano Bitsum..." -ForegroundColor Cyan
        cmd /c "powercfg -import `"$PowFile`" 77777777-7777-7777-7777-777777777777 >nul 2>&1"
        cmd /c "powercfg -SETACTIVE 77777777-7777-7777-7777-777777777777 >nul 2>&1"

        Write-Host ">> Limpando planos de energia secundários e desativando Hibernação..." -ForegroundColor Cyan
        $output = powercfg /list
        $powerPlans = @()
        foreach ($line in $output) {
            if ($line -match '([0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12})') {
                $guid = $matches[1]
                if ($guid -ne "77777777-7777-7777-7777-777777777777" -and $guid -ne "381b4222-f694-41f0-9685-ff5bb260df2e") {
                    $powerPlans += $guid
                }
            }
        }
        
        foreach ($plan in $powerPlans) { cmd /c "powercfg /delete $plan >nul 2>&1" }
        
        # Desativa hibernação e Fast Startup
        powercfg /hibernate off
        cmd /c "reg add `"HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power`" /v `"HiberbootEnabled`" /t REG_DWORD /d `"0`" /f >nul 2>&1"

        Remove-Item $PowFile -Force -ErrorAction SilentlyContinue
        Write-Host "`n[+] Plano Bitsum ativado com sucesso!" -ForegroundColor Green
        
        # Abre a tela de Opções de Energia
        Start-Process powercfg.cpl
    } else {
        Write-Host "`n[!] ERRO: Arquivo Power.pow não pôde ser obtido." -ForegroundColor Red
    }
    
    Pause
}

# ============================================================================
# 4. INSTALAÇÃO DO OFFICE 2024
# ============================================================================
function Instalar-Office {
    Clear-Host
    Write-Host "[-] Preparando instalação do Microsoft Office 2024 LTSC..." -ForegroundColor Yellow
    
    # 1. MATAR PROCESSOS TRAVADOS
    $processos = Get-Process "setup" -ErrorAction SilentlyContinue
    if ($processos) {
        Write-Host " Limpando instaladores travados de tentativas anteriores..." -ForegroundColor Cyan
        $processos | Stop-Process -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
    }
    
    $OfficeTemp = "C:\OfficeTemp"
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    Write-Host " Preparando arquivos de instalação do Office..." -ForegroundColor Cyan
    Get-RepoAsset -FileName "setup.exe" -DestinationPath "$OfficeTemp\setup.exe"
    Get-RepoAsset -FileName "config.xml" -DestinationPath "$OfficeTemp\config.xml"

    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host " Iniciando instalador oficial da Microsoft (Aguarde alguns minutos em segundo plano)..." -ForegroundColor Yellow
        
        Start-Process "$OfficeTemp\setup.exe" -ArgumentList "/configure `"$OfficeTemp\config.xml`"" -Wait
        
        Write-Host "`n[+] Office Instalado com sucesso!" -ForegroundColor Green
        
        # 2. CONFIGURAR ATALHOS NA ÁREA DE TRABALHO
        Write-Host " Configurando atalhos na Área de Trabalho..." -ForegroundColor Cyan
        $Desktop = [Environment]::GetFolderPath("Desktop")
        $CommonStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
        $UserStartMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
        
        $OfficeExecutables = @{
            "Word.lnk"       = "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE"
            "Excel.lnk"      = "C:\Program Files\Microsoft Office\root\Office16\EXCEL.EXE"
            "PowerPoint.lnk" = "C:\Program Files\Microsoft Office\root\Office16\POWERPNT.EXE"
        }
        
        $WshShell = New-Object -ComObject WScript.Shell
        foreach ($shortcutName in $OfficeExecutables.Keys) {
            $targetExe = $OfficeExecutables[$shortcutName]
            $destShortcut = "$Desktop\$shortcutName"
            
            # Tenta primeiro copiar do Start Menu se existir
            $copied = $false
            foreach ($folder in @($CommonStartMenu, $UserStartMenu, "$CommonStartMenu\Microsoft Office")) {
                if (Test-Path "$folder\$shortcutName") {
                    Copy-Item "$folder\$shortcutName" -Destination $destShortcut -Force -ErrorAction SilentlyContinue
                    $copied = $true
                    break
                }
            }
            
            # Se não encontrou atalho pronto, cria via WScript.Shell diretamente apontando para o .EXE
            if (-not $copied -and (Test-Path $targetExe)) {
                $shortcut = $WshShell.CreateShortcut($destShortcut)
                $shortcut.TargetPath = $targetExe
                $shortcut.Save()
            }
        }
        
        Write-Host " [OK] Atalhos do Office configurados na Área de Trabalho!" -ForegroundColor Green

    } else {
        Write-Host "`n[!] ERRO: setup.exe do Office não pôde ser obtido." -ForegroundColor Red
    }
    
    Remove-Item -Path $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue
    Pause
}

# ============================================================================
# 5. ATIVAÇÃO DO SISTEMA (MAS)
# ============================================================================
function Ativar-Sistema {
    Clear-Host
    Write-Host "[-] Abrindo Microsoft Activation Scripts (MAS)..." -ForegroundColor Yellow
    Start-Sleep -Seconds 1
    try {
        irm https://get.activated.win | iex
    }
    catch {
        Write-Host " [!] Tentando servidor secundário..." -ForegroundColor Yellow
        irm https://massgrave.dev/get | iex
    }
}

# ============================================================================
# 6. CONTATO WHATSAPP E APOIO PIXGG
# ============================================================================
function Abrir-WhatsApp {
    Clear-Host
    Write-Host "[-] Abrindo WhatsApp de Renan Portes..." -ForegroundColor Green
    $zapUrl = "https://wa.me/5544988279740?text=Ol%C3%A1%2C%20Renan!%20Estou%20usando%20o%20seu%20Toolkit%20e%20preciso%20de%20suporte."
    Start-Process $zapUrl
}

function Abrir-Apoio {
    Clear-Host
    Write-Host "[-] Abrindo página de apoio PixGG (pixgg.com.br/rzao)..." -ForegroundColor Cyan
    $pixUrl = "https://pixgg.com.br/rzao"
    Start-Process $pixUrl
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
    Write-Host " [2] Otimizações de Registro (Regedit & Performance)"
    Write-Host " [3] Instalação de PowerPlan (Bitsum Highest Performance)"
    Write-Host " [4] Instalação do Office 2024 LTSC"
    Write-Host " [5] Ativação de Windows / Office (MAS)"
    Write-Host " [6] Contato (WhatsApp Direto)"
    Write-Host " [7] Apoiar o Projeto (PixGG)"
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
        '7' { Abrir-Apoio }
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

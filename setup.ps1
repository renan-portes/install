<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.5 (Adobe Web Installer Fix)
Contato: (44) 98827.9740
#>

# --- CONFIGURAÇÃO INICIAL ---
$RepoURL = "https://raw.githubusercontent.com/renan-portes/install/main"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Show-Menu {
    Clear-Host
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "               RENAN PORTES - MEU TÉCNICO ONLINE              " -ForegroundColor White
    Write-Host "                  Contato: (44) 98827.9740                    " -ForegroundColor DarkGray
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host " [1] Instalar Essenciais (Chrome, Adobe Reader, WinRAR, AnyDesk)"
    Write-Host " [2] Instalar Office 2024 (Configuração Personalizada)"
    Write-Host " [3] Aplicar Otimizações (Regedit + Plano de Energia + Logo)"
    Write-Host " [4] Ativar Windows/Office (MAS Script)"
    Write-Host " [0] Sair"
    Write-Host ""
}

# Função auxiliar para download seguro (Simula um navegador real)
function Download-File {
    param ($Url, $Path)
    try {
        # Adiciona User-Agent para evitar bloqueios (Erro 196 bytes)
        $proc = Start-Process "curl.exe" -ArgumentList "-L", "-A", "Mozilla/5.0", "-o", "$Path", "$Url" -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -ne 0) { throw "Curl error" }
    } catch {
        Invoke-WebRequest -Uri $Url -OutFile $Path -UserAgent "Mozilla/5.0"
    }
}

function Install-Essentials {
    Write-Host "[-] Verificando ambiente..." -ForegroundColor Yellow
    
    $wingetReady = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetReady = $true }
    
    if (-not $wingetReady) {
        Write-Host "Winget não detectado. Tentando configurar..." -ForegroundColor Cyan
        # Tentativa silenciosa de dependências. Se falhar, vamos direto pro Legacy.
        $tempPath = "$env:TEMP"
        
        # 1. VCLibs
        Download-File "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" "$tempPath\vclibs.appx"
        Add-AppxPackage -Path "$tempPath\vclibs.appx" -ErrorAction SilentlyContinue

        # 2. UI.Xaml
        Download-File "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" "$tempPath\xaml.appx"
        Add-AppxPackage -Path "$tempPath\xaml.appx" -ErrorAction SilentlyContinue

        # 3. Winget
        Download-File "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "$tempPath\winget.msixbundle"
        try {
            Add-AppxPackage -Path "$tempPath\winget.msixbundle" -ErrorAction Stop
            $wingetReady = $true
            Write-Host "Winget ativado!" -ForegroundColor Green
        } catch {
            Write-Host "Aviso: Winget falhou (Erro de dependência do Windows). Usando instaladores diretos." -ForegroundColor Yellow
            Start-Sleep 2
        }
    }

    $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetCmd = "winget" }

    Write-Host "[-] Iniciando instalação de programas..." -ForegroundColor Yellow
    
    # Tenta Winget apenas se estiver 100% funcional
    if ($wingetReady -and ((Test-Path $wingetCmd) -or (Get-Command winget -ErrorAction SilentlyContinue))) {
        $apps = @{
            "Google Chrome" = "Google.Chrome"
            "Adobe Reader"  = "Adobe.Acrobat.Reader.64-bit"
            "WinRAR"        = "RARLab.WinRAR"
            "AnyDesk"       = "AnyDeskSoftwareGmbH.AnyDesk"
        }
        foreach ($app in $apps.GetEnumerator()) {
            Write-Host "Instalando $($app.Key)..." -ForegroundColor Cyan
            try {
                Start-Process -FilePath $wingetCmd -ArgumentList "install --id $($app.Value) -e --silent --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
            } catch { Write-Host "Erro Winget. Tentando legado..." -ForegroundColor Red }
        }
    } else {
        # --- MODO LEGACY (Instaladores Diretos - Mais Robusto) ---
        Write-Host ">>> MODO INSTALAÇÃO DIRETA ATIVADO <<<" -ForegroundColor Magenta
        
        # Chrome
        Write-Host "Instalando Chrome..."
        $chromePath = "$env:TEMP\chrome.msi"
        Download-File "https://dl.google.com/chrome/install/googlechromestandaloneenterprise64.msi" $chromePath
        Start-Process "msiexec.exe" -ArgumentList "/i $chromePath /quiet /norestart" -Wait

        # WinRAR
        Write-Host "Instalando WinRAR..."
        $rarPath = "$env:TEMP\winrar.exe"
        Download-File "https://www.win-rar.com/fileadmin/winrar-versions/winrar/winrar-x64-701.exe" $rarPath
        if ((Get-Item $rarPath).Length -gt 1000000) {
            Start-Process -FilePath $rarPath -ArgumentList "/S" -Wait
        }

        # AnyDesk
        Write-Host "Instalando AnyDesk..."
        $anyPath = "$env:TEMP\AnyDesk.exe"
        Download-File "https://download.anydesk.com/AnyDesk.exe" $anyPath
        Start-Process -FilePath $anyPath -ArgumentList "--install `"$env:ProgramFiles(x86)\AnyDesk`" --start-with-win --silent" -Wait

        # Adobe Reader (WEB INSTALLER - CORREÇÃO)
        Write-Host "Instalando Adobe Reader (Versão Web - Rápido)..."
        $readerPath = "$env:TEMP\reader_install.exe"
        # Link oficial genérico da Adobe (sempre funciona)
        Download-File "https://admdownload.adobe.com/bin/live/readerdc_pt_br_xa_crd_install.exe" $readerPath
        
        if ((Get-Item $readerPath).Length -gt 500000) { # Verifica se baixou > 500kb
            # Argumentos silenciosos do instalador web
            Start-Process -FilePath $readerPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait
        } else { 
            Write-Host "Erro: Falha no download do Adobe Reader." -ForegroundColor Red 
        }
    }

    Write-Host "Fim da instalação!" -ForegroundColor Green
    Pause
}

function Install-Office {
    Write-Host "[-] Preparando instalação do Office 2024..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    Write-Host "Baixando Instalador do GitHub..."
    Download-File "$RepoURL/setup.exe" "$OfficeTemp\setup.exe"

    Write-Host "Baixando Configuração..."
    Download-File "$RepoURL/config.xml" "$OfficeTemp\config.xml"

    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host "Iniciando instalação..." -ForegroundColor Cyan
        try {
            Start-Process -FilePath "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
            Write-Host "Office Instalado!" -ForegroundColor Green
        } catch { Write-Host "Erro ao rodar instalador." -ForegroundColor Red }
    } else {
        Write-Host "Erro: setup.exe não encontrado no GitHub." -ForegroundColor Red
    }
    
    Remove-Item -Path $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue
    
    # Atalhos
    $Desktop = [Environment]::GetFolderPath("Desktop")
    $CommonStartMenu = "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
    Copy-Item "$CommonStartMenu\Excel.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    Copy-Item "$CommonStartMenu\Word.lnk" -Destination $Desktop -ErrorAction SilentlyContinue
    
    Pause
}

function Apply-Tweaks {
    Write-Host "[-] Aplicando Otimizações..." -ForegroundColor Yellow
    $TechPath = "C:\meutecnico"
    New-Item -ItemType Directory -Force -Path $TechPath | Out-Null
    
    Write-Host "Baixando recursos..."
    try {
        Download-File "$RepoURL/logo-win.bmp" "$TechPath\logo-win.bmp"
        Set-ItemProperty -Path $TechPath -Name Attributes -Value "Hidden"
        
        $RegFile = "$env:TEMP\Registry.reg"
        Download-File "$RepoURL/Registry.reg" $RegFile
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s $RegFile" -Wait
        Remove-Item $RegFile
        
        $PowFile = "$env:TEMP\Power.pow"
        Download-File "$RepoURL/Power.pow" $PowFile
        powercfg -import $PowFile 77777777-7777-7777-7777-777777777777
        powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
        Remove-Item $PowFile
    } catch { Write-Host "Aviso na aplicação de Tweaks." -ForegroundColor DarkGray }

    Stop-Process -Name explorer -Force
    Write-Host "Otimizações Aplicadas!" -ForegroundColor Green
    Pause
}

function Run-Activator {
    Write-Host "[-] Abrindo MAS..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
}

do {
    Show-Menu
    $input = Read-Host " Digite sua opção"
    switch ($input) {
        '1' { Install-Essentials }
        '2' { Install-Office }
        '3' { Apply-Tweaks }
        '4' { Run-Activator }
        '0' { Write-Host "Saindo..."; exit }
        default { Write-Host "Opção Inválida"; Start-Sleep -Seconds 1 }
    }
} while ($true)

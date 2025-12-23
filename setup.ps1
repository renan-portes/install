<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.2 (Winget Dependencies Fix)
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

function Install-Essentials {
    Write-Host "[-] Verificando ambiente..." -ForegroundColor Yellow
    
    # Verifica se o Winget já funciona
    $wingetReady = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetReady = $true }
    
    if (-not $wingetReady) {
        Write-Host "Winget não detectado. Instalando dependências críticas..." -ForegroundColor Cyan
        
        # 1. VCLibs (Necessário para C++ UWP)
        try {
            Write-Host " -> [1/4] Instalando VCLibs..."
            $vclibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
            $vclibsPath = "$env:TEMP\vclibs.appx"
            Invoke-WebRequest -Uri $vclibsUrl -OutFile $vclibsPath
            Add-AppxPackage -Path $vclibsPath -ErrorAction SilentlyContinue
        } catch { Write-Host "    (Pulo: VCLibs ok ou erro ignorável)" -ForegroundColor DarkGray }

        # 2. Windows App SDK (A correção do erro 0x80073CF3)
        try {
            Write-Host " -> [2/4] Instalando Windows App SDK (Runtime)..."
            # Baixa o instalador oficial do Runtime mais recente (1.6+)
            $waSdkUrl = "https://aka.ms/windowsappsdk/1.6/windowsappruntimeinstall-x64.exe"
            $waSdkPath = "$env:TEMP\AppRuntime.exe"
            Invoke-WebRequest -Uri $waSdkUrl -OutFile $waSdkPath
            # Instala silenciosamente
            Start-Process -FilePath $waSdkPath -ArgumentList "--quiet" -Wait -NoNewWindow
        } catch { Write-Host "    (Erro ao instalar App SDK. O Winget pode falhar.)" -ForegroundColor Red }

        # 3. UI.Xaml (Necessário para a interface)
        try {
            Write-Host " -> [3/4] Instalando UI.Xaml 2.8..."
            $xamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx"
            $xamlPath = "$env:TEMP\xaml.appx"
            Invoke-WebRequest -Uri $xamlUrl -OutFile $xamlPath
            Add-AppxPackage -Path $xamlPath -ErrorAction SilentlyContinue
        } catch { Write-Host "    (Pulo: UI.Xaml erro ignorável)" -ForegroundColor DarkGray }

        # 4. Winget (DesktopAppInstaller)
        Write-Host " -> [4/4] Instalando Winget..."
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        
        try {
            Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
            # ErrorAction Stop garante que caia no catch se falhar
            Add-AppxPackage -Path $wingetPath -ErrorAction Stop
            Write-Host "Winget instalado com sucesso!" -ForegroundColor Green
            $wingetReady = $true
        } catch {
            Write-Host "ERRO FATAL: Não foi possível instalar o Winget." -ForegroundColor Red
            Write-Host "O erro anterior (dependência) provavelmente não foi resolvido." -ForegroundColor Yellow
            Write-Host "Tente rodar o Windows Update antes de usar o script." -ForegroundColor Yellow
            Pause; return
        }
    }

    # Garante o caminho do executável
    $wingetCmd = "winget"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    }

    if (-not (Test-Path $wingetCmd) -and -not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "ERRO: Executável do Winget não encontrado mesmo após instalação." -ForegroundColor Red
        Pause; return
    }

    Write-Host "[-] Iniciando instalação de programas..." -ForegroundColor Yellow
    $apps = @{
        "Google Chrome" = "Google.Chrome"
        "Adobe Reader"  = "Adobe.Acrobat.Reader.64-bit"
        "WinRAR"        = "RARLab.WinRAR"
        "AnyDesk"       = "AnyDeskSoftwareGmbH.AnyDesk"
    }

    foreach ($app in $apps.GetEnumerator()) {
        Write-Host "Instalando $($app.Key)..." -ForegroundColor Cyan
        try {
            # Executa o Winget. Se falhar, avisa.
            $proc = Start-Process -FilePath $wingetCmd -ArgumentList "install --id $($app.Value) -e --silent --accept-package-agreements --accept-source-agreements" -PassThru -Wait -NoNewWindow
        } catch {
            Write-Host "Erro ao tentar instalar $($app.Key)." -ForegroundColor Red
        }
    }
    Write-Host "Fim da instalação de programas!" -ForegroundColor Green
    Pause
}

function Install-Office {
    Write-Host "[-] Preparando instalação do Office 2024..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    # Usa setup.exe hospedado no GitHub (Conforme versão 3.0)
    Write-Host "Baixando Instalador (setup.exe)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/setup.exe" -OutFile "$OfficeTemp\setup.exe"
    } catch {
        Write-Host "ERRO: setup.exe não encontrado no GitHub." -ForegroundColor Red
        Pause; return
    }

    Write-Host "Baixando Configuração (config.xml)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml." -ForegroundColor Red; Pause; return
    }

    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host "Iniciando instalação (Aguarde o logo do Office)..." -ForegroundColor Cyan
        try {
            Start-Process -FilePath "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
            Write-Host "Office Instalado com Sucesso!" -ForegroundColor Green
        } catch {
            Write-Host "Erro ao rodar o instalador." -ForegroundColor Red
        }
    } else {
        Write-Host "Erro: Arquivo setup.exe inválido." -ForegroundColor Red
    }
    
    Remove-Item -Path $OfficeTemp -Recurse -Force -ErrorAction SilentlyContinue
    
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
        Invoke-WebRequest -Uri "$RepoURL/logo-win.bmp" -OutFile "$TechPath\logo-win.bmp"
        Set-ItemProperty -Path $TechPath -Name Attributes -Value "Hidden"
        
        $RegFile = "$env:TEMP\Registry.reg"
        Invoke-WebRequest -Uri "$RepoURL/Registry.reg" -OutFile $RegFile
        Start-Process -FilePath "regedit.exe" -ArgumentList "/s $RegFile" -Wait
        Remove-Item $RegFile
        
        $PowFile = "$env:TEMP\Power.pow"
        Invoke-WebRequest -Uri "$RepoURL/Power.pow" -OutFile $PowFile
        powercfg -import $PowFile 77777777-7777-7777-7777-777777777777
        powercfg -SETACTIVE "77777777-7777-7777-7777-777777777777"
        Remove-Item $PowFile
    } catch { Write-Host "Aviso: Falha ao baixar arquivos auxiliares." -ForegroundColor DarkGray }

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

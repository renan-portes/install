<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.4 (Stable Links + Legacy Full)
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

# Função auxiliar para download seguro
function Download-File {
    param ($Url, $Path)
    # Tenta usar curl (mais robusto para links diretos)
    try {
        $proc = Start-Process "curl.exe" -ArgumentList "-L", "-o", "$Path", "$Url" -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -ne 0) { throw "Curl error" }
    } catch {
        # Fallback para Invoke-WebRequest
        Invoke-WebRequest -Uri $Url -OutFile $Path
    }
}

function Install-Essentials {
    Write-Host "[-] Verificando ambiente..." -ForegroundColor Yellow
    
    $wingetReady = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetReady = $true }
    
    if (-not $wingetReady) {
        Write-Host "Winget não detectado. Instalando dependências (Links Diretos)..." -ForegroundColor Cyan
        
        # 1. VCLibs (Link direto do servidor MS)
        Write-Host " -> [1/4] VCLibs..."
        $vclibsPath = "$env:TEMP\vclibs.appx"
        Download-File "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" $vclibsPath
        Add-AppxPackage -Path $vclibsPath -ErrorAction SilentlyContinue

        # 2. Windows App SDK (CORREÇÃO: Link do GitHub Releases em vez de aka.ms)
        Write-Host " -> [2/4] Windows App SDK Runtime..."
        $waSdkPath = "$env:TEMP\AppRuntime.exe"
        # Link direto da versão 1.6.3 (Estável)
        Download-File "https://github.com/microsoft/WindowsAppSDK/releases/download/v1.6.3/windowsappruntimeinstall-x64.exe" $waSdkPath
        
        # Verifica tamanho (>1MB) para garantir que não é erro
        if ((Get-Item $waSdkPath).Length -gt 1000000) {
            Start-Process -FilePath $waSdkPath -ArgumentList "--quiet" -Wait -NoNewWindow
        } else {
            Write-Host "    Erro: Download do App SDK falhou (arquivo pequeno)." -ForegroundColor Red
        }

        # 3. UI.Xaml (Link Github)
        Write-Host " -> [3/4] UI.Xaml 2.8..."
        $xamlPath = "$env:TEMP\xaml.appx"
        Download-File "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" $xamlPath
        Add-AppxPackage -Path $xamlPath -ErrorAction SilentlyContinue

        # 4. Winget Core (Link Github)
        Write-Host " -> [4/4] Winget Installer..."
        $wingetPath = "$env:TEMP\winget.msixbundle"
        Download-File "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" $wingetPath
        
        try {
            Add-AppxPackage -Path $wingetPath -ErrorAction Stop
            Write-Host "Winget instalado com sucesso!" -ForegroundColor Green
            $wingetReady = $true
        } catch {
            Write-Host "AVISO: Falha ao registrar Winget. Ativando MODO LEGACY..." -ForegroundColor Yellow
            Start-Sleep 2
        }
    }

    # Definição do comando
    $wingetCmd = "winget"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    }

    Write-Host "[-] Iniciando instalação de programas..." -ForegroundColor Yellow
    
    # Tenta usar Winget
    if ((Test-Path $wingetCmd) -or (Get-Command winget -ErrorAction SilentlyContinue)) {
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
            } catch { Write-Host "Erro Winget em $($app.Key). Tentando legado..." -ForegroundColor Red }
        }
    } else {
        # --- MODO LEGACY (Instalação Direta sem Winget) ---
        Write-Host ">>> MODO LEGACY ATIVADO (Baixando .exe diretos) <<<" -ForegroundColor Magenta
        
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
        } else { Write-Host "Erro download WinRAR" -ForegroundColor Red }

        # AnyDesk
        Write-Host "Instalando AnyDesk..."
        $anyPath = "$env:TEMP\AnyDesk.exe"
        Download-File "https://download.anydesk.com/AnyDesk.exe" $anyPath
        Start-Process -FilePath $anyPath -ArgumentList "--install `"$env:ProgramFiles(x86)\AnyDesk`" --start-with-win --silent" -Wait

        # Adobe Reader (Link FTP oficial)
        Write-Host "Instalando Adobe Reader (Isso demora)..."
        $readerPath = "$env:TEMP\reader.exe"
        Download-File "https://ardownload2.adobe.com/pub/adobe/reader/win/AcrobatDC/2400220191/AcroRdrDC2400220191_pt_BR.exe" $readerPath
        if ((Get-Item $readerPath).Length -gt 1000000) {
            Start-Process -FilePath $readerPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait
        } else { Write-Host "Erro download Reader" -ForegroundColor Red }
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

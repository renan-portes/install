<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.7 (Adobe Latest - Fake Browser Header)
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

# Função de Download "Camuflado" (Engana os servidores da Adobe/MS)
function Download-File {
    param ($Url, $Path, $FakeReferer = $null)
    
    # Argumentos base do Curl
    $args = @("-L", "-o", "$Path", "$Url", "--ssl-no-revoke")
    
    # Adiciona User-Agent de navegador real
    $args += "-A"
    $args += "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    
    # Se precisar de Referer (Caso da Adobe)
    if ($FakeReferer) {
        $args += "-H"
        $args += "Referer: $FakeReferer"
    }

    try {
        $proc = Start-Process "curl.exe" -ArgumentList $args -NoNewWindow -Wait -PassThru
        if ($proc.ExitCode -ne 0) { throw "Erro no Curl" }
    } catch {
        # Fallback simples
        Invoke-WebRequest -Uri $Url -OutFile $Path
    }
}

function Install-Essentials {
    Write-Host "[-] Verificando ambiente..." -ForegroundColor Yellow
    
    $wingetReady = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetReady = $true }
    
    # Tenta consertar Winget se não existir
    if (-not $wingetReady) {
        Write-Host "Winget não detectado. Baixando dependências (GitHub Direct)..." -ForegroundColor Cyan
        $temp = $env:TEMP
        
        # 1. VCLibs (Link Direto)
        Download-File "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" "$temp\vclibs.appx"
        Add-AppxPackage "$temp\vclibs.appx" -ErrorAction SilentlyContinue

        # 2. Windows App SDK 1.6 (Link Direto GitHub - Sem aka.ms para evitar bloqueio)
        Write-Host " -> Instalando App SDK..."
        Download-File "https://github.com/microsoft/WindowsAppSDK/releases/download/v1.6.3/windowsappruntimeinstall-x64.exe" "$temp\AppRuntime.exe"
        if ((Get-Item "$temp\AppRuntime.exe").Length -gt 1000000) {
            Start-Process -FilePath "$temp\AppRuntime.exe" -ArgumentList "--quiet" -Wait -NoNewWindow
        }

        # 3. UI.Xaml 2.8 (Link Direto GitHub)
        Download-File "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx" "$temp\xaml.appx"
        Add-AppxPackage "$temp\xaml.appx" -ErrorAction SilentlyContinue

        # 4. Winget Core (Link Direto GitHub)
        Download-File "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" "$temp\winget.msixbundle"
        
        try {
            Add-AppxPackage "$temp\winget.msixbundle" -ErrorAction Stop
            $wingetReady = $true
            Write-Host "Winget Ativado!" -ForegroundColor Green
        } catch {
            Write-Host "Aviso: Winget falhou. O script usará o método tradicional." -ForegroundColor Yellow
        }
    }

    # Define comando
    $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetCmd = "winget" }
    
    # Validação final do Winget
    if ($wingetReady -and (Test-Path $wingetCmd)) {
         try { Start-Process $wingetCmd -ArgumentList "--version" -NoNewWindow -Wait -ErrorAction Stop } 
         catch { $wingetReady = $false }
    } else { $wingetReady = $false }

    Write-Host "[-] Iniciando instalação de programas..." -ForegroundColor Yellow
    
    if ($wingetReady) {
        # --- MODO 1: VIA WINGET (Baixa sempre a última versão oficial) ---
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
        # --- MODO 2: LEGACY (Links Diretos Oficiais) ---
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
        if ((Get-Item $rarPath).Length -gt 1000000) { Start-Process -FilePath $rarPath -ArgumentList "/S" -Wait }

        # AnyDesk
        Write-Host "Instalando AnyDesk..."
        $anyPath = "$env:TEMP\AnyDesk.exe"
        Download-File "https://download.anydesk.com/AnyDesk.exe" $anyPath
        Start-Process -FilePath $anyPath -ArgumentList "--install `"$env:ProgramFiles(x86)\AnyDesk`" --start-with-win --silent" -Wait

        # Adobe Reader (WEB INSTALLER + FAKE HEADER)
        Write-Host "Instalando Adobe Reader (Web Installer)..."
        $readerPath = "$env:TEMP\reader_install.exe"
        
        # O Pulo do Gato: Simulamos que viemos do site da Adobe
        # Link oficial do instalador web
        $adobeUrl = "https://admdownload.adobe.com/bin/live/readerdc_pt_br_xa_crd_install.exe"
        
        # Baixa usando cabeçalho fake para evitar erro 196 bytes
        Download-File $adobeUrl $readerPath "https://get.adobe.com/br/reader/"
        
        if ((Get-Item $readerPath).Length -gt 500000) { 
            # Roda o instalador web silenciosamente (ele baixa a ultima versão sozinho)
            Start-Process -FilePath $readerPath -ArgumentList "/sAll /rs /msi EULA_ACCEPT=YES" -Wait
        } else { 
            Write-Host "ERRO: Adobe bloqueou o download." -ForegroundColor Red 
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
    
    # Baixa setup.exe do seu GitHub (Self-Hosted é obrigatório só pro Office)
    Write-Host "Baixando Instalador..."
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
        Write-Host "Erro: setup.exe inválido ou não encontrado no GitHub." -ForegroundColor Red
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

<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.1 (Dependency Fix)
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
    
    # 1. Tenta identificar se o Winget já funciona
    $wingetReady = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) { $wingetReady = $true }
    
    if (-not $wingetReady) {
        Write-Host "Winget não detectado. Iniciando instalação das dependências..." -ForegroundColor Cyan
        
        # --- PASSO A: Instalar VCLibs (Obrigatório para Win 10/11 limpo) ---
        try {
            Write-Host " -> Instalando VCLibs..."
            $vclibsUrl = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
            $vclibsPath = "$env:TEMP\vclibs.appx"
            Invoke-WebRequest -Uri $vclibsUrl -OutFile $vclibsPath
            Add-AppxPackage -Path $vclibsPath -ErrorAction SilentlyContinue
        } catch { Write-Host " (VCLibs já instalado ou erro ignorável)" -ForegroundColor DarkGray }

        # --- PASSO B: Instalar UI.Xaml (Obrigatório para versões novas do Winget) ---
        try {
            Write-Host " -> Instalando UI.Xaml..."
            # Link oficial da versão 2.7 (mais compatível)
            $xamlUrl = "https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx"
            $xamlPath = "$env:TEMP\xaml.appx"
            Invoke-WebRequest -Uri $xamlUrl -OutFile $xamlPath
            Add-AppxPackage -Path $xamlPath -ErrorAction SilentlyContinue
        } catch { Write-Host " (UI.Xaml erro ignorável)" -ForegroundColor DarkGray }

        # --- PASSO C: Instalar Winget ---
        Write-Host " -> Instalando Winget (App Installer)..."
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        
        try {
            Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
            Add-AppxPackage -Path $wingetPath
            Write-Host "Winget instalado com sucesso!" -ForegroundColor Green
            $wingetReady = $true
        } catch {
            Write-Host "ERRO: Não foi possível instalar o Winget." -ForegroundColor Red
            Write-Host "Dica: Atualize o Windows Update e tente novamente." -ForegroundColor Yellow
            Pause; return
        }
    }

    # 2. Define o comando de execução
    $wingetCmd = "winget"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        # Tenta achar no local padrão se não estiver no PATH
        $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
    }

    if (-not (Test-Path $wingetCmd) -and -not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "ERRO CRÍTICO: Executável do Winget não encontrado." -ForegroundColor Red
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
        # Reset do contador de erro para cada app
        $err = $null
        try {
            # Executa direto, tratando erro
            $proc = Start-Process -FilePath $wingetCmd -ArgumentList "install --id $($app.Value) -e --silent --accept-package-agreements --accept-source-agreements" -PassThru -Wait -NoNewWindow
            if ($proc.ExitCode -ne 0) { throw "ExitCode: $($proc.ExitCode)" }
        } catch {
            Write-Host "Erro ao instalar $($app.Key). O Winget pode estar atualizando as fontes." -ForegroundColor Red
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
    
    Write-Host "Baixando Instalador (setup.exe)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/setup.exe" -OutFile "$OfficeTemp\setup.exe"
    } catch {
        Write-Host "ERRO: setup.exe não encontrado no seu GitHub." -ForegroundColor Red
        Write-Host "Verifique se você fez o upload do arquivo." -ForegroundColor Yellow
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

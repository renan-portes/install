<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 3.0 (Self-Hosted Stable)
Contato: (44) 98827.9740
#>

# --- CONFIGURAÇÃO INICIAL ---
# Como seus arquivos estão no GitHub, vamos usar ele como fonte central confiável
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
    Write-Host "[-] Verificando gerenciador de pacotes (Winget)..." -ForegroundColor Yellow
    
    # Verifica e Instala Winget se necessário (Correção para PCs recém formatados)
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget não encontrado. Instalando..." -ForegroundColor Cyan
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        try {
            Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
            Add-AppxPackage -Path $wingetPath
            Write-Host "Winget instalado!" -ForegroundColor Green
        } catch {
            Write-Host "Erro: Falha ao instalar Winget. Atualize o Windows Update primeiro." -ForegroundColor Red
            Pause; return
        }
    }

    # Garante o caminho do executável
    $wingetCmd = "winget"
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        $wingetCmd = "$env:LOCALAPPDATA\Microsoft\WindowsApps\winget.exe"
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
        Invoke-Expression "& '$wingetCmd' install --id $($app.Value) -e --silent --accept-package-agreements --accept-source-agreements"
    }
    Write-Host "Instalação de programas concluída!" -ForegroundColor Green
    Pause
}

function Install-Office {
    Write-Host "[-] Preparando instalação do Office 2024..." -ForegroundColor Yellow
    
    $OfficeTemp = "C:\OfficeTemp"
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    # 1. Baixa o setup.exe DO SEU GITHUB (Solução Definitiva)
    Write-Host "Baixando Instalador (setup.exe)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/setup.exe" -OutFile "$OfficeTemp\setup.exe"
    } catch {
        Write-Host "ERRO: setup.exe não encontrado no seu GitHub." -ForegroundColor Red
        Write-Host "Ação necessária: Faça upload do arquivo 'setup.exe' para o repositório 'renan-portes/install'." -ForegroundColor Yellow
        Pause; return
    }

    # 2. Baixa o config.xml DO SEU GITHUB
    Write-Host "Baixando Configuração (config.xml)..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml." -ForegroundColor Red; Pause; return
    }

    # 3. Executa a instalação
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
    
    # Limpeza e Atalhos
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
    
    Write-Host "Baixando recursos do GitHub..."
    try {
        # Baixa tudo do seu repositório central
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
    } catch { Write-Host "Aviso: Algum arquivo auxiliar não foi encontrado no GitHub." -ForegroundColor DarkGray }

    Stop-Process -Name explorer -Force
    Write-Host "Otimizações Aplicadas!" -ForegroundColor Green
    Pause
}

function Run-Activator {
    Write-Host "[-] Abrindo MAS..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
}

# Loop do Menu
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

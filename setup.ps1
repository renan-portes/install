<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 2.4 (Direct Setup Fix)
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
    Write-Host "[-] Verificando gerenciador de pacotes (Winget)..." -ForegroundColor Yellow
    
    # 1. Instala Winget se necessário
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "Winget não encontrado. Baixando instalador..." -ForegroundColor Cyan
        $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        $wingetPath = "$env:TEMP\winget.msixbundle"
        try {
            Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath
            Add-AppxPackage -Path $wingetPath
            Write-Host "Winget instalado!" -ForegroundColor Green
        } catch {
            Write-Host "Erro: Não foi possível instalar o Winget. Prossiga atualizando o Windows." -ForegroundColor Red
            Pause; return
        }
    }

    # 2. Localiza o executável correto
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
    
    # --- CORREÇÃO: LINK DIRETO PARA O ENGINE (SEM EXTRAÇÃO) ---
    Write-Host "Baixando Motor de Instalação (Setup.exe)..."
    # Este link aponta direto para o executável do servidor de produção da MS
    $setupUrl = "https://officecdn.microsoft.com/pr/wsus/setup.exe"
    $setupPath = "$OfficeTemp\setup.exe"
    
    try {
        # Curl é mais robusto para downloads diretos
        Start-Process "curl.exe" -ArgumentList "-L", "-o", "$setupPath", "$setupUrl" -NoNewWindow -Wait
    } catch {
        Write-Host "Erro ao baixar setup.exe." -ForegroundColor Red; Pause; return
    }

    # Verifica se o arquivo é válido (> 3MB)
    if ((Get-Item $setupPath).Length -lt 3000000) {
        Write-Host "ERRO CRÍTICO: O arquivo baixado parece corrompido ou é apenas uma página web." -ForegroundColor Red
        Write-Host "Tamanho: $((Get-Item $setupPath).Length) bytes" -ForegroundColor Red
        Pause; return
    }

    # Baixa config.xml do GitHub
    Write-Host "Baixando configuração personalizada..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml." -ForegroundColor Red; Pause; return
    }

    # Instalação Direta
    Write-Host "Iniciando instalação (Aguarde o logo do Office)..." -ForegroundColor Cyan
    try {
        Start-Process -FilePath $setupPath -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
        Write-Host "Office Instalado com Sucesso!" -ForegroundColor Green
    } catch {
        Write-Host "Erro ao iniciar o instalador." -ForegroundColor Red
    }
    
    # Limpeza
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

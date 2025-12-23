<#
Script: Renan Portes Toolkit - Cloud Edition
Versão: 2.2 (Fix Download Office + Winget)
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
    # Remove pasta antiga se existir para evitar conflito
    if (Test-Path $OfficeTemp) { Remove-Item $OfficeTemp -Recurse -Force }
    New-Item -ItemType Directory -Force -Path $OfficeTemp | Out-Null
    
    # 1. Baixa o ODT com USER-AGENT (A correção principal)
    Write-Host "Baixando Ferramenta de Implantação (ODT)..."
    try {
        $odtUrl = "https://go.microsoft.com/fwlink/p/?LinkID=626065"
        # O UserAgent engana o servidor da MS para baixar o arquivo certo
        Invoke-WebRequest -Uri $odtUrl -OutFile "$OfficeTemp\odt.exe" -UserAgent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
    } catch {
        Write-Host "Erro de conexão ao baixar ODT." -ForegroundColor Red; Pause; return
    }

    # Verifica se o arquivo tem tamanho válido (> 2MB)
    $fileSize = (Get-Item "$OfficeTemp\odt.exe").Length
    if ($fileSize -lt 1000000) {
        Write-Host "Erro: O arquivo baixado está corrompido (tamanho inválido). Tente novamente." -ForegroundColor Red
        Pause; return
    }

    # 2. Extrai o setup.exe
    Write-Host "Extraindo arquivos de instalação..."
    Start-Sleep -Seconds 2 # Espera liberar o arquivo
    try {
        Start-Process -FilePath "$OfficeTemp\odt.exe" -ArgumentList "/quiet /extract:$OfficeTemp" -Wait
    } catch {
        Write-Host "Erro ao extrair. Verifique se o antivirus não bloqueou o odt.exe." -ForegroundColor Red; Pause; return
    }

    # 3. Baixa config.xml
    Write-Host "Baixando configuração personalizada..."
    try {
        Invoke-WebRequest -Uri "$RepoURL/config.xml" -OutFile "$OfficeTemp\config.xml"
    } catch {
        Write-Host "Erro ao baixar config.xml." -ForegroundColor Red; Pause; return
    }

    # 4. Instala
    if (Test-Path "$OfficeTemp\setup.exe") {
        Write-Host "Iniciando instalação (Aguarde o logo do Office)..." -ForegroundColor Cyan
        Start-Process -FilePath "$OfficeTemp\setup.exe" -ArgumentList "/configure $OfficeTemp\config.xml" -Wait
        Write-Host "Office Instalado com Sucesso!" -ForegroundColor Green
    } else {
        Write-Host "Erro: setup.exe não apareceu após a extração." -ForegroundColor Red
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

# ============================================================================
# WIN-TOOLKIT - MEU TÉCNICO ONLINE
# Criado por: Renan Portes
# Contato: (44) 98827-9740
# ============================================================================
#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "WIN-TOOLKIT - MEU TÉCNICO ONLINE"

# --- FUNÇÃO GLOBAL DE DOWNLOAD COM BARRA DE PROGRESSO ---
function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    
    function Show-Progress {
        param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10)
        $percent = $CurrentValue / $TotalValue
        $percentComplete = $percent * 100
        Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % "
    }

    try {
        $request = [System.Net.HttpWebRequest]::Create($URL)
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
            if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " Baixando $($File.Name):" -BarSize 20 }
        } while ($count -gt 0)
        Write-Host "" 
    }
    finally {
        if ($null -ne $reader) { $reader.Close() }
        if ($null -ne $writer) { $writer.Close() }
    }
}

# ============================================================================
# 1. SUBMENU: INSTALADOR DE PROGRAMAS / LAUNCHERS / DEPENDÊNCIAS
# ============================================================================
function Menu-Instalador {
    do {
        Clear-Host
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host "               INSTALADOR DE PROGRAMAS E JOGOS                " -ForegroundColor White
        Write-Host "==============================================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host " [1] Navegadores (Chrome, Brave, Firefox)"
        Write-Host " [2] Utilidades (WinRAR, AnyDesk, Adobe Reader, Notepad++)"
        Write-Host " [3] Launchers de Jogos (Steam, Epic, Riot, etc.)"
        Write-Host " [4] Dependências (C++ All-in-One e DirectX)"
        Write-Host " [0] VOLTAR AO MENU PRINCIPAL"
        Write-Host ""
        
        $subEscolha = Read-Host " Escolha uma categoria"

        switch ($subEscolha) {
            '1' { Write-Host "Instalando Navegadores..."; Pause } # Vamos rechear aqui
            '2' { Write-Host "Instalando Utilidades..."; Pause }  # Vamos rechear aqui
            '3' { Write-Host "Instalando Launchers..."; Pause }   # Vamos rechear aqui
            '4' { Write-Host "Instalando C++ e DirectX..."; Pause } # Aquela nossa função otimizada
            '0' { return } # O 'return' sai desse submenu e volta pra tela inicial
            default { Write-Host " Opção Inválida!" -ForegroundColor Red; Start-Sleep -Seconds 1 }
        }
    } while ($true)
}

# ============================================================================
# 2 A 5. FUNÇÕES PRINCIPAIS DE OTIMIZAÇÃO E SISTEMA
# ============================================================================

function Aplicar-Regedit {
    Clear-Host
    Write-Host "[-] Aplicando Otimizações de Registro..." -ForegroundColor Yellow
    # Aqui vamos colar o código filtrado da aba "Optimize" do arquivo 12 Registry.ps1
    Pause
}

function Aplicar-PowerPlan {
    Clear-Host
    Write-Host "[-] Instalando Ultimate Power Plan..." -ForegroundColor Yellow
    # Aqui vamos colar a lógica de energia do arquivo 9 Power Plan.ps1
    Pause
}

function Instalar-Office {
    Clear-Host
    Write-Host "[-] Iniciando Instalação do Office..." -ForegroundColor Yellow
    # Instalação do Office 2024
    Pause
}

function Ativar-Sistema {
    Clear-Host
    Write-Host "[-] Abrindo Ativador (MAS)..." -ForegroundColor Yellow
    irm https://get.activated.win | iex
}

# ============================================================================
# 6. FUNÇÃO DE CONTATO WHATSAPP
# ============================================================================
function Abrir-WhatsApp {
    Clear-Host
    Write-Host "[-] Abrindo WhatsApp de Renan Portes..." -ForegroundColor Green
    # O link já vai com uma mensagem pré-programada!
    $zapUrl = "https://wa.me/5544988279740?text=Ol%C3%A1%2C%20Renan!%20Estou%20usando%20o%20seu%20Toolkit%20e%20preciso%20de%20suporte."
    Start-Process $zapUrl
}

# ============================================================================
# MENU PRINCIPAL (A "Cara" do Script)
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
        '1' { Menu-Instalador }
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

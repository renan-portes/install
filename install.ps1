# Define o tamanho da janela
$FormWidth = 854
$FormHeight = 480

# Cria a janela
$Form = New-Object System.Windows.Forms.Form
$Form.Text = "POST INSTALL - RENAN PORTES"
$Form.Size = New-Object System.Drawing.Size($FormWidth, $FormHeight)
$Form.BackColor = [System.Drawing.Color]::FromArgb(33, 33, 33)  # Cor de fundo escura
$Form.StartPosition = "CenterScreen"

# Função para criar e configurar os controles de label e lista com CheckBoxes
function CriarControle($Parent, $Left, $Top, $Width, $Height, $Text, $FontColor) {
    $Label = New-Object System.Windows.Forms.Label
    $Label.Text = $Text
    $Label.AutoSize = $true
    $Label.ForeColor = [System.Drawing.Color]::FromArgb($FontColor.R, $FontColor.G, $FontColor.B)  # Corrigido
    $Label.Location = New-Object System.Drawing.Point($Left, $Top)
    $Label.Size = New-Object System.Drawing.Size($Width, $Height)
    $Parent.Controls.Add($Label)
    return $Label
}

# Função para criar e configurar os controles de lista com CheckBoxes
function CriarListaCheckBox($Parent, $Left, $Top, $Width, $Height) {
    $ListBox = New-Object System.Windows.Forms.CheckedListBox
    $ListBox.Location = New-Object System.Drawing.Point($Left, $Top)
    $ListBox.Size = New-Object System.Drawing.Size($Width, $Height)
    $ListBox.CheckOnClick = $true  # Para que os itens sejam marcados/desmarcados clicando neles
    $Parent.Controls.Add($ListBox)
    return $ListBox
}

# Criando os controles e listas com CheckBoxes
$ProgramasPadraoLabel = CriarControle $Form 20 20 150 20 "Programas Padrão" ([System.Drawing.Color]::White)
$ProgramasPadraoLista = CriarListaCheckBox $Form 20 50 200 200

$MicrosoftOfficeLabel = CriarControle $Form 300 20 150 20 "Microsoft Office" ([System.Drawing.Color]::White)
$MicrosoftOfficeLista = CriarListaCheckBox $Form 300 50 200 200

$OutrosLabel = CriarControle $Form 580 20 150 20 "Outros" ([System.Drawing.Color]::White)
$OutrosLista = CriarListaCheckBox $Form 580 50 200 100

# Adicionando os programas às listas
$ProgramasPadraoLista.Items.AddRange(@(
    "Google Chrome", 
    "Mozilla Firefox", 
    "Adobe Reader DC", 
    "WinRAR", 
    "7-Zip", 
    "Steam", 
    "EA App", 
    "Epic Games Store", 
    "Google Drive", 
    "Microsoft OneDrive",
    "AnyDesk",  # Adicionado
    "TeamViewer"  # Adicionado
))

$MicrosoftOfficeLista.Items.AddRange(@(
    "Office 2019", 
    "Office 2021", 
    "Office 365 x64", 
    "Office 365 x86"
))

$OutrosLista.Items.AddRange(@(
    "Ativador Windows/Office", 
    "Otimizar Windows"
))

# Configurando ação do botão de instalar
$InstalarButton = New-Object System.Windows.Forms.Button
$InstalarButton.Text = "Instalar"
$InstalarButton.Size = New-Object System.Drawing.Size(100, 30)
$InstalarButton.ForeColor = [System.Drawing.Color]::White  # Cor branca
$InstalarButton.Add_Click({
    $ProgramasSelecionados = $ProgramasPadraoLista.CheckedItems
    $OfficeSelecionados = $MicrosoftOfficeLista.CheckedItems
    $OutrosSelecionados = $OutrosLista.CheckedItems

    # Lógica para lidar com os programas selecionados
    foreach ($programa in $ProgramasSelecionados) {
        $programaId = @{
            "Google Chrome" = "Google.Chrome"
            "Mozilla Firefox" = "Mozilla.Firefox"
            "Adobe Reader DC" = "Adobe.Acrobat.Reader.64-bit"
            "WinRAR" = "RARLab.WinRAR"
            "7-Zip" = "7zip.7zip"
            "Steam" = "Valve.Steam"
            "EA App" = "ElectronicArts.EADesktop"
            "Epic Games Store" = "EpicGames.EpicGamesLauncher"
            "Google Drive" = "Google.Drive"
            "Microsoft OneDrive" = "Microsoft.OneDrive"
            "AnyDesk" = "AnyDeskSoftwareGmbH.AnyDesk"  # Adicionado
            "TeamViewer" = "TeamViewer.TeamViewer"  # Adicionado
        }[$programa]

        if ($programaId) {
            Write-Host "Instalando $programa"
            Invoke-Expression "winget install -e --id $programaId"
        }
        else {
            Write-Host "ID não encontrada para $programa"
        }
    }

    # Lógica para lidar com os programas do Microsoft Office selecionados
    foreach ($office in $OfficeSelecionados) {
        Write-Host "Instalando $office"

        # Lógica de instalação para os diferentes tipos de Office
        switch ($office) {
            "Office 2019" {
                irm https://raw.githubusercontent.com/renan-portes/install/main/office/2019.ps1 | iex
            }
            "Office 2021" {
                irm https://raw.githubusercontent.com/renan-portes/install/main/office/2021.ps1 | iex
            }
            "Office 365 x64" {
                irm https://raw.githubusercontent.com/renan-portes/install/main/office/365-x64.ps1 | iex
            }
            "Office 365 x86" {
                irm https://raw.githubusercontent.com/renan-portes/install/main/office/365-x86.ps1 | iex
            }
        }
    }

    # Lógica para lidar com outros programas selecionados
    foreach ($outro in $OutrosSelecionados) {
        Write-Host "Executando $outro"
        # Lógica para os outros programas
        switch ($outro) {
            "Ativador Windows/Office" {
                irm massgrave.dev/get | iex
            }
            "Otimizar Windows" {
                irm https://raw.githubusercontent.com/renan-portes/install/main/_files/registry.ps1 | iex
            }
        }
    }

    Write-Host "Instalação concluída."
})

# Movendo o botão para a posição anterior
$InstalarButton.Location = New-Object System.Drawing.Point(50, 350)
$Form.Controls.Add($InstalarButton)

# Adicionando o texto centralizado e abaixo da janela
$TextoDireita = @"
Script criado por Renan Portes
   Contato (44) 98827-9740
Última Atualização 01/02/2024



       WHATSAPP(clique)
"@

$TextoDireitaLabel = CriarControle $Form 315 300 300 100 $TextoDireita ([System.Drawing.Color]::White)

# Adicionando um evento Click ao LinkLabel para abrir o navegador com o link
$TextoDireitaLabel.Add_Click({
    [System.Diagnostics.Process]::Start("https://wa.me/5544988279740")
})

# Exibe a janela
$Form.ShowDialog()

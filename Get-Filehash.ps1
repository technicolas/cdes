# Commande de base:
# -----------------
# (Get-FileHash .\AlmaLinux-10.2-x86_64-Live-KDE.iso -Algorithm SHA256).Hash -eq "ff3f9c16614abeb672415ba45aaceb358b7765e327961a80ddf69e7c7c3bdf2a"
# Résultat obtenu: True

# Script permettant de vérifier l'intégrité d'un fichier ISO via SHA256:
# ----------------------------------------------------------------------

Clear-Host

Write-Host "===================================" -ForegroundColor Blue
Write-Host "Vérification hash file ISO (SHA256)" -ForegroundColor Blue
Write-Host "===================================" -ForegroundColor Blue
Write-Host ""

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
 
# Fenêtre principale
$form = New-Object System.Windows.Forms.Form
$form.Text = "Vérification hash file ISO (SHA256)"
$form.Size = New-Object System.Drawing.Size(700, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
 
# Label fichier
$lblFile = New-Object System.Windows.Forms.Label
$lblFile.Location = New-Object System.Drawing.Point(10, 20)
$lblFile.Size = New-Object System.Drawing.Size(120, 20)
$lblFile.Text = "Fichier ISO :"
$form.Controls.Add($lblFile)

# Zone chemin
$txtFile = New-Object System.Windows.Forms.TextBox
$txtFile.Location = New-Object System.Drawing.Point(130, 18)
$txtFile.Size = New-Object System.Drawing.Size(450, 20)
$form.Controls.Add($txtFile)

# Bouton Parcourir
$btnBrowse = New-Object System.Windows.Forms.Button
$btnBrowse.Location = New-Object System.Drawing.Point(590, 16)
$btnBrowse.Size = New-Object System.Drawing.Size(80, 25)
$btnBrowse.Text = "Parcourir"
$form.Controls.Add($btnBrowse)

# Label Hash
$lblHash = New-Object System.Windows.Forms.Label
$lblHash.Location = New-Object System.Drawing.Point(10, 70)
$lblHash.Size = New-Object System.Drawing.Size(120, 20)
$lblHash.Text = "Hash attendu :"
$form.Controls.Add($lblHash)

# Zone Hash
$txtHash = New-Object System.Windows.Forms.TextBox
$txtHash.Location = New-Object System.Drawing.Point(130, 68)
$txtHash.Size = New-Object System.Drawing.Size(540, 20)
$form.Controls.Add($txtHash)

# Bouton Vérifier
$btnVerify = New-Object System.Windows.Forms.Button
$btnVerify.Location = New-Object System.Drawing.Point(285, 110)
$btnVerify.Size = New-Object System.Drawing.Size(110, 35)
$btnVerify.Text = "Test"
$form.Controls.Add($btnVerify)

# Zone résultat
$lblResult = New-Object System.Windows.Forms.Label
$lblResult.Location = New-Object System.Drawing.Point(10, 170)
$lblResult.Size = New-Object System.Drawing.Size(660, 60)
$lblResult.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($lblResult)

# Dialogue de sélection
$btnBrowse.Add_Click({
        $Dialog = New-Object System.Windows.Forms.OpenFileDialog
        $Dialog.Filter = "Fichiers ISO (*.iso)|*.iso|Tous les fichiers (*.*)|*.*"
        $Dialog.Title = "Sélectionnez un fichier ISO"
        if ($Dialog.ShowDialog() -eq "OK") {
            $txtFile.Text = $Dialog.FileName
        }
    })

# Vérification
$btnVerify.Add_Click({
        $lblResult.Text = ""

    if (-not $txtFile.Text.Trim()) {
        [System.Windows.Forms.MessageBox]::Show(
            "Veuillez sélectionner un fichier.",
            "Information",
            "OK",
            "Information"
        )
        return
    }

    if (-not (Test-Path $txtFile.Text)) {
        [System.Windows.Forms.MessageBox]::Show(
            "Le fichier sélectionné n'existe pas.",
            "Erreur",
            "OK",
            "Error"
        )
        return
    }

    if (-not $txtHash.Text.Trim()) {
        [System.Windows.Forms.MessageBox]::Show(
            "Veuillez saisir le hash attendu.",
            "Information",
            "OK",
            "Information"
        )
        return
    }

    try {
        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
        $ExpectedHash = $txtHash.Text.Trim().ToUpper()
        $ActualHash = (Get-FileHash $txtFile.Text -Algorithm SHA256).Hash.ToUpper()

        if ($ExpectedHash -eq $ActualHash) {
            $lblResult.ForeColor = "Green"
            $lblResult.Text = @"
                FICHIER VALIDE ;-)
                Le hash calculé correspond exactement au hash attendu.
                L'intégrité du fichier est confirmée.
"@
            Write-Host "File OK" -ForegroundColor Green
        }
        else {
            $lblResult.ForeColor = "Red"
            $lblResult.Text = @"
            ATTENTION
            Le hash calculé ne correspond PAS au hash attendu...
            Le fichier peut être corrompu, incomplet ou avoir été modifié par un malappris. :-(
"@
            Write-Host "File NOK" -ForegroundColor Red
        [System.Windows.Forms.MessageBox]::Show(
            "Le hash ne correspond pas.",
            "Alerte",
            "OK",
            "Warning"
        )
    }
}
    catch {
        [System.Windows.Forms.MessageBox]::Show(
            $_.Exception.Message,
            "Erreur",
            "OK",
            "Error"
        )
    }
    finally {
        $form.Cursor = [System.Windows.Forms.Cursors]::Default
    }
})
[void]$form.ShowDialog()
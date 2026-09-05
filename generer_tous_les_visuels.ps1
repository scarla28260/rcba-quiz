Add-Type -AssemblyName System.Drawing

# Repertoires
$assetsDir = Join-Path $PSScriptRoot "assets"
$outputDir = Join-Path $PSScriptRoot "visuels_quiz"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$fondPath = Join-Path $assetsDir "fond_clean.png"
if (-not (Test-Path $fondPath)) {
    $fondPath = Join-Path $assetsDir "fond_modele.png"
}
if (-not (Test-Path $fondPath)) {
    Write-Error "Fichier fond introuvable."
    exit 1
}

$jsonPath = Join-Path $PSScriptRoot "quiz_data.json"
if (-not (Test-Path $jsonPath)) {
    Write-Error "Fichier quiz_data.json introuvable."
    exit 1
}

# Chargement des donnees JSON en UTF-8
$jsonContent = [System.IO.File]::ReadAllText($jsonPath, [System.Text.Encoding]::UTF8)
$quizData = $jsonContent | ConvertFrom-Json

# Fonction pour decouper le texte en lignes selon la largeur max
function Wrap-Text($text, [System.Drawing.Font]$font, [int]$maxWidth, [System.Drawing.Graphics]$g) {
    # Nettoyage des espaces orphelins devant la ponctuation
    $cleanText = $text -replace '\s+([!?:;])', '$1'
    $words = $cleanText -split '\s+'
    $lines = New-Object System.Collections.ArrayList
    $currentLine = ""

    foreach ($word in $words) {
        $testLine = if ($currentLine -eq "") { $word } else { "$currentLine $word" }
        $size = $g.MeasureString($testLine, $font)
        if ($size.Width -gt $maxWidth) {
            if ($currentLine -ne "") {
                [void]$lines.Add($currentLine)
            }
            $currentLine = $word
        } else {
            $currentLine = $testLine
        }
    }
    if ($currentLine -ne "") {
        [void]$lines.Add($currentLine)
    }
    return $lines
}

# Fonction de rendu d'un rectangle arrondi
function Draw-RoundedRectangle([System.Drawing.Graphics]$g, [System.Drawing.Brush]$brush, [System.Drawing.Pen]$pen, [float]$x, [float]$y, [float]$width, [float]$height, [float]$radius) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2

    [void]$path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    [void]$path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
    [void]$path.AddArc($x + $width - $diameter, $y + $height - $diameter, $diameter, $diameter, 0, 90)
    [void]$path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()

    if ($brush -ne $null) {
        $g.FillPath($brush, $path)
    }
    if ($pen -ne $null) {
        $g.DrawPath($pen, $path)
    }
    $path.Dispose()
}

Write-Host "Chargement du fond officiel RCBA..." -ForegroundColor Cyan
$imgBase = [System.Drawing.Image]::FromFile($fondPath)

# Dimensions cibles HD : 1080 x 1336 px (ratio 4:5 officiel)
$targetW = 1080
$targetH = [int]($imgBase.Height * ($targetW / $imgBase.Width))
$scaleX = $targetW / $imgBase.Width
$scaleY = $targetH / $imgBase.Height

# Typographies
$fontTitle = New-Object System.Drawing.Font "Arial", 28, ([System.Drawing.FontStyle]::Bold)
$fontSub = New-Object System.Drawing.Font "Arial", 16, ([System.Drawing.FontStyle]::Bold)
$fontTheme = New-Object System.Drawing.Font "Arial", 13, ([System.Drawing.FontStyle]::Bold)
$fontQuestion = New-Object System.Drawing.Font "Arial", 18, ([System.Drawing.FontStyle]::Bold)
$fontOption = New-Object System.Drawing.Font "Arial", 16, ([System.Drawing.FontStyle]::Bold)
$fontBadge = New-Object System.Drawing.Font "Arial", 14, ([System.Drawing.FontStyle]::Bold)
$fontCalloutTitle = New-Object System.Drawing.Font "Arial", 12, ([System.Drawing.FontStyle]::Bold)
$fontCalloutBody = New-Object System.Drawing.Font "Arial", 13, ([System.Drawing.FontStyle]::Regular)

# Palette de couleurs RCBA
$cWhite = [System.Drawing.Color]::White
$cGold = [System.Drawing.Color]::FromArgb(245, 158, 11)
$cSky = [System.Drawing.Color]::FromArgb(56, 189, 248)
$cRacing = [System.Drawing.Color]::FromArgb(28, 100, 242)
$cEmerald = [System.Drawing.Color]::FromArgb(16, 185, 129)
$cDarkNavy = [System.Drawing.Color]::FromArgb(255, 7, 12, 26) # 100% Opaque

$brushWhite = New-Object System.Drawing.SolidBrush $cWhite
$brushGold = New-Object System.Drawing.SolidBrush $cGold
$brushSky = New-Object System.Drawing.SolidBrush $cSky
$brushRacing = New-Object System.Drawing.SolidBrush $cRacing
$brushEmerald = New-Object System.Drawing.SolidBrush $cEmerald
$brushDarkCard = New-Object System.Drawing.SolidBrush $cDarkNavy
$brushDim = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(140, 255, 255, 255))
$brushLightSlate = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(226, 232, 240))

$penCyanBorder = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(200, 56, 189, 248)), 3
$penEmeraldBorder = New-Object System.Drawing.Pen ($cEmerald), 4
$penNormalOption = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(60, 255, 255, 255)), 2

Write-Host "Generation des 11 visuels Questions + 11 visuels Reponses en haute definition..." -ForegroundColor Yellow

$checkChar = [char]0x2713

foreach ($q in $quizData) {
    foreach ($mode in @("question", "reponse")) {
        $bmp = New-Object System.Drawing.Bitmap $targetW, $targetH
        $g = [System.Drawing.Graphics]::FromImage($bmp)
        $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

        # 1. Dessin du fond officiel RCBA
        $g.DrawImage($imgBase, 0, 0, $targetW, $targetH)

        # 2. Zone Titre Haut (Masquage 100% opaque couvrant RCBA MATCHWEEK et la date)
        $headerX = 75
        $headerY = [int](120 * $scaleY)
        $headerW = $targetW - 150
        $headerH = [int](96 * $scaleY)

        $brushHeaderBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 9, 20))
        $penHeaderBorder = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 56, 189, 248)), 2
        Draw-RoundedRectangle $g $brushHeaderBg $penHeaderBorder $headerX $headerY $headerW $headerH 20
        $brushHeaderBg.Dispose()
        $penHeaderBorder.Dispose()

        # Tag Theme
        $themeStr = $q.theme.ToUpper()
        $themeSize = $g.MeasureString($themeStr, $fontTheme)
        $g.DrawString($themeStr, $fontTheme, $brushGold, ($targetW - $themeSize.Width) / 2, $headerY + 12)

        # Grand Titre Quiz
        $titleStr = "LE GRAND QUIZ DU RCBA"
        $titleSize = $g.MeasureString($titleStr, $fontTitle)
        $g.DrawString($titleStr, $fontTitle, $brushWhite, ($targetW - $titleSize.Width) / 2, $headerY + 36)

        # Numero Question
        $qNumStr = "QUESTION " + ("{0:D2}" -f [int]$q.id) + " / 11"
        $qNumSize = $g.MeasureString($qNumStr, $fontSub)
        $g.DrawString($qNumStr, $fontSub, $brushSky, ($targetW - $qNumSize.Width) / 2, $headerY + 84)

        # 3. Grande Carte Centrale (100% opaque, se termine parfaitement au dessus de FIERS DE NOS COULEURS !)
        $cardX = 75
        $cardY = [int](226 * $scaleY)
        $cardW = $targetW - 150
        $cardH = [int](270 * $scaleY)

        Draw-RoundedRectangle $g $brushDarkCard $penCyanBorder $cardX $cardY $cardW $cardH 24

        # Badge de la carte
        $badgeText = if ($mode -eq "question") { "QUESTION OFFICIELLE (1 POINT)" } else { "BONNE REPONSE : OPTION " + $q.answer }
        $badgeBrush = if ($mode -eq "question") { $brushGold } else { $brushEmerald }
        $g.DrawString($badgeText, $fontBadge, $badgeBrush, $cardX + 25, $cardY + 16)

        # Texte de la question
        $qLines = Wrap-Text $q.question $fontQuestion ($cardW - 50) $g
        $qCurY = $cardY + 44
        foreach ($line in $qLines) {
            $g.DrawString($line, $fontQuestion, $brushWhite, $cardX + 25, $qCurY)
            $qCurY += 26
        }

        # Ligne separatrice fine
        $penSep = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(60, 255, 255, 255)), 1
        $g.DrawLine($penSep, $cardX + 25, $qCurY + 8, $cardX + $cardW - 25, $qCurY + 8)
        $penSep.Dispose()

        # Options A, B, C
        $optionsY = $qCurY + 16
        $optH = 50
        $optSpacing = 10

        $options = @(
            @{ key = "A"; text = $q.optA; brush = $brushSky; color = $cRacing },
            @{ key = "B"; text = $q.optB; brush = $brushGold; color = $cGold },
            @{ key = "C"; text = $q.optC; brush = $brushEmerald; color = $cEmerald }
        )

        for ($i = 0; $i -lt 3; $i++) {
            $opt = $options[$i]
            $rowY = $optionsY + ($i * ($optH + $optSpacing))

            $isCorrect = ($opt.key -eq $q.answer)
            $rowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 15, 24, 48))
            $rowPen = $penNormalOption
            $textBrush = $brushWhite

            if ($mode -eq "reponse") {
                if ($isCorrect) {
                    $rowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 12, 65, 45))
                    $rowPen = $penEmeraldBorder
                    $textBrush = $brushWhite
                } else {
                    $rowBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 10, 16, 32))
                    $textBrush = $brushDim
                }
            }

            # Fond option
            Draw-RoundedRectangle $g $rowBrush $rowPen ($cardX + 25) $rowY ($cardW - 50) $optH 12
            $rowBrush.Dispose()

            # Pastille A, B, C
            $badgeX = $cardX + 38
            $badgeY = $rowY + 9
            $badgeBoxW = 32
            $badgeBoxH = 32

            $badgeBg = if ($mode -eq "reponse" -and $isCorrect) { $brushEmerald } else { New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 25, 38, 70)) }
            Draw-RoundedRectangle $g $badgeBg $null $badgeX $badgeY $badgeBoxW $badgeBoxH 8
            if ($mode -ne "reponse" -or -not $isCorrect) { $badgeBg.Dispose() }

            $badgeLetter = if ($mode -eq "reponse" -and $isCorrect) { "$checkChar" } else { $opt.key }
            $letterColor = if ($mode -eq "reponse" -and $isCorrect) { $brushWhite } else { $opt.brush }
            $g.DrawString($badgeLetter, $fontBadge, $letterColor, $badgeX + 8, $badgeY + 7)

            # Texte de l'option (avec troncature si necessaire)
            $g.DrawString($opt.text, $fontOption, $textBrush, $cardX + 85, $rowY + 14)
        }

        # Boite Callout Inferieure
        $calloutY = $optionsY + (3 * ($optH + $optSpacing)) + 14
        $calloutH = $cardY + $cardH - $calloutY - 16
        $calloutW = $cardW - 50
        $calloutX = $cardX + 25

        if ($mode -eq "question") {
            $calloutBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 12, 28, 56))
            $calloutPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(120, 56, 189, 248)), 1.5
            Draw-RoundedRectangle $g $calloutBg $calloutPen $calloutX $calloutY $calloutW $calloutH 12
            $calloutBg.Dispose()
            $calloutPen.Dispose()

            $g.DrawString("A VOS PRONOSTICS !", $fontCalloutTitle, $brushSky, $calloutX + 16, $calloutY + 10)
            $g.DrawString("Donnez votre reponse (A, B ou C) en commentaire !", $fontCalloutBody, $brushWhite, $calloutX + 16, $calloutY + 28)
            $g.DrawString("Mentionnez un coequipier pour tester ses connaissances !", $fontCalloutBody, $brushLightSlate, $calloutX + 16, $calloutY + 48)
        } else {
            $calloutBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 8, 42, 30))
            $calloutPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(140, 16, 185, 129)), 1.5
            Draw-RoundedRectangle $g $calloutBg $calloutPen $calloutX $calloutY $calloutW $calloutH 12
            $calloutBg.Dispose()
            $calloutPen.Dispose()

            $g.DrawString("LE SAVIEZ-VOUS ? (ANECDOTE DU CLUB)", $fontCalloutTitle, $brushEmerald, $calloutX + 16, $calloutY + 10)
            $explLines = Wrap-Text $q.explanation $fontCalloutBody ($calloutW - 32) $g
            $eY = $calloutY + 28
            foreach ($el in $explLines) {
                $g.DrawString($el, $fontCalloutBody, $brushWhite, $calloutX + 16, $eY)
                $eY += 20
            }
        }

        # Sauvegarde PNG HD
        $filename = "RCBA_Quiz_Q" + ("{0:D2}" -f [int]$q.id) + "_" + $mode + ".png"
        $filePath = Join-Path $outputDir $filename
        $bmp.Save($filePath, [System.Drawing.Imaging.ImageFormat]::Png)

        $g.Dispose()
        $bmp.Dispose()
    }
    Write-Host "  -> Question $($q.id) generee (question + reponse)" -ForegroundColor Green
}

# ==============================================================================
# 4. GENERATION DU VISUEL FINAL DE RESULTATS & PALMARES (SLIDE 12)
# ==============================================================================
Write-Host "Generation du visuel de Resultats & Palmares..." -ForegroundColor Cyan

$bmpRes = New-Object System.Drawing.Bitmap $targetW, $targetH
$gRes = [System.Drawing.Graphics]::FromImage($bmpRes)
$gRes.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$gRes.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$gRes.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# Fond officiel
$gRes.DrawImage($imgBase, 0, 0, $targetW, $targetH)

# En-tete
$headerX = 75
$headerY = [int](120 * $scaleY)
$headerW = $targetW - 150
$headerH = [int](96 * $scaleY)

$brushHeaderBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 9, 20))
$penHeaderBorder = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 56, 189, 248)), 2
Draw-RoundedRectangle $gRes $brushHeaderBg $penHeaderBorder $headerX $headerY $headerW $headerH 20
$brushHeaderBg.Dispose()
$penHeaderBorder.Dispose()

$themeStr = "PALMARES & CLOTURE DU GRAND QUIZ"
$themeSize = $gRes.MeasureString($themeStr, $fontTheme)
$gRes.DrawString($themeStr, $fontTheme, $brushGold, ($targetW - $themeSize.Width) / 2, $headerY + 12)

$titleStr = "LE GRAND QUIZ DU RCBA"
$titleSize = $gRes.MeasureString($titleStr, $fontTitle)
$gRes.DrawString($titleStr, $fontTitle, $brushWhite, ($targetW - $titleSize.Width) / 2, $headerY + 36)

$subStr = "QUEL EST VOTRE SCORE FINAL SUR 11 ?"
$subSize = $gRes.MeasureString($subStr, $fontSub)
$gRes.DrawString($subStr, $fontSub, $brushSky, ($targetW - $subSize.Width) / 2, $headerY + 84)

# Grande Carte Centrale
$cardX = 75
$cardY = [int](226 * $scaleY)
$cardW = $targetW - 150
$cardH = [int](250 * $scaleY)

Draw-RoundedRectangle $gRes $brushDarkCard $penCyanBorder $cardX $cardY $cardW $cardH 24

# Badge haut de la carte
$gRes.DrawString("BAREME OFFICIEL & CLASSEMENT DU CLUB", $fontBadge, $brushGold, $cardX + 25, $cardY + 14)
$gRes.DrawString("Decouvrez votre statut officiel au sein du Racing Club Bu Abondant :", $fontCalloutBody, $brushWhite, $cardX + 25, $cardY + 38)

# 4 Rangs / Paliers officiels
$tiers = @(
    @{ score = "10 - 11 PTS"; title = "LEGENDE DU RCBA"; desc = "Connaissance absolue du club ! Maillot d'or et respect eternel du vestiaire."; color = $cGold; border = ([System.Drawing.Color]::FromArgb(200, 245, 158, 11)) },
    @{ score = "7 - 9 PTS"; title = "TITULAIRE INDISCUTABLE"; desc = "Le sang bleu et blanc ! Tu connais parfaitement ton club et ses valeurs."; color = $cEmerald; border = ([System.Drawing.Color]::FromArgb(200, 16, 185, 129)) },
    @{ score = "4 - 6 PTS"; title = "SUPPORTER DU DIMANCHE"; desc = "Bon potentiel ! Un passage par la buvette s'impose pour reviser le club."; color = $cSky; border = ([System.Drawing.Color]::FromArgb(200, 56, 189, 248)) },
    @{ score = "0 - 3 PTS"; title = "NOUVELLE RECRUE"; desc = "Bienvenue dans la famille RCBA ! La prochaine tournee de frites est pour toi !"; color = ([System.Drawing.Color]::FromArgb(249, 115, 22)); border = ([System.Drawing.Color]::FromArgb(200, 249, 115, 22)) }
)

$tierStartY = $cardY + 66
$tierH = 52
$tierSpacing = 8
$fontTierTitle = New-Object System.Drawing.Font "Arial", 14, ([System.Drawing.FontStyle]::Bold)
$fontTierDesc = New-Object System.Drawing.Font "Arial", 11, ([System.Drawing.FontStyle]::Regular)

for ($i = 0; $i -lt 4; $i++) {
    $t = $tiers[$i]
    $tY = $tierStartY + ($i * ($tierH + $tierSpacing))

    $tBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 12, 20, 42))
    $tPen = New-Object System.Drawing.Pen ($t.border), 1.5
    Draw-RoundedRectangle $gRes $tBrush $tPen ($cardX + 25) $tY ($cardW - 50) $tierH 10
    $tBrush.Dispose()
    $tPen.Dispose()

    $scoreBrush = New-Object System.Drawing.SolidBrush $t.color
    $scoreBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 18, 30, 60))
    Draw-RoundedRectangle $gRes $scoreBg $null ($cardX + 35) ($tY + 8) 115 36 6
    $scoreBg.Dispose()

    $gRes.DrawString($t.score, $fontTierTitle, $scoreBrush, $cardX + 42, $tY + 16)
    $scoreBrush.Dispose()

    $tTitleBrush = New-Object System.Drawing.SolidBrush $t.color
    $gRes.DrawString($t.title, $fontTierTitle, $tTitleBrush, $cardX + 165, $tY + 9)
    $tTitleBrush.Dispose()

    $gRes.DrawString($t.desc, $fontTierDesc, $brushDim, $cardX + 165, $tY + 30)
}

# Boite Callout Inferieure parfaitement proportionnee
$calloutY = $tierStartY + (4 * ($tierH + $tierSpacing)) + 12
$calloutH = 80
$calloutW = $cardW - 50
$calloutX = $cardX + 25

$calloutBg = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 10, 24, 50))
$calloutPen = New-Object System.Drawing.Pen ([System.Drawing.Color]::FromArgb(160, 56, 189, 248)), 1.5
Draw-RoundedRectangle $gRes $calloutBg $calloutPen $calloutX $calloutY $calloutW $calloutH 12
$calloutBg.Dispose()
$calloutPen.Dispose()

$gRes.DrawString("A VOS COMMENTAIRES ! QUEL EST VOTRE SCORE SUR 11 ?", $fontCalloutTitle, $brushSky, $calloutX + 18, $calloutY + 11)
$gRes.DrawString("Ecrivez votre note (ex: 9/11) et votre statut officiel en commentaire !", $fontCalloutBody, $brushWhite, $calloutX + 18, $calloutY + 32)
$gRes.DrawString("Defiez vos coequipiers du RCBA pour voir qui connait le mieux le club !", $fontTierDesc, $brushDim, $calloutX + 18, $calloutY + 52)

# Sauvegarde visuel resultat
$resPath = Join-Path $outputDir "RCBA_Quiz_12_resultats.png"
$bmpRes.Save($resPath, [System.Drawing.Imaging.ImageFormat]::Png)

$gRes.Dispose()
$bmpRes.Dispose()
$fontTierTitle.Dispose()
$fontTierDesc.Dispose()

Write-Host "  -> Slide Resultats generee : RCBA_Quiz_12_resultats.png" -ForegroundColor Green

$imgBase.Dispose()

# Liberation polices et pinceaux
$fontTitle.Dispose()
$fontSub.Dispose()
$fontTheme.Dispose()
$fontQuestion.Dispose()
$fontOption.Dispose()
$fontBadge.Dispose()
$fontCalloutTitle.Dispose()
$fontCalloutBody.Dispose()

$brushWhite.Dispose()
$brushGold.Dispose()
$brushSky.Dispose()
$brushRacing.Dispose()
$brushEmerald.Dispose()
$brushDarkCard.Dispose()
$brushDim.Dispose()
$brushLightSlate.Dispose()

$penCyanBorder.Dispose()
$penEmeraldBorder.Dispose()
$penNormalOption.Dispose()

Write-Host "SUCCES ! 23 visuels HD (11 questions + 11 reponses + 1 palmares resultat) generes dans : $outputDir" -ForegroundColor Green

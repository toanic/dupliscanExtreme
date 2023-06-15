$Host.UI.RawUI.WindowTitle = "Windows Powershell " + $Host.Version;

function coloredOutput ($text1, $text2, $text3, [int] $scheme = 0) {
    if ($scheme -eq 0){
        Write-Host -ForegroundColor Green -NoNewline $text1
        Write-Host -ForegroundColor Cyan -NoNewline $text2
        Write-Host -ForegroundColor Green -NoNewline $text3
    }
    if ($scheme -eq 1){
        Write-Host -ForegroundColor Yellow -NoNewline $text1
        Write-Host -ForegroundColor Cyan -NoNewline $text2
        Write-Host -ForegroundColor Yellow -NoNewline $text3
    }    
    if ($scheme -eq 2){
        Write-Host -ForegroundColor Yellow -NoNewline $text1
        Write-Host -ForegroundColor Red -NoNewline $text2
        Write-Host -ForegroundColor Yellow -NoNewline $text3
    }
    if ($scheme -eq 3){
        Write-Host ""
        Write-Host -ForegroundColor Green -NoNewline $text1
        Write-Host -ForegroundColor Cyan -NoNewline $text2
        Write-Host -ForegroundColor Green -NoNewline $text3
    }
}

function errorHandling ([string]$errorMessage ){
    Write-Host ""
    Write-Host -ForegroundColor Red "[!] $errorMessage"
    Write-Host ""
}

if ([System.Environment]::OSVersion.Version.Major -lt 6) {
    errorHandling "Unsupported operating system"
    exit
}

if (-not (Test-Path -Path ".\VERSION")) {
    errorHandling "VERSION file not found"
    New-Item -Path ".\VERSION" -ItemType File -Force | Out-Null
    Add-Content -Path ".\VERSION" -Value "0.0.0" | Out-Null
}

$version = Get-Content -Path ".\VERSION"

if ((($version.GetType()).BaseType).Name -eq "Array"){
    Write-Host ""
    Write-Host -ForegroundColor White                  $version[1]
    Write-Host -ForegroundColor White       -NoNewLine $version[2].Substring(0, 13)
    Write-Host -ForegroundColor Cyan        -NoNewLine $version[2].Substring(13, 12)
    Write-Host -ForegroundColor DarkCyan               $version[2].Substring(25)
    Write-Host -ForegroundColor White       -NoNewLine $version[3].Substring(0, 14)
    Write-Host -ForegroundColor DarkGreen              $version[3].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[4].Substring(0, 14)
    Write-Host -ForegroundColor DarkGreen              $version[4].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[5].Substring(0, 14)
    Write-Host -ForegroundColor DarkMagenta            $version[5].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[6].Substring(0, 13)
    Write-Host -ForegroundColor DarkMagenta            $version[6].Substring(13)
    Write-Host ""
}

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    coloredOutput [ ! ] 2
    Write-Host -ForegroundColor Yellow -NoNewLine " Warning: Recomended to run as"
    Write-Host -ForegroundColor Red " administrator"
    Write-Host ""
}

coloredOutput [ + ]
Write-Host -ForegroundColor Green -NoNewline " Checking for updates..."
Write-Host ""

try {
    $latestVersion = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/toanic/dupliscanExtreme/main/DupliscanExtremeEdition/VERSION" -UseBasicParsing
    $latestVersion = $latestVersion.Content

    $latestVersion = $latestVersion.Substring(41, 5)

    if ((($version.GetType()).BaseType).Name -eq "Array") {
        $version = $version[2].Substring(23)
    }

    if ($latestVersion -gt $version) {
        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewline " Current version "
        Write-Host -ForegroundColor Cyan -NoNewline $version
        Write-Host ""

        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewline " Latest version "
        Write-Host -ForegroundColor Cyan -NoNewline $latestVersion
        Write-Host ""

        coloredOutput [ + ] 3
        Write-Host -ForegroundColor Green -NoNewLine " Update now? "
        coloredOutput "(" "y" "/"
        coloredOutput "" "n" ") "
        $update = Read-Host " "

        if ($update.ToUpper() -eq "Y") {
            coloredOutput [ + ] 3
            Write-Host -ForegroundColor Green -NoNewline " Updating..."
            Write-Host ""

            #$script = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/simonrenggli1/dupliscan/master/DupliScan.ps1" -UseBasicParsing
            #$script = $script.Content
            #$script | Out-File -FilePath ".\dupliscanExp.ps1" -Force

            $version = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/toanic/dupliscanExtreme/main/DupliscanExtremeEdition/VERSION" -UseBasicParsing
            $version = $version.Content
            $version | Out-File -FilePath ".\VERSION" -Force
            
            coloredOutput [ + ] 3
            coloredOutput " Updated to " $latestVersion ""
            Write-Host ""
            exit
        } 
        else {
            coloredOutput [ + ]
            Write-Host -ForegroundColor Green -NoNewline " Skipping update"
            Write-Host ""
        }
    }
    else {
        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewline " Up to date"
        Write-Host ""
    }
}
catch {
    errorHandling "Failed to check for updates"
}

Write-Host ""
Write-Host -ForegroundColor Green "    Mode"
Write-Host -ForegroundColor Green "---------------------------------------------"
coloredOutput "" "    1" "."
Write-Host -ForegroundColor Cyan " Scan partition"
coloredOutput "" "    2" "."
Write-Host -ForegroundColor Cyan " Scan custom directory"
Write-Host ""
coloredOutput [ + ]
Write-Host -ForegroundColor Green -NoNewline " Select mode "
coloredOutput "(" "1-2" ")"
$mode = Read-Host " "

if ($mode -eq "") {
    errorHandling "No input"
    exit
}

if ($mode -lt 1 -or $mode -gt 2) {
    errorHandling "Out of range"
    exit
}

if ($mode -eq 1) {
    coloredOutput [ + ] 3
    Write-Host -ForegroundColor Green " Scanning partitions..."
    Write-Host ""

    $partitions = Get-Partition | Where-Object { $_.Size -gt 1000000000 }
    Write-Host ""
    Write-Host -ForegroundColor Green "    Drive    Size"
    Write-Host -ForegroundColor Green "---------------------------------------------"

    $number = 0
    $partitionInfo = @{}

    foreach ($partition in $partitions) {
        $size = "{0:N2} GB" -f ($partition.Size / 1GB)
        $partitionInfo[$number] = $partition.DriveLetter
        $number = $number + 1
        $partitionName = $partition.DriveLetter
        coloredOutput "" "$number" ".  $partitionName        "
        Write-Host -ForegroundColor Cyan "$size"
    }

    coloredOutput [ + ] 3
    Write-Host -ForegroundColor Green -NoNewline " Select partition "
    if ($number -eq 1){
    coloredOutput "(" "1" ")"
    }
    else {
    coloredOutput "(" "1-$number" ")"
    }
    $partitionSelected = Read-Host " "

    if ($partitionSelected -eq "") {
        errorHandling "No input"
        exit
    }

    if ($partitionSelected -lt 1 -or $partitionSelected -gt $number) {
        errorHandling "Out of Range"
        exit
    }

    coloredOutput [ + ]
    Write-Host -ForegroundColor Green " Scanning partition..."
    Write-Host ""

    $driveLetter = $partitionInfo[$partitionSelected - 1]

    $path = $driveLetter + ":\"
}

if ($mode -eq 2) {
    coloredOutput [ + ]
    Write-Host -ForegroundColor Green -NoNewline " Enter custom directory "
    $path = Read-Host " "

    if ($path -eq "") {
        errorHandling "No input"
        exit
    }

    if (-not (Test-Path $path)) {
        errorHandling "Path does not exist"
        exit
    }

    if (-not (Test-Path $path -PathType Container)) {
        errorHandling "Path is not a directory"
        exit
    }

    coloredOutput [ + ] 3
    Write-Host -ForegroundColor Green " Scanning directory..."

    $fileInfo = @{}

    $path = $path.Trim()

    if ($path -match "^[a-zA-Z]:$") {
        $path = "$path\"
    }

    if (((Get-CimInstance Win32_OperatingSystem).Caption) -NotLike "*Microsoft Windows*")
    {
        $path = "\\?\" + $path
    }
}

$fileInfo = @{}

function CheckDuplicate($filePath, $fileName, $fileSize) {
    try {
        $key = "$fileName-$fileSize"
        if ($fileInfo.ContainsKey($key)) {
            $duplicatePaths = $fileInfo[$key]
            $duplicatePaths += $filePath
            $fileInfo[$key] = $duplicatePaths
        }
        else {
            $fileInfo[$key] = @($filePath)
        }
    }
    catch {
        errorHandling "Error occured while checking duplicate: $_"
    }
}

try {
    $files = Get-ChildItem -LiteralPath $path -File -Recurse

    foreach ($file in $files) {
        try {
            $filePath = $file.FullName
            $fileName = $file.Name
            $fileSize = $file.Length

            CheckDuplicate -filePath $filePath -fileName $fileName -fileSize $fileSize
        }
        catch {
            errorHandling "Error occured while processing file: $_"
        }
    }

    if (-not (Test-Path -Path ".\DupliScan.log")) {
        New-Item -Path ".\DupliScan.log" -ItemType File -Force | Out-Null
        Add-Content -Path ".\DupliScan.log" -Value "== DupliScan Log ==" | Out-Null
    }
    else {
        Add-Content -Path ".\DupliScan.log" -Value "== DupliScan Log ==" | Out-Null
    }

    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Timestamp: [$(Get-Date)]"
    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Directory: $path"
    Add-Content -Path ".\DupliScan.log" -Value ""

    if ($fileInfo.Count -eq 0) {
        coloredOutput [ + ] 3

        Write-Host -ForegroundColor Green -NoNewline " No duplicates found"
        Write-Host ""

        Add-Content -Path ".\DupliScan.log" -Value "No duplicates found"
        exit
    }

    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
    Add-Content -Path ".\DupliScan.log" -Value "Duplicate Files Found:"
    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"

    foreach ($key in $fileInfo.Keys) {
        try {
            $duplicatePaths = $fileInfo[$key]
            if ($duplicatePaths.Count -gt 1) {
                Write-Host ""
                coloredOutput [ + ] 1
                Write-Host -ForegroundColor Yellow " Duplicate file: $key"

                Add-Content -Path ".\DupliScan.log" -Value ""
                Add-Content -Path ".\DupliScan.log" -Value "File: $key"
                Add-Content -Path ".\DupliScan.log" -Value "Duplicates:"

                foreach ($duplicatePath in $duplicatePaths) {
                    Write-Host -ForegroundColor Red "[!] $duplicatePath"
                    Add-Content -Path ".\DupliScan.log" -Value "    - $duplicatePath"
                }
            }
        }
        catch {
            Write-Host -ForegroundColor Red "[!] Error occurred while processing duplicate: $_"
        }
    }
}
catch {
    Write-Host -ForegroundColor Red "[!] Error occurred while scanning partition: $_"
}

coloredOutput [ + ] 3
Write-Host -ForegroundColor Green " Done"
Write-Host ""

Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value "End of Duplicate Files Log"
Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value ""
exit

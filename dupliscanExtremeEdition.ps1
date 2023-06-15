$Host.UI.RawUI.WindowTitle = "Windows Powershell " + $Host.Version;

function coloredOutput ($text1, $text2, $text3, [int]$scheme = 0){
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
}

if ([System.Environment]::OSVersion.Version.Major -lt 6) {
    Write-Host -ForegroundColor Red "[!] Unsupported operating system"
    Write-Host ""
    exit
}

if (-not (Test-Path -Path ".\VERSION")) {
    Write-Host -ForegroundColor Red "[!] VERSION file not found"
    Write-Host ""
    New-Item -Path ".\VERSION" -ItemType File -Force | Out-Null
    Add-Content -Path ".\VERSION" -Value "0.0.0" | Out-Null
}

$version = Get-Content -Path ".\VERSION"


<#
Write-Host ""
#Write-Host -ForegroundColor White "     ______"
Write-Host -ForegroundColor White $version[1]
#Write-Host -ForegroundColor White -NoNewline "    | __   \	"
Write-Host -ForegroundColor White -NoNewLine $version[2].Substring(0, 13)
#Write-Host -ForegroundColor Cyan -NoNewline "DupliScan "
Write-Host -ForegroundColor Cyan -NoNewLine $version[2].Substring(13, 10)
#Write-Host -ForegroundColor DarkCyan "0.1.6"
Write-Host -ForegroundColor DarkCyan $version[2].Substring(23)
#Write-Host -ForegroundColor White -NoNewline "    | _ __  |	"
Write-Host -ForegroundColor White -NoNewLine $version[3].Substring(0, 14)
#Write-Host -ForegroundColor DarkGreen "a duplicate file scanner by simonrenggli1"
Write-Host -ForegroundColor DarkGreen $version[3].Substring(14)
#Write-Host -ForegroundColor White -NoNewline "    | ____  |	"
Write-Host -ForegroundColor White -NoNewLine $version[4].Substring(0, 14)
#Write-Host -ForegroundColor DarkGreen "maintained by simonrenggli1"
Write-Host -ForegroundColor DarkGreen $version[4].Substring(14)
#Write-Host -ForegroundColor White -NoNewline "    | __ _  |	"
Write-Host -ForegroundColor White -NoNewLine $version[5].Substring(0, 14)
#Write-Host -ForegroundColor DarkMagenta "https://github.com/simonrenggli1/dupliscan"
Write-Host -ForegroundColor DarkMagenta $version[5].Substring(14)
#Write-Host -ForegroundColor White "    |_______|"
Write-Host -ForegroundColor White $version[6].Substring(0, 13)
#>



Write-Host ""
Write-Host -ForegroundColor White            $version[1]
Write-Host -ForegroundColor White -NoNewLine $version[2].Substring(0, 13)
Write-Host -ForegroundColor Cyan -NoNewLine  $version[2].Substring(13, 10)
Write-Host -ForegroundColor DarkCyan         $version[2].Substring(23)
Write-Host -ForegroundColor White -NoNewLine $version[3].Substring(0, 14)
Write-Host -ForegroundColor DarkGreen        $version[3].Substring(14)
Write-Host -ForegroundColor White -NoNewLine $version[4].Substring(0, 14)
Write-Host -ForegroundColor DarkGreen        $version[4].Substring(14)
Write-Host -ForegroundColor White -NoNewLine $version[5].Substring(0, 14)
Write-Host -ForegroundColor DarkMagenta      $version[5].Substring(14)
Write-Host -ForegroundColor White            $version[6].Substring(0, 13)



Write-Host ""

if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    coloredOutput [ ! ] 2
    coloredOutput " Warning: Recomended to run as" " administrator" "" 2
    Write-Host ""
}

coloredOutput [ + ]
Write-Host -ForegroundColor Green -NoNewline " Checking for updates..."
Write-Host ""

try {
    $latestVersion = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/simonrenggli1/dupliscan/master/VERSION" -UseBasicParsing
    $latestVersion = $latestVersion.Content

    $latestVersion = $latestVersion.Replace("`n", "")
    $latestVersion = $latestVersion.Replace("`r", "")

    if ($latestVersion -gt $version[2].Substring(23)) {
        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewline " Current version "
        Write-Host -ForegroundColor Cyan -NoNewline $version[2].Substring(23)
        Write-Host ""

        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewline " Latest version "
        Write-Host -ForegroundColor Cyan -NoNewline $latestVersion
        Write-Host ""
        Write-Host ""

        coloredOutput [ + ]
        Write-Host -ForegroundColor Green -NoNewLine " Update now? "
        coloredOutput "(" "y" "/"
        coloredOutput "" "n" ") "
        $update = Read-Host " "

        if ($update.ToUpper() -eq "Y") {
            Write-Host ""
            coloredOutput [ + ]
            Write-Host -ForegroundColor Green -NoNewline " Updating..."
            Write-Host ""

            $script = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/simonrenggli1/dupliscan/master/DupliScan.ps1" -UseBasicParsing
            $script = $script.Content
            $script | Out-File -FilePath ".\dupliscanExp.ps1" -Force

            $version = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/simonrenggli1/dupliscan/master/VERSION" -UseBasicParsing
            $version = $version.Content
            $version | Out-File -FilePath ".\VERSION" -Force
            
            Write-Host ""
            coloredOutput [ + ]
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
    Write-Host -ForegroundColor Red "[!] Failed to check for updates"
    Write-Host ""
}

Write-Host ""
Write-Host -ForegroundColor Green "    Mode"
Write-Host -ForegroundColor Green "---------------------------------------------"
coloredOutput "    1" "." ""
Write-Host -ForegroundColor Cyan " Scan partition"
coloredOutput "    2" "." ""
Write-Host -ForegroundColor Cyan " Scan custom directory"
Write-Host ""
coloredOutput [ + ]
Write-Host -ForegroundColor Green -NoNewline " Select mode "
coloredOutput "(" "1-2" ")"
$mode = Read-Host " "
Write-Host ""

if ($mode -eq "") {
    Write-Host -ForegroundColor Red "[!] No input"
    Write-Host ""
    exit
}

if ($mode -lt 1 -or $mode -gt 2) {
    Write-Host -ForegroundColor Red "[!] Out of range"
    Write-Host ""
    exit
}

if ($mode -eq 1) {
    coloredOutput [ + ]
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
        coloredOutput "" "$number" ".  "
        coloredOutput "$partitionName        " "$size" ""
    }
    #TODO TOAN
    Write-Host ""
    coloredOutput [ + ]
    Write-Host -ForegroundColor Green -NoNewline " Select partition "
    if ($number -eq 1){
    coloredOutput "(" "1" ")"
    }
    else {
    coloredOutput "(" "1 - $number" ")"
    }
    $partitionSelected = Read-Host " "
    Write-Host ""

    if ($partitionSelected -eq "") {
        Write-Host -ForegroundColor Red "[!] No input"
        Write-Host ""
        exit
    }

    if ($partitionSelected -lt 1 -or $partitionSelected -gt $number) {
        Write-Host -ForegroundColor Red "[!] Out of range"
        Write-Host ""
        exit
    }

    coloredOutput [ + ]
    Write-Host -ForegroundColor Green " Scanning partition..."

    $driveLetter = $partitionInfo[$partitionSelected - 1]

    $path = $driveLetter + ":\"
}

if ($mode -eq 2) {
    coloredOutput [ + ]
    Write-Host -ForegroundColor Green -NoNewline " Enter custom directory "
    $path = Read-Host " "
    Write-Host ""

    if ($path -eq "") {
        Write-Host -ForegroundColor Red "[!] No input"
        Write-Host ""
        exit
    }

    if (-not (Test-Path $path)) {
        Write-Host -ForegroundColor Red "[!] Path does not exist"
        Write-Host ""
        exit
    }

    if (-not (Test-Path $path -PathType Container)) {
        Write-Host -ForegroundColor Red "[!] Path is not a directory"
        Write-Host ""
        exit
    }

    coloredOutput [ + ]
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
        Write-Host -ForegroundColor Red "[!] Error occurred while checking duplicate: $_"
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
            Write-Host -ForegroundColor Red "[!] Error occurred while processing file: $_"
        }
    }


    if (-not (Test-Path -Path ".\DupliScan.log")) {
        New-Item -Path ".\DupliScan.log" -ItemType File -Force | Out-Null
        Add-Content -Path ".\DupliScan.log" -Value "== DupliScan Log ==" | Out-Null
    }
    #if ((Get-Content -Path ".\DupliScan.log") -eq "") {
    else {
        Add-Content -Path ".\DupliScan.log" -Value "== DupliScan Log ==" | Out-Null
    }

    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Timestamp: [$(Get-Date)]"
    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Directory: $path"
    Add-Content -Path ".\DupliScan.log" -Value ""

    if ($fileInfo.Count -eq 0) {
        Write-Host ""
        coloredOutput [ + ]

        Write-Host -ForegroundColor Green -NoNewline " No duplicates found"
        Write-Host ""

        Add-Content -Path ".\DupliScan.log" -Value "No duplicates found"
        exit
    }

    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
    Add-Content -Path ".\DupliScan.log" -Value "Duplicate Files Found:"
    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
    Add-Content -Path ".\DupliScan.log" -Value ""

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
                Add-Content -Path ".\DupliScan.log" -Value ""
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

Write-Host ""
coloredOutput [ + ]
Write-Host -ForegroundColor Green " Done"
Write-Host ""

Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value "End of Duplicate Files Log"
Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value ""
exit
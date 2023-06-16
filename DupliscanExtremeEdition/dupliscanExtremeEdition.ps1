# modify CLI window name
$Host.UI.RawUI.WindowTitle = "DupliScanEXT "

# change directory so that version can be checked and log is in the same directory
if ((Get-Location).Path -ne $PSScriptRoot) {
    cd $PSScriptRoot
}

# function for colored information text
function coloredOutput ($text1, [int] $scheme = 0) {
    if ($scheme -eq 0) {
        Write-Host -ForegroundColor Green -NoNewLine "["
        Write-Host -ForegroundColor Cyan  -NoNewLine "+"
        Write-Host -ForegroundColor Green -NoNewLine "] $text1"
    }
    if ($scheme -eq 1) {
        Write-Host -ForegroundColor Green -NoNewLine "["
        Write-Host -ForegroundColor Cyan  -NoNewLine "+"
        Write-Host -ForegroundColor Green -NoNewLine "] "
        Write-Host -ForegroundColor Green            $text1
    }
    if ($scheme -eq 2) {
        Write-Host -ForegroundColor Yellow -NoNewLine "`n["
        Write-Host -ForegroundColor Red    -NoNewLine "!"
        Write-Host -ForegroundColor Yellow -NoNewLine "] $text1"
    }
}

# function for colored user options
function coloredOption ($text1, $text2, $text3, $text4 = "", $text5 = "") {
        Write-Host -ForegroundColor Green -NoNewLine $text1
        Write-Host -ForegroundColor Cyan  -NoNewLine $text2
        Write-Host -ForegroundColor Green -NoNewLine $text3
        Write-Host -ForegroundColor Cyan  -NoNewLine $text4
        Write-Host -ForegroundColor Green -NoNewLine $text5
}

# function for error messages
function errorHandling ([string]$errorMessage, [int] $outputType = 0) {
    Write-Host -ForegroundColor Red "`n[!] $errorMessage"
    if ($outputType -eq 0) {
        Write-Host ""
    }
}

# check OS
if ([System.Environment]::OSVersion.Version.Major -lt 6) {
    errorHandling "Unsupported operating system"
    exit
}

# get local VERSION
if (-not (Test-Path -Path ".\VERSION")) {
    errorHandling "VERSION file not found" 1
    New-Item -Path ".\VERSION" -ItemType File -Force | Out-Null
    Add-Content -Path ".\VERSION" -Value "0.0.0" | Out-Null
    Set-ItemProperty -Path ".\VERSION" -Name IsReadOnly -Value $true
}

$version = Get-Content -Path ".\VERSION"

# output ASCII header
if ((($version.GetType()).BaseType).Name -eq "Array") {
    Write-Host ""
    Write-Host -ForegroundColor White                  $version[1]
    Write-Host -ForegroundColor White       -NoNewLine $version[2].Substring(0, 13)
    Write-Host -ForegroundColor Cyan        -NoNewLine $version[2].Substring(13, 13)
    Write-Host -ForegroundColor DarkCyan               $version[2].Substring(26)
    Write-Host -ForegroundColor White       -NoNewLine $version[3].Substring(0, 14)
    Write-Host -ForegroundColor DarkGreen              $version[3].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[4].Substring(0, 14)
    Write-Host -ForegroundColor DarkGreen              $version[4].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[5].Substring(0, 14)
    Write-Host -ForegroundColor DarkMagenta            $version[5].Substring(14)
    Write-Host -ForegroundColor White       -NoNewLine $version[6].Substring(0, 13)
    Write-Host -ForegroundColor DarkMagenta            $version[6].Substring(13)

    $version = $version[2].Substring(26)

    # modify CLI window name
    $Host.UI.RawUI.WindowTitle += $version
}

# check for administrator mode
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    coloredOutput "Warning: Recommended to run as " 2
    Write-Host -ForegroundColor Red "administrator`n"
}

coloredOutput "Checking for updates..." 1

# check for updates
try {
    # get latest VERSION
    $latestVersion = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/toanic/dupliscanExtreme/main/DupliscanExtremeEdition/VERSION" -UseBasicParsing
    $latestVersion = $latestVersion.Content
    $latestVersion = $latestVersion.Substring(42, 5)

    # check for differences in versions
    if ($latestVersion -gt $version) {
        coloredOutput "Current version "
        Write-Host -ForegroundColor Cyan $version

        coloredOutput "Latest version "
        Write-Host -ForegroundColor Cyan $latestVersion

        # give option to update local script
        Write-Host ""
        coloredOutput "Update now? "
        coloredOption "(" "y" "/" "n" ")"
        $update = Read-Host " "

        if ($update.ToUpper() -eq "Y") {
            Write-Host ""
            coloredOutput "Updating..." 1

            # download latest script
            <#
            $script = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/toanic/dupliscanExtreme/main/DupliscanExtremeEdition/dupliscanExtremeEdition.ps1" -UseBasicParsing
            $script = $script.Content
            $script | Out-File -FilePath ".\dupliscanExtremeEdition.ps1" -Force
            #>

            # download latest VERSION
            $version = Invoke-WebRequest -Uri "https://raw.githubusercontent.com/toanic/dupliscanExtreme/main/DupliscanExtremeEdition/VERSION" -UseBasicParsing
            $version = $version.Content
            $version | Out-File -FilePath ".\VERSION" -Force
            
            Write-Host ""
            coloredOutput "Updated to "
            Write-Host -ForegroundColor Cyan $latestVersion

            # warning for ISE users, as updated files aren't updated inside the ISE
            if ((Get-Host).Name -eq "Windows PowerShell ISE Host") {
                coloredOutput "Warning: This file has to be closed and reopened to use the updated version" 2
                Write-Host ""
            }
            # end script to allow updated script to be run
            exit
        } 
        else {
            coloredOutput "Skipping update" 1
        }
    }
    else {
        coloredOutput "Up to date" 1
    }
}
catch {
    errorHandling "Failed to check for updates"
}

# selection of modes
Write-Host ""
Write-Host -ForegroundColor Green            "    Mode"
Write-Host -ForegroundColor Green            "---------------------------------------------"
Write-Host -ForegroundColor Cyan  -NoNewLine "    1"
Write-Host -ForegroundColor Green -NoNewLine "."
Write-Host -ForegroundColor Cyan             " Scan partition"
Write-Host -ForegroundColor Cyan  -NoNewLine "    2"
Write-Host -ForegroundColor Green -NoNewLine "."
Write-Host -ForegroundColor Cyan             " Scan custom directory"
Write-Host ""
coloredOutput "Select mode "
coloredOption "(" "1-2" ")"
$mode = Read-Host " "

if ($mode -eq "") {
    errorHandling "No input"
    exit
}

if ($mode -lt 1 -or $mode -gt 2) {
    errorHandling "Out of range"
    exit
}

# mode 1
if ($mode -eq 1) {
    Write-Host ""
    coloredOutput "Scanning partitions...`n" 1

    # get available partitions
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
        Write-Host -ForegroundColor Cyan  -NoNewLine "$number"
        Write-Host -ForegroundColor Green -NoNewLine ".  $partitionName        "

        Write-Host -ForegroundColor Cyan "$size"
    }

    # allow for a partition to be selected
    Write-Host ""
    coloredOutput "Select partition "
    if ($number -eq 1) {
        coloredOption "(" 1 ")"
    }
    else {
        coloredOption "(" "1-$number" ")"
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
    
    coloredOutput "Scanning partition...`n" 1

    $driveLetter = $partitionInfo[$partitionSelected - 1]

    # set path to selected partition
    $path = $driveLetter + ":\"
}

# mode 2
if ($mode -eq 2) {
    # allow for custom directory to be specified
    coloredOutput "Enter custom directory "
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

    Write-Host ""
    coloredOutput "Scanning directory..." 1

    $fileInfo = @{}

    # modify $path so that directory path can be searched
    $path = $path.Trim()

    if ($path -match "^[a-zA-Z]:$") {
        $path = "$path\"
    }

    # modify $path for use on macOS
    if (((Get-CimInstance Win32_OperatingSystem).Caption) -NotLike "*Microsoft Windows*") {
        $path = "\\?\" + $path
    }
}

# initialize fileInfo array
$fileInfo = @{}

# function which looks for duplicate files in the specified path
function CheckDuplicate($filePath, $fileName, $fileSize) {
    try {
        $key = "$fileName-$fileSize"
        # checks whether file already exists in fileInfo array
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
    # gets all files in selected partition/ directory
    $files = Get-ChildItem -LiteralPath $path -File -Recurse

    foreach ($file in $files) {
        try {
            $filePath = $file.FullName
            $fileName = $file.Name
            $fileSize = $file.Length

            # calls CheckDuplicate function with each file
            CheckDuplicate -filePath $filePath -fileName $fileName -fileSize $fileSize
        }
        catch {
            errorHandling "Error occured while processing file: $_"
        }
    }

    if (Test-Path -Path ".\DupliScan.log") {
        coloredOutput "Do you want to overwrite the existing log? "
        coloredOption "(" "y" "/" "n" ")"
        $overwrite = Read-Host " "
        Write-Host ""
        
        if ($overwrite.ToUpper() -eq "Y") {
            Remove-Item -Path ".\DupliScan.log" -Force
        }
    }

    # checks whether log already exists    
    if (-not (Test-Path -Path ".\DupliScan.log")) {
        New-Item -Path ".\DupliScan.log" -ItemType File -Force | Out-Null
    }

    # add information header to log
    Add-Content -Path ".\DupliScan.log" -Value "== DupliScan Log ==" | Out-Null
    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Timestamp: [(Get-Date)]"
    Add-Content -Path ".\DupliScan.log" -Value ""
    Add-Content -Path ".\DupliScan.log" -Value "Directory: $path"
    Add-Content -Path ".\DupliScan.log" -Value ""

    # alternate ending if no duplicate files are found
    if ($fileInfo.Count -eq 0) {
        Write-Host ""
        coloredOutput "No duplicates found" 1

        Add-Content -Path ".\DupliScan.log" -Value "No duplicates found"
        exit
    }

    # add duplicate file header to log
    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
    Add-Content -Path ".\DupliScan.log" -Value "Duplicate Files Found:"
    Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"

    foreach ($key in $fileInfo.Keys) {
        try {
            $duplicatePaths = $fileInfo[$key]
            if ($duplicatePaths.Count -gt 1) {
                # output duplicate file via CLI
                Write-Host ""
                Write-Host -ForegroundColor Yellow -NoNewLine "["
                Write-Host -ForegroundColor Cyan   -NoNewLine "+"
                Write-Host -ForegroundColor Yellow -NoNewLine "] "
                Write-Host -ForegroundColor Yellow            "Duplicate file: $key"

                # add duplicate file to log
                Add-Content -Path ".\DupliScan.log" -Value ""
                Add-Content -Path ".\DupliScan.log" -Value "File: $key"
                Add-Content -Path ".\DupliScan.log" -Value "Duplicates:"

                foreach ($duplicatePath in $duplicatePaths) {
                    Write-Host -ForegroundColor Red "[!] $duplicatePath"               # output all paths via CLI 
                    Add-Content -Path ".\DupliScan.log" -Value "    - $duplicatePath"  # add all paths to duplicate file
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

# output end of script via CLI
Write-Host ""
coloredOutput "Done`n" 1

# add ending to log
Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value "End of Duplicate Files Log"
Add-Content -Path ".\DupliScan.log" -Value "----------------------------------"
Add-Content -Path ".\DupliScan.log" -Value ""
exit

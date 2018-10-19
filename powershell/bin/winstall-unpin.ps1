Get-AppxPackage -AllUsers | where-object {$_.name -notlike "*Microsoft.WindowsCalculator*"} | Remove-AppxPackage
#Get-AppxProvisionedPackage -online | where-object {$_.packagename -notlike "*Microsoft.WindowsCalculator*"} | Remove-AppxProvisionedPackage -online

function findTheNeedle ($needle, $haystack, $startIndexInHaystack=0, $needlePartsThatDontMatter=@())
{
    # Save the last index for the current haystack array and the needle array
    $haystackLastIndex = ($haystack.Length - 1)
    $needleLastIndex = ($needle.Length - 1)

    # Used to keep track of the current location in the byte arrays
    $needleCurrentIndex = 0
    $haystackCurrentIndex = $startIndexInHaystack

    # Loop through the current haystack array
    while ($haystackCurrentIndex -lt $haystackLastIndex)
    {
        if ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex]  -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
        {
            # If the current value of the haystack array matches the first value of the needle array,
            # we save the current haystack array index.
            $startIndex = $haystackCurrentIndex

            # We then proceed to compare the next item in the haystack array with the next value in the
            # needle array until we no longer get a match, like a greedy regex
            while ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
            {
                $needleCurrentIndex += 1
                $haystackCurrentIndex += 1
            }

            # If the last match was the last item in the needle array, we have located the entire needle
            # array inside the haystack array. This means the needle is present. Return the indexes in the haystack
            # array where the needle array begins.
            if (($needleCurrentIndex - 1) -eq $needleLastIndex)
            {
                return ($startIndex + 1)
            }

            # Reset the needle index counter
            $needleCurrentIndex = 0

            # Move the haystack index back to the location of the match that caused us to enter this if block.
            $haystackCurrentIndex = $startIndex
        }

        # Step to the next item in the haystack array
        $haystackCurrentIndex += 1
    }
    return -1
}

function findTheNeedleReverse ($needle, $haystack, $startIndexInHaystack=0, $needlePartsThatDontMatter=@())
{
    # Save the last index for the current taskbar array and the needle array
    $needleLastIndex = ($needle.Length - 1)

    # Used to keep track of the current location in the byte arrays
    $needleCurrentIndex = $needleLastIndex
    $haystackCurrentIndex = $startIndexInHaystack

    # Loop through the current taskbar array
    while ($haystackCurrentIndex -gt 0)
    {

        if ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex]  -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
        {
            # If the current value of the registry byte array matches the first value of the app byte array,
            # we save the current registry byte array index.
            $startIndex = $haystackCurrentIndex

            # We then proceed to compare the next item in the registry byte array with the next value in the
            # app byte array until we no longer get a match, like a greedy regex.
            while ($haystack[$haystackCurrentIndex] -eq $needle[$needleCurrentIndex] -or ($needleCurrentIndex -in $needlePartsThatDontMatter))
            {
                $needleCurrentIndex -= 1
                $haystackCurrentIndex -= 1
            }

            # If the last match was the last item in the app byte array, we have located the entire app byte
            # array inside the registry byte array. This means Edge is pinned. Save the indexes in the registry
            # byte array where the Edge byte array begins and ends ($startIndex and $endIndex).
            if (($needleCurrentIndex + 1) -eq 0)
            {
                return ($haystackCurrentIndex + 1)
            }

            # Reset the needle index counter
            $needleCurrentIndex = $needleLastIndex

            # Move the haystack index back to the location of the match that caused us to enter this if block.
            $haystackCurrentIndex = $startIndex
        }

        # Step to the next byte in the registry array
        $haystackCurrentIndex -= 1
    }
    return -1
}

# The header and trailer patterns seem to be the same for all modern apps, so as of right now it isn't really needed to
# have separate hash table entries for each app. I'm doing it anyway to add some futureproofing/flexibility.
$taskbarEntryHeaderBytes = @(0,51,6,0,0,20,0,31,128,155,212,52);
$taskbarEntryHeaderBytesThatDontMatter = @(0,1,2,5,9,10);
$taskbarEntryTrailerBytes = @(34,0,0,0,30,0,239,190,2,0,85,0,115,0,101,0,114,0,80,0,105,0,110,0,110,0,101,0,100,0,0,0,59,5,0,0);
$taskbarEntryTrailerBytesThatDontMatter = @(32,33);

$apps = @(
    @{
        "appName" = "Microsoft Edge"
        "appThumbprint" = @(38,0,0,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,46,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,69,0,100,0,103,0,101);
        "taskbarEntryHeaderBytes" = $taskbarEntryHeaderBytes
        "taskbarEntryHeaderBytesThatDontMatter" = $taskbarEntryHeaderBytesThatDontMatter
        "taskbarEntryTrailerBytes" = $taskbarEntryTrailerBytes
        "taskbarEntryTrailerBytesThatDontMatter" = $taskbarEntryTrailerBytesThatDontMatter
    }
    @{
        "appName" = "Microsoft Windows Store"
        "appThumbprint" = @(37,0,0,0,77,0,105,0,99,0,114,0,111,0,115,0,111,0,102,0,116,0,46,0,87,0,105,0,110,0,100,0,111,0,119,0,115,0,83,0,116,0,111,0,114,0,101);
        "taskbarEntryHeaderBytes" = $taskbarEntryHeaderBytes
        "taskbarEntryHeaderBytesThatDontMatter" = $taskbarEntryHeaderBytesThatDontMatter
        "taskbarEntryTrailerBytes" = $taskbarEntryTrailerBytes
        "taskbarEntryTrailerBytesThatDontMatter" = $taskbarEntryTrailerBytesThatDontMatter
    }
)

# Start with the assumption that no apps are pinned.
$atLeastOneAppIsPinned = $false

foreach ($app in $apps)
{
    # Get the current taskbar registry key
    $haystack = (Get-ItemProperty -Path "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites").Favorites

    # First, we check for the app's thumbprint.
    $needleStart = findTheNeedle $app["appThumbprint"] $haystack

    # Carry on only if we found the thumbprint
    if ($needleStart -ne -1)
    {
        # Look for the trailer pattern starting from the first byte after the thumbprint
        $firstIndexAfterNeedle = $needleStart + $app["appThumbprint"].Length
        $lastIndexOfEntry = (findTheNeedle $app["taskbarEntryTrailerBytes"] $haystack $firstIndexAfterNeedle $app["taskbarEntryTrailerBytesThatDontMatter"]) + ($app["taskbarEntryTrailerBytes"].Length - 1)

        # Carry on only if we found the trailer pattern
        if (($lastIndexOfEntry) -ne -1)
        {
            # Look for the header pattern going backwards from the first byte before the thumbprint
            $firstIndexOfEntry = findTheNeedleReverse $app["taskbarEntryHeaderBytes"] $haystack $needleStart $app["taskbarEntryHeaderBytesThatDontMatter"]

            # Carry on only if we found the header pattern
            if (($firstIndexOfEntry) -ne -1)
            {
                $atLeastOneAppIsPinned = $true

                # Create a new version of the taskbar registry entry without the app we're unpinning
                if ($firstIndexOfEntry -eq 0) 
                {
                    $newArray = $haystack[$lastIndexOfEntry..($haystack.Length)]
                }
                else
                {
                    $newArray = $haystack[0..($firstIndexOfEntry - 1)] + $haystack[$lastIndexOfEntry..($haystack.Length)]
                }
                # Overwrite the old registry key with the new one
                New-ItemProperty -Path "hkcu:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Taskband" -Name "Favorites" -Value $newArray -PropertyType Binary -Force | Out-Null
            }
        }
    }
}


function Pin-App {    param(
        [string]$appname,
        [switch]$unpin
    )
    try{
        if ($unpin.IsPresent){
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'Von "Start" lösen|Unpin from Start'} | %{$_.DoIt()}
            return "App '$appname' unpinned from Start"
        }else{
            ((New-Object -Com Shell.Application).NameSpace('shell:::{4234d49b-0245-4df3-b780-3893943456e1}').Items() | ?{$_.Name -eq $appname}).Verbs() | ?{$_.Name.replace('&','') -match 'An "Start" anheften|Pin to Start'} | %{$_.DoIt()}
            return "App '$appname' pinned to Start"
        }
    }catch{
        Write-Error "Error Pinning/Unpinning App! (App-Name correct?)"
    }
}

Get-StartApps | ForEach-Object { Pin-App $_.name -unpin }


Invoke-Expression "taskkill /f /im explorer.exe"
Invoke-Expression "start explorer.exe"


Pin-App "Calculator" -pin
Pin-App "This PC" -pin
Pin-App "Settings" -pin
Pin-App "Remote Desktop Connection" -pin
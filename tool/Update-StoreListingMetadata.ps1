<#
.SYNOPSIS
  Updates Microsoft Store listing metadata JSON for a Store submission.

.DESCRIPTION
  Reads metadata JSON from `msstore submission get`, applies the English Store
  listing draft from docs/store-listing/README.md when present, and sets the
  Store "What's new in this version" field from recent git commit subjects.

  For packaged MSIX products, msstore uses the Dev Center submission shape:
  Listings.<language>.BaseListing.ReleaseNotes.

  For newer metadata API products, msstore uses the Store metadata shape:
  listings[].whatsNew.
#>
param(
  [Parameter(Mandatory = $true)]
  [string]$MetadataPath,

  [string]$OutputPath,
  [string]$ListingMarkdownPath = "docs/store-listing/README.md",
  [string]$ListingLanguage = "en-us",
  [string]$ReleaseNotesFromRef = "",
  [string]$ReleaseNotesToRef = "HEAD",
  [int]$ReleaseNotesMaxCharacters = 1500,
  [string]$ReleaseNotesOutputPath = ""
)

$ErrorActionPreference = 'Stop'

if (-not $OutputPath) {
  $OutputPath = $MetadataPath
}

function Resolve-LocalPath {
  param([string]$Path)

  if ([System.IO.Path]::IsPathRooted($Path)) {
    return $Path
  }

  return Join-Path (Get-Location) $Path
}

function Get-JsonProperty {
  param(
    [Parameter(Mandatory = $true)]$InputObject,
    [Parameter(Mandatory = $true)][string]$Name
  )

  return $InputObject.PSObject.Properties |
      Where-Object { $_.Name -ieq $Name } |
      Select-Object -First 1
}

function Set-JsonProperty {
  param(
    [Parameter(Mandatory = $true)]$InputObject,
    [Parameter(Mandatory = $true)][string]$Name,
    $Value
  )

  $property = Get-JsonProperty -InputObject $InputObject -Name $Name
  if ($property) {
    $property.Value = $Value
  }
  else {
    Add-Member -InputObject $InputObject -MemberType NoteProperty -Name $Name -Value $Value
  }
}

function Ensure-JsonObjectProperty {
  param(
    [Parameter(Mandatory = $true)]$InputObject,
    [Parameter(Mandatory = $true)][string]$Name
  )

  $property = Get-JsonProperty -InputObject $InputObject -Name $Name
  if ($property -and $property.Value) {
    return $property.Value
  }

  $value = [pscustomobject]@{}
  Set-JsonProperty -InputObject $InputObject -Name $Name -Value $value
  return $value
}

function Get-MarkdownSection {
  param(
    [Parameter(Mandatory = $true)][string]$Markdown,
    [Parameter(Mandatory = $true)][string]$Heading
  )

  $escapedHeading = [regex]::Escape($Heading)
  $match = [regex]::Match(
    $Markdown,
    "(?ms)^##\s+$escapedHeading\s*\r?\n(?<body>.*?)(?=^##\s+|\z)"
  )

  if ($match.Success) {
    return $match.Groups['body'].Value.Trim()
  }

  return ""
}

function Read-ListingDraft {
  param([string]$Path)

  $resolvedPath = Resolve-LocalPath $Path
  if (-not (Test-Path -LiteralPath $resolvedPath)) {
    Write-Host "Listing markdown not found at $resolvedPath; only release notes will be updated."
    return $null
  }

  $markdown = Get-Content -LiteralPath $resolvedPath -Raw
  $featuresSection = Get-MarkdownSection -Markdown $markdown -Heading "Feature List"
  $features = @(
    $featuresSection -split '\r?\n' |
        ForEach-Object {
          if ($_ -match '^\s*-\s+(.+?)\s*$') {
            $matches[1].Trim()
          }
        } |
        Where-Object { $_ }
  )
  $keywordsSection = Get-MarkdownSection -Markdown $markdown -Heading "Keywords"
  $keywords = @(
    $keywordsSection -split '\r?\n' |
        ForEach-Object {
          if ($_ -match '^\s*-\s+(.+?)\s*$') {
            $matches[1].Trim()
          }
        } |
        Where-Object { $_ }
  )

  $listing = [pscustomobject]@{
    ShortDescription = Get-MarkdownSection -Markdown $markdown -Heading "Short Description"
    Description = Get-MarkdownSection -Markdown $markdown -Heading "Full Description"
    Features = $features
    Keywords = $keywords
  }

  if ($listing.ShortDescription.Length -gt 1000) {
    throw "Short Description is $($listing.ShortDescription.Length) characters; Store limit is 1000."
  }
  if ($listing.Description.Length -gt 10000) {
    throw "Full Description is $($listing.Description.Length) characters; Store limit is 10000."
  }
  if ($listing.Features.Count -gt 20) {
    throw "Feature List has $($listing.Features.Count) items; Store limit is 20."
  }
  foreach ($feature in $listing.Features) {
    if ($feature.Length -gt 200) {
      throw "Feature '$feature' is $($feature.Length) characters; Store feature limit is 200."
    }
  }
  if ($listing.Keywords.Count -gt 7) {
    throw "Keywords has $($listing.Keywords.Count) items; Store search term limit is 7."
  }
  foreach ($keyword in $listing.Keywords) {
    if ($keyword.Length -gt 30) {
      throw "Keyword '$keyword' is $($keyword.Length) characters; Store search term limit is 30."
    }
  }

  return $listing
}

function Invoke-GitOutput {
  param(
    [Parameter(Mandatory = $true)][string[]]$Arguments,
    [switch]$AllowFailure
  )

  $output = & git @Arguments 2>$null
  if ($LASTEXITCODE -ne 0) {
    if ($AllowFailure) {
      return $null
    }

    throw "git $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
  }

  return $output
}

function Format-ReleaseNoteSubject {
  param([string]$Subject)

  $formatted = ($Subject -replace '\s+', ' ').Trim()
  $formatted = [regex]::Replace($formatted, '\bwasm\b', 'WebAssembly', 'IgnoreCase')
  $formatted = [regex]::Replace($formatted, '\bui\b', 'UI', 'IgnoreCase')
  $formatted = [regex]::Replace($formatted, '\botp\b', 'OTP', 'IgnoreCase')
  $formatted = [regex]::Replace($formatted, '\btotp\b', 'TOTP', 'IgnoreCase')
  $formatted = [regex]::Replace($formatted, '\bhotp\b', 'HOTP', 'IgnoreCase')

  if ($formatted.Length -gt 0 -and $formatted[0] -cmatch '[a-z]') {
    $formatted = $formatted.Substring(0, 1).ToUpperInvariant() + $formatted.Substring(1)
  }

  return $formatted
}

function Get-ReleaseNotes {
  param(
    [string]$FromRef,
    [string]$ToRef,
    [int]$MaxCharacters
  )

  $insideWorkTree = Invoke-GitOutput -Arguments @('rev-parse', '--is-inside-work-tree') -AllowFailure
  if (-not $insideWorkTree) {
    return "Bug fixes and improvements."
  }

  $resolvedFromRef = $FromRef.Trim()
  if (-not $resolvedFromRef) {
    $resolvedFromRef = Invoke-GitOutput -Arguments @('describe', '--tags', '--abbrev=0', "$ToRef^") -AllowFailure
  }
  if (-not $resolvedFromRef) {
    $resolvedFromRef = Invoke-GitOutput -Arguments @('describe', '--tags', '--abbrev=0', $ToRef) -AllowFailure
  }

  $range = if ($resolvedFromRef) { "$resolvedFromRef..$ToRef" } else { $ToRef }
  $subjects = @(
    Invoke-GitOutput -Arguments @('log', '--no-merges', '--format=%s', '--reverse', $range) -AllowFailure |
        ForEach-Object { Format-ReleaseNoteSubject $_ } |
        Where-Object { $_ -and ($_ -notmatch '^Release\s+v?\d+(\.\d+)*') }
  )
  $subjects = @($subjects | Select-Object -Unique)

  if ($subjects.Count -eq 0) {
    $subjects = @('Bug fixes and improvements.')
  }

  $lines = @($subjects | ForEach-Object { "- $_" })
  $selected = New-Object System.Collections.Generic.List[string]

  foreach ($line in $lines) {
    $candidateLines = @($selected) + $line
    $candidate = $candidateLines -join [Environment]::NewLine
    if ($candidate.Length -le $MaxCharacters) {
      $selected.Add($line) | Out-Null
    }
    elseif ($selected.Count -eq 0) {
      return $line.Substring(0, [Math]::Min($line.Length, $MaxCharacters))
    }
    else {
      break
    }
  }

  return (@($selected) -join [Environment]::NewLine)
}

function Get-MapEntry {
  param(
    [Parameter(Mandatory = $true)]$Map,
    [Parameter(Mandatory = $true)][string]$PreferredName
  )

  $properties = @($Map.PSObject.Properties)
  if ($properties.Count -eq 0) {
    return $null
  }

  $entry = $properties | Where-Object { $_.Name -ieq $PreferredName } | Select-Object -First 1
  if (-not $entry -and $PreferredName -ieq 'en-us') {
    $entry = $properties | Where-Object { $_.Name -ieq 'en' } | Select-Object -First 1
  }
  if (-not $entry) {
    $entry = $properties | Where-Object { $_.Name -like 'en*' } | Select-Object -First 1
  }
  if (-not $entry) {
    $entry = $properties | Select-Object -First 1
  }

  return $entry
}

function Get-ArrayListing {
  param(
    [Parameter(Mandatory = $true)]$Listings,
    [Parameter(Mandatory = $true)][string]$PreferredLanguage
  )

  $items = @($Listings)
  if ($items.Count -eq 0) {
    return $null
  }

  $entry = $items |
      Where-Object {
        $language = Get-JsonProperty -InputObject $_ -Name 'language'
        $language -and ($language.Value -ieq $PreferredLanguage)
      } |
      Select-Object -First 1

  if (-not $entry -and $PreferredLanguage -ieq 'en-us') {
    $entry = $items |
        Where-Object {
          $language = Get-JsonProperty -InputObject $_ -Name 'language'
          $language -and ($language.Value -ieq 'en')
        } |
        Select-Object -First 1
  }
  if (-not $entry) {
    $entry = $items |
        Where-Object {
          $language = Get-JsonProperty -InputObject $_ -Name 'language'
          $language -and ($language.Value -like 'en*')
        } |
        Select-Object -First 1
  }
  if (-not $entry) {
    $entry = $items | Select-Object -First 1
  }

  return $entry
}

function Apply-PackagedMetadata {
  param(
    [Parameter(Mandatory = $true)]$Metadata,
    $ListingDraft,
    [Parameter(Mandatory = $true)][string]$ReleaseNotes,
    [Parameter(Mandatory = $true)][string]$Language
  )

  $listingsProperty = $Metadata.PSObject.Properties |
      Where-Object { $_.Name -ceq 'Listings' } |
      Select-Object -First 1
  if (-not $listingsProperty) {
    return $false
  }
  if ($listingsProperty.Value -is [array]) {
    return $false
  }

  $listingEntry = Get-MapEntry -Map $listingsProperty.Value -PreferredName $Language
  if (-not $listingEntry) {
    throw "No listing entries found in packaged metadata."
  }

  $baseListing = Ensure-JsonObjectProperty -InputObject $listingEntry.Value -Name 'BaseListing'
  Set-JsonProperty -InputObject $baseListing -Name 'ReleaseNotes' -Value $ReleaseNotes

  if ($ListingDraft) {
    if ($ListingDraft.Description) {
      Set-JsonProperty -InputObject $baseListing -Name 'Description' -Value $ListingDraft.Description
    }
    if ($ListingDraft.ShortDescription) {
      Set-JsonProperty -InputObject $baseListing -Name 'ShortDescription' -Value $ListingDraft.ShortDescription
    }
    if ($ListingDraft.Features.Count -gt 0) {
      Set-JsonProperty -InputObject $baseListing -Name 'Features' -Value @($ListingDraft.Features)
    }
    if ($ListingDraft.Keywords.Count -gt 0) {
      Set-JsonProperty -InputObject $baseListing -Name 'Keywords' -Value @($ListingDraft.Keywords)
    }
  }

  Write-Host "Updated packaged listing '$($listingEntry.Name)' with release notes."
  return $true
}

function Apply-StoreMetadata {
  param(
    [Parameter(Mandatory = $true)]$Metadata,
    $ListingDraft,
    [Parameter(Mandatory = $true)][string]$ReleaseNotes,
    [Parameter(Mandatory = $true)][string]$Language
  )

  $payload = $Metadata
  $responseData = Get-JsonProperty -InputObject $Metadata -Name 'responseData'
  if ($responseData -and $responseData.Value) {
    $payload = $responseData.Value
  }

  $listingsProperty = Get-JsonProperty -InputObject $payload -Name 'listings'
  if (-not $listingsProperty) {
    return $false
  }

  $listings = $listingsProperty.Value
  $listing = if ($listings -is [array]) {
    Get-ArrayListing -Listings $listings -PreferredLanguage $Language
  }
  else {
    $entry = Get-MapEntry -Map $listings -PreferredName $Language
    if ($entry) { $entry.Value } else { $null }
  }

  if (-not $listing) {
    throw "No listing entries found in Store metadata."
  }

  Set-JsonProperty -InputObject $listing -Name 'whatsNew' -Value $ReleaseNotes

  if ($ListingDraft) {
    if ($ListingDraft.Description) {
      Set-JsonProperty -InputObject $listing -Name 'description' -Value $ListingDraft.Description
    }
    if ($ListingDraft.ShortDescription) {
      Set-JsonProperty -InputObject $listing -Name 'shortDescription' -Value $ListingDraft.ShortDescription
    }
    if ($ListingDraft.Features.Count -gt 0) {
      Set-JsonProperty -InputObject $listing -Name 'productFeatures' -Value @($ListingDraft.Features)
    }
    if ($ListingDraft.Keywords.Count -gt 0) {
      $keywordsProperty = Get-JsonProperty -InputObject $listing -Name 'keywords'
      $searchTermsProperty = Get-JsonProperty -InputObject $listing -Name 'searchTerms'
      if ($keywordsProperty) {
        Set-JsonProperty -InputObject $listing -Name $keywordsProperty.Name -Value @($ListingDraft.Keywords)
      }
      elseif ($searchTermsProperty) {
        Set-JsonProperty -InputObject $listing -Name $searchTermsProperty.Name -Value @($ListingDraft.Keywords)
      }
    }
  }

  Write-Host "Updated Store metadata listing for '$Language' with release notes."
  return $true
}

$resolvedMetadataPath = Resolve-LocalPath $MetadataPath
$resolvedOutputPath = Resolve-LocalPath $OutputPath

if (-not (Test-Path -LiteralPath $resolvedMetadataPath)) {
  throw "Metadata file not found: $resolvedMetadataPath"
}

$metadata = Get-Content -LiteralPath $resolvedMetadataPath -Raw | ConvertFrom-Json
$listingDraft = Read-ListingDraft -Path $ListingMarkdownPath
$releaseNotes = Get-ReleaseNotes `
  -FromRef $ReleaseNotesFromRef `
  -ToRef $ReleaseNotesToRef `
  -MaxCharacters $ReleaseNotesMaxCharacters

if ($releaseNotes.Length -gt $ReleaseNotesMaxCharacters) {
  throw "Generated release notes are $($releaseNotes.Length) characters; Store limit is $ReleaseNotesMaxCharacters."
}

$updated = Apply-PackagedMetadata `
  -Metadata $metadata `
  -ListingDraft $listingDraft `
  -ReleaseNotes $releaseNotes `
  -Language $ListingLanguage

if (-not $updated) {
  $updated = Apply-StoreMetadata `
    -Metadata $metadata `
    -ListingDraft $listingDraft `
    -ReleaseNotes $releaseNotes `
    -Language $ListingLanguage
}

if (-not $updated) {
  throw "Metadata JSON did not contain a supported Listings/listings shape."
}

$json = $metadata | ConvertTo-Json -Depth 100
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($resolvedOutputPath, $json + [Environment]::NewLine, $utf8NoBom)

if ($ReleaseNotesOutputPath) {
  $resolvedReleaseNotesOutputPath = Resolve-LocalPath $ReleaseNotesOutputPath
  [System.IO.File]::WriteAllText($resolvedReleaseNotesOutputPath, $releaseNotes + [Environment]::NewLine, $utf8NoBom)
}

Write-Host ""
Write-Host "Release notes:"
Write-Host $releaseNotes
Write-Host ""
Write-Host "Updated metadata written to $resolvedOutputPath"

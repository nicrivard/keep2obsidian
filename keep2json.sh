Get-ChildItem .\Downloads\Keep -Filter *.json | Foreach-Object {

    # get the contents of the .JSON file and convert it to a Power Shell Custom Object called $a
    $a = Get-Content $_.FullName | ConvertFrom-Json
    
    # convert Google Keep's epoch time to a human-readable format
    function Date-Convert{
        $unixTime = $a.userEditedTimestampUsec.ToString()
        $dateTime = $unixTime.Substring(0, $unixTime.Length-6) # removing the microseconds so string is "yymmddhhmm"
        [datetime]$origin = '1970-01-01 00:00:00'
        return $origin.AddSeconds($dateTime) | Get-Date -Format "yyMMdd dddd" # desired date format 
    } 

    # extract Google Keep source url information into []() format
    function Create-Url{
        return "[" + $a.annotations.title + "]" + "(" + $a.annotations.url + ")"
    }

    # create an empty Power Shell Custom Object called $info
    $info = "" | Select fileName, Title, Date, Content, Labels, Url

    # fill $info with data from $a
    $info.fileName = $a.title -replace '[~#%&*{}|:<>?/|"]' # make the file name readable
    $info.Title = $a.title
    $info.Content = $a.textContent
    $info.Labels = $a.labels.name | ForEach-Object {"#$_"} # tags
    $info.Date = Date-Convert
    $info.Url = Create-Url

    # create the string and output the content to a new file
    $text = "# " + $info.Title + "`n" + "`n" + 
    $info.Content + "`n" + "`n" + 
    "---" + "`n" + 
    "Tags: " + $info.Labels + "`n" + 
    "References: " + "[[" + $info.Date + "]]" + " " + $info.Url 

    # create a new file in a separate folder
    New-Item -Path .\Downloads\Keep-new -Name $info.fileName -ItemType "file" -Value $text
}

# rename all files in the directory to .md 
Get-ChildItem .\Downloads\Keep-new | Rename-Item -NewName { $_.Name + '.md' }

# display results
Get-ChildItem .\Downloads\Keep-new\*.md
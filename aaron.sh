#aaron script
#!/bin/bash

###Check args###
NAME="${1:?Missing argument: Company name}"

createOutput() {
	###Create CSV and print header line###
	printf "Organization, Customer, Cusomter Name, Address, City, State, Postal Code, Country, NetHandle, NetRange, CIDR\n" >> ArinNetworks.csv
}

###Initialize -- https://stackoverflow.com/questions/20294918/extract-file-contents-into-array-using-bash###
getArray() {
    array=() # Create array
    while IFS= read -r line # Read a line
    do
        array+=("$line") # Append line to the array
    done < "$1"
}

###Run arin against the argument###
runArinNetworks() {
	echo "[+] Building ArinNetworks.csv ... "
	sleep 2s

	###Perform secondary search based on returned NetworkIDs###
	getArray "working/NetworkIDs"
	for e in "${array[@]}"
	do
		###Create a working file for networkInfo###
		whois -h whois.arin.net n ! "$e" >> working/networkInfo
		echo "[+] Getting info for: $e"

		###Grep for and add Customer to CSV if it exists###
		ORG=$(sed -n -e '/Organization:/p' working/networkInfo | cut -d ' ' -f4- | tr ',' ';' | tr -d "\n")
		
		### Determine if CUST is not empty and populate CSV###
		if [ -z "$ORG" ]
		then
	    	printf "," >> ArinNetworks.csv
	    else
	    	printf "$ORG" >> ArinNetworks.csv
	    	printf "," >> ArinNetworks.csv
		fi

		###Grep for and add Customer to CSV if it exists###
		CUST=$(sed -n -e '/Customer:/p' working/networkInfo | cut -d ' ' -f8- | tr ',' ';' | tr -d "\n")
		
		### Determine if CUST is not empty and populate CSV###
		if [ -z "$CUST" ]
		then
	    	printf "," >> ArinNetworks.csv
	    else
	    	printf "$CUST" >> ArinNetworks.csv
	    	printf "," >> ArinNetworks.csv
		fi

		sed -n -e '/CustName:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		sed -n -e '/Address:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		sed -n -e '/City:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		sed -n -e '/StateProv:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		sed -n -e '/PostalCode:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		sed -n -e '/Country:/p' working/networkInfo | cut -d ' ' -f2- | sed -e 's/^[ \t]*//' | tr ',' ';' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		###sed and pull the NetHandle from netwrokInfo###
		sed -n -e '/NetHandle:/p' working/networkInfo | cut -d ' ' -f2- | tr ',' ';' | sed 's/ //g' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv

		###sed and pull the NetRange from netwrokInfo###
		sed -n -e '/NetRange:/p' working/networkInfo | cut -d ' ' -f8- | tr ',' ';' | sed 's/ //g' | tr -d "\n" >> ArinNetworks.csv
		printf "," >> ArinNetworks.csv
		
		###sed and pull the CIDR from networkInfo###
		sed -n -e '/CIDR:/p' working/networkInfo | cut -d ' ' -f12- | tr ',' ';' | sed 's/ //g' | sed 's/^/"/;s/$/"/' | tr ";" "\n" >> ArinNetworks.csv

		###Cleanup -- Delete last networkInfo###
		rm working/networkInfo
	done
}

###Not used###
runArinOrgs() {
	###Perform secondary search based on returned NetworkIDs###
	getArray "working/Orgs"
	for e in "${array[@]}"
	do

		FIELD=$(echo "$e" | head -n 1 | awk '{print NF}')
		orgID=$(echo "$e" | cut -d" " -f "$FIELD"- | sed 's/(//g' | sed 's/)//g')

		###Create a working file for networkInfo###
		whois -h whois.arin.net o ! "$e" >> working/orgInfo
	done
}

echo ""
echo "#########################################"
echo "###### -- AARON SCRIPT STARTED --- ######"
echo "#########################################"
echo ""

###Make a new directory to store output files###
mkdir working

###Perform initial search###
whois -h whois.arin.net e / "$NAME" > working/arinlookup
cat working/arinlookup | grep "(NET" | cut -d"(" -f3 | cut -d")" -f1 >> working/NetworkIDs
cat working/arinlookup | grep ")$" >> ArinOrgs.txt
echo "[+] Adding organizations to ArinOrgs.txt"
sleep 2s
cat "ArinOrgs.txt"
echo ""

FILE=ArinNetworks.csv
if test -f "$FILE"
then
    #echo "$FILE exist"
    runArinNetworks
else
	createOutput
	runArinNetworks
fi

###Cleanup -- Delete working directory###
rm -r working
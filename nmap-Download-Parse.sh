#!/bin/bash
echo    "########## Downloading GNX and gnmap-parser tools to this directory ############"
wget https://bitbucket.org/memoryresident/gnxtools/raw/fde3449ff2756686e001ac4f7a45849a187f3710/gnxparse.py &> /dev/null
wget https://bitbucket.org/memoryresident/gnxtools/raw/fde3449ff2756686e001ac4f7a45849a187f3710/gnxmerge.py &> /dev/null
wget https://raw.githubusercontent.com/royharoush/rtools/master/gnmap-parser.sh &> /dev/null
now=$(date +"%d-%m-%y"-"%T" |tr ":" "-" | cut -d"-" -f1,2,3,4,5)
mkdir Results-$now
echo    "########## Download Complete ############"
echo    "########## GNX Nmap Tools Are Now Inside Your Directory ############"
echo    "########## Modified Gnmap-Parser is now Inside Your Directory ############"
echo ##### This can be used to remove files that don't have any open ports 
echo #find -name '*.xml'   | xargs -I{} grep -LZ "state=\"open\"" {} | while IFS= read -rd '' x; do mv "$x" "$x".empty ; done 
echo #find -name '*.xml' -exec grep -LZ "state=\"open\"" {} + |  perl -n0e 'rename("$_", "$_.empty")'
echo "I will now parse all your XMLs into one file called gnx-merged-$now.xml" 
python gnxmerge.py -s ./  > gnx-merged-$now.xml
echo "I will now create the outputs of your scans from the XML file" 
python gnxparse.py gnx-merged-$now.xml -i -p -s -r -c >> gnx-output_all-$now.csv 
python gnxparse.py gnx-merged-$now.xml -p >> gnx-Open-Ports.txt 
python gnxparse.py gnx-merged-$now.xml -i >> gnx-Live-IPs.txt
python gnxparse.py gnx-merged-$now.xml -s >> gnx-Subnets.txt 
python gnxparse.py gnx-merged-$now.xml -c >> gnx-Host-Ports-Matrix.csv  
python gnxparse.py gnx-merged-$now.xml -r 'nmap -A ' >> ./gnx-suggested_scans-$now.sh
echo "########All Done, Merged XML is in gnx-merged-$now.xml########"
echo "########Scan data can be found in gnx* files########" 
echo "############parsing Gnmap files##########"
find . -maxdepth 1 -type f -name '*.gnmap' -print0 |  sort -z |  xargs -0 cat -- >> ./Results-$now/gnmap-merged.gnmap
echo "############parsing Gnmap files##########"
mv gnmap-parser.sh ./Results-$now
cd Results-$now
bash gnmap-parser.sh -p
mv ../gnx* ./
#cd Results-$now
cat ./Results-$now/Parsed-Results/Host-Lists/Alive-Hosts-Open-Ports.txt > Gnmap-LiveHosts.txt
cat ./Results-$now/Parsed-Results/Port-Lists/TCP-Ports-List.txt  | tr "\n" "," > Gnmap-OpenPorts.txt
echo "#### Downloading nmapParse.sh####"
#https://raw.githubusercontent.com/royharoush/rtools/master/nmapParse.sh &> /dev/null
#echo "#### To parse again run 'bash nmapParse.sh' ####"
echo "I like wearing flip flops!"
ls ./Results-$now -latr | tail -n 10
#rm -- "$0"

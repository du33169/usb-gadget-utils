# convert Descriptor.h file to binary file
descFile=$1
targetFile=$2
sourceFile=c2bin.c
executable=c2bin

print_usage()
{
	echo "Descriptor Convert Scrpt

Usage: 
	./convert.sh [desc] [binary]
	
	  desc:    the .h file generated be descTool.  for example, 'mouse.h'
	binary:    the target .bin filename to output. for example, 'mouse-descriptor.bin'
"
}
clean()
{
	rm $sourceFile $executable >/dev/null 2>/dev/null
}
fail()# $1=fail_text
{
	echo $1
	clean
	exit 1
}
#check input
if [ ! -e "$descFile" ] ; then 
	print_usage
	fail "[Err] desc file <$descFile> not found."
fi
if [ -z "$targetFile" ] ; then 
	print_usage
	fail "[Err] target file not specified."
fi
cat <<EOF > $sourceFile
#include"${descFile}"
#include<stdio.h>
int main()
{
	FILE *f = fopen("${targetFile}", "wb");
	fwrite(ReportDescriptor, sizeof(char), 50, f);
	fclose(f);
	return 0;
}
EOF

gcc $sourceFile -o $executable || fail "[Err] compile failed."
./$executable || fail "[Err] execute failed."

if [ ! -e "$targetFile" ]; then
	fail "[Err] $targetFile not created."
else 
	#success
	echo "Successfully generated $targetFile. 
You can use 'hexdump $targetFile -C' to check its content."
fi
clean

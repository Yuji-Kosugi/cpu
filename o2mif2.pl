# perl o2mif.pl filename size


$NUM_WORDS = $ARGV[1];

$filename = $ARGV[0];

if ($filename !~ /.*\.o/){
	 die "Error: not .o file\n";
}

open(IN, "objdump -d $filename |");

$out = substr($filename,0,length($filename)-2);

#$out = substr($filename,0,length($filename)-2);

#open(OUT, ">$out.mif");
open(OUT, ">insn.mif");
print(OUT "WIDTH=32;\nDEPTH=$NUM_WORDS;\n\nADDRESS_RADIX=UNS;\nDATA_RADIX=HEX;\nCONTENT BEGIN\n");

$n=0;
$byte=0;
$i=1;
$skip=0;

while(<IN>){

	
	if ($skip == 1){
		$skip=0;
		next;
	}
	
	if ( $_ =~ /:\t/ ) {
		
		if($byte == 0 ){
			print(OUT " $n : ");
		}
		
		$_1 = substr($_,6,2);
		$_2 = substr($_,9,2);
		$_3 = substr($_,12,2);
		$_4 = substr($_,15,2);
		
		$_5 = substr($_,18,2);
		if($_5 !~ /\s/){
			die "Error: 5bytes instruction\n $_";
		}
		
		# zSLL, zSLA, zSRL,zSRA
		if( $_1 =~ /d1/ ) {
			print(OUT "c1");
		} else {
			print(OUT "$_1");
		}
		$byte++;
		
		# zLD
		if( $_1 =~ /8b/ && substr($_,35,1) =~ /\(/) {
			$tmp = hex(substr($_,9,1)) + 4;
			$tmp = sprintf "%X", $tmp;
			print(OUT "$tmp");
			$tmp = substr($_,10,1);
			print(OUT "$tmp");
			print(OUT "00");
			$byte += 2;
			$skip=1;
			next;
		}
		# zST
		if( $_1 =~ /89/ && substr($_,40,1) =~ /\(/) {
			$tmp = hex(substr($_,9,1)) + 4;
			$tmp = sprintf "%X", $tmp;
			print(OUT "$tmp");
			$tmp = substr($_,10,1);
			print(OUT "$tmp");
			print(OUT "00");
			$byte += 2;
			$skip=1;
			next;
		}
		
		if($_2 !~ /\s/ && $byte < 4){
			print(OUT "$_2");
			$byte++;
		}
		
		# zSLL, zSLA, zSRL,zSRA
		if( $_1 =~ /d1/) {
			print(OUT "00");
			$byte++;
			$skip=1;
			next;
		}
		
		if($_3 !~ /\s/ && $byte < 4){
			print(OUT "$_3");
			$byte++;
		}
		if($_4 !~ /\s/ && $byte < 4){
			print(OUT "$_4");
			$byte++;
		}
		if($byte == 4){
			print(OUT ";\n");
			$byte=0;
			$n++;
		}
	}
}

$NUM_WORDS--;
if(n == $NUM_WORDS){
	print(OUT "$NUM_WORDS : 00000000;\n");
} elsif($n < $NUM_WORDS){
	print(OUT "[$n..$NUM_WORDS] : 00000000;\n");
} else {
	die "Error: insufficient size\n";
}
print(OUT "END;\n");

close(OUT);
close(IN);

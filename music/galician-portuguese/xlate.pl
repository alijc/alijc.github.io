#!/usr/bin/perl 
use strict;

# Data used for conjugating verbs.
my @person = ( "I", "thou", "one", "we", "you", "they" );
my @tense = ( "=",				# Presente						Indicativo
			  "was.=-ing",		# Imperfecto					Indicativo
			  "will.=",			# Futuro						Indicativo
			  "did.=",			# Pretérito perfecto			Indicativo
			  "had.=-ed",		# Pretérito pluscuamperfecto	Indicativo
			  "would.=",		# Presente						Subxuntivo
			  "would.have.=-ed",# Imperfecto					Subxuntivo
			  "should.=",		# Futuro						Subxuntivo
			  "might.=",		# Futuro hipotético				(Condicional)
			  "=!!",			# Imperativo
			  "to.="			# Infinitivo Conxugado
);

my %ar = (
	finite => [
	[ qw{ o    as    a    amos    ades    an    } ],	# Present
	[ qw{ ava  avas  ava  avamos  avades  avan  } ],	# Imperfect
	[ qw{ arei arás  ará  aremos  aredes  arán  } ],	# Futuro			  
	[ qw{ ei   aste  ou   amos    astes   aron  } ],	# perfecto  
	[ qw{ ara  aras  ara  aramos  arades  aran  } ],	# pluperfect
	[ qw{ e    es    e    emos    edes    en    } ],	# Presente Subxuntivo
	[ qw{ asse asses asse assemos assedes assen } ],	# Imperfecto Subxuntivo
	[ qw{ X    ares  X    armos   ardes   aren  } ],	# Futuro Subxuntivo
	[ qw{ aria arias aria ariamos ariades arian } ],	# Condicional ((í))
	[ qw{ X    a     e    emos    ade     en    } ],	# Imperativo
	[ qw{ X    ares  X    armos   ardes   aren  } ],	# Infinitive
	],
	gerund => "ando",
	pp => [ "ado", "" ]
	);

my %er = (
	"finite" => [
	[ qw{ o    es    e    emos    edes    en    } ],	# Present
	[ qw{ ia   ias   ia   iamos   iades   ian   } ],	# Imperfect
	[ qw{ erei erás  erá  eremos  eredes  erán  } ],	# Futuro			  
	[ qw{ i    iste  eu   emos    estes   eron  } ],	# perfecto  
	[ qw{ era  eras  era  eramos  erades  eran  } ],	# pluperfect
	[ qw{ a    as    a    amos    ades    an    } ],	# Presente Subxuntivo
	[ qw{ esse esses esse essemos essedes essen } ],	# Imperfecto Subxuntivo
	[ qw{ X    eres  X    ermos   erdes   eren  } ],	# Futuro Subxuntivo
	[ qw{ eria erias eria eriamos eriades erian } ],	# Condicional ((í))
	[ qw{ X    e     a    amos    ede     an    } ],	# Imperativo
	[ qw{ X    eres  X    ermos   erdes   eren  } ],	# Infinitive
	],
	gerund => "endo",
	pp => [ "ido", "udo" ]
	);

my %ir = (
	"finite" => [
	[ qw{ o    es    e    imos    ides    en    } ],	# Present
	[ qw{ ia   ias   ia   iamos   iades   ian   } ],	# Imperfect
	[ qw{ irei irás  irá  iremos  iredes  irán  } ],	# Futuro			  
	[ qw{ i    iste  iu   imos    istes   iron  } ],	# perfecto  
	[ qw{ ira  iras  ira  iramos  irades  iran  } ],	# pluperfect
	[ qw{ a    as    a    amos    ades    an    } ],	# Presente Subxuntivo
	[ qw{ isse isses isse issemos issedes issen } ],	# Imperfecto Subxuntivo
	[ qw{ X    ires  X    irmos   irdes   iren  } ],	# Futuro Subxuntivo
	[ qw{ iria irias iria iriamos iriades irian } ],	# Condicional ((í))
	[ qw{ X    e     a    amos    ide     an    } ],	# Imperativo
	[ qw{ X    ires  X    irmos   irdes   iren  } ],	# Infinitive
	],
	gerund => "indo",
	pp => [ "ido", "udo" ]
	);

my %conjugations = ( ar => \%ar, er => \%er, ir => \%ir );

my $line;
my %dict;

# Populate our dictionary
my $VOCAB = "./vocab.txt";
open VOCAB, $VOCAB or die "couldn't open $VOCAB\n";
my @vocab = <VOCAB>;

# First find the 'normal' words, ie. those without a Viz field
foreach $line (@vocab) {
    my @tmp = split /,/, $line;	# re-fontify => /,
	$tmp[0] =~ s/\s+//;			# PG word
	$tmp[1] =~ s/\s*$// if ($tmp[1]) ;	# optional Viz., pointing to correct sp.
	if ( $#tmp > 1  &&  $tmp[1] eq "" ) {
		chomp $tmp[2];			# Eng translation
		$tmp[2] =~ s/\s*$//;
		add_word( "|", $tmp[0], $tmp[2] );
		if ( $#tmp > 2 ) {
			if	  ($tmp[3] eq "v") { conjugate( $tmp[0], $tmp[2] ); }
			elsif ($tmp[3] eq "V") { conjugate_irr( $tmp[0], $tmp[2] ); }
			elsif ($tmp[3] eq "a") { decline( $tmp[0], $tmp[2] ); }
			elsif ($tmp[3] eq "n") { pluralize( $tmp[0], $tmp[2] ); }
		}
    }
}

# Now find the words with viz'es and use the definitions that they point to
foreach $line (@vocab) {
	my @tmp = split /,/, $line;
	$tmp[0] =~ s/\s+//;		# PG word
	$tmp[1] =~ s/\s*$//;	# optional Viz.
	if ( $tmp[1] ne "" ) {
		my @words = split /[\s-]+/, $tmp[1];
		my $word;

		# Replace each word with English
		foreach $word (@words) {
			add_word( ".", $tmp[0], $dict{$word} );
		}
	}
}

# Extract the 'W:' lines from the file, removing the 'W:'
my @text = grep s/^W://, <>;

foreach $line (@text) {

	print "W:$line";	# Print the original line, restoring the 'W:'.
	print "% ";			# Start out the next line with a comment mark.

	# Make sure that all contractions are separated by spaces.
	$line =~ s/'/' /g;

	# Remove the editorial marks for inserted characters
	$line =~ s/\[//;
	$line =~ s/\]//;

	# Split the line into words.
	my @words = split /[\s-]+/, $line;
	my $word;

	# Replace each word with English (if it's in the dictionary).
	foreach $word (@words) {
		$word =~ tr/A-Z/a-z/;		# switch to lowercase
		$word =~ tr/y/i/;			# turn all y's into i's
		$word =~ tr/í/i/;			# and all í's (acute i's) as well
		$word =~ tr/,.;:«»!|? //d;	# get rid of punctuation (and spaces)

		# Normalize the 'c's before soft vowels.
		$word =~ s/çe/ce/g;
		$word =~ s/çi/ci/g;

		# If it's a contraction, look for all possible expansions.
		if ($word =~ /'$/)	{	#' (defontifying comment)
			my $vowel;
			my $found = 0;
			foreach $vowel ('a','e','o') {
				$word = substr( $word, 0, -1 ).$vowel;
				if ( exists $dict{$word} )	{ 
					if ($found)	{ print "|"; }	# divider after last word found
					print "$dict{$word}";		# this word
					$found = 1;
				}
			}
			if ( ! $found ) {
				$word = substr( $word, 0, -1 )."'";
				print "#$word#";
			}
			print " ";
			next;
		}

		if ( 0 != length $word ) {
			if ( exists $dict{$word} )	{ print "$dict{$word} "; }
			else						{ print "#$word# "; }
		}
	}

	print "\n\n";
}


# Starting with the infinitive, create a definition for each
# person & number, and tense & mood, for all 3 conjugations.
sub conjugate
{
	my ( $port, $eng ) = @_;
	my $base   = substr $port, 0, -2;
	my $suffix = substr $port, -2, 2;
	$eng =~ s/to\.//g;

	return if ( ! exists $conjugations{$suffix} );

	my $conj = $conjugations{$suffix};

	# finite verbal forms
	my ( $tense, $person );
	for $tense ( 0 .. 10 ) {
		for $person ( 0 .. 5 ) {
			my $ending = $$conj{finite}[$tense][$person];
			if ( $ending ne "X" ) {
				$port = adjust( $suffix, $base, $ending );
				my ( $before, $after ) = split /=/, $tense[$tense];	#/
				my $x = "${person[$person]}.$before$eng$after";
				add_word( "|", $port, $x );
			}
		}
	}

	# gerund (present participle
	$port = $base . $$conj{gerund};
	add_word( "|", $port, "${eng}-ing" );

	# past participle
	my ( $pp, $x );
	for $pp ( 0 .. 1 ) {
		if ( $$conj{pp}[$pp] ne "" ) {
			$port = adjust( $suffix, $base, $$conj{pp}[$pp] );
			$x = "${eng}-en";
			add_word( "|", $port, "$x" );
			decline( $port, "$x" );
		}
	}
}

# Starting with the infinitive, conjugate an irregular verb.
sub conjugate_irr
{
	my ( $port, $eng ) = @_;
	my $base   = substr $port, 0, -2;
	my $suffix = substr $port, -2, 2;
	$eng =~ s/to\.//g;

my %aver = (
	"finite" => [
	[ qw{ ei      ás       á       R          R          an    } ],	# Present
	[ qw{ R		  R        R       R          R          R     } ],	# Imperfect
	[ qw{ R       R        R       R          R          R     } ],	# Futuro
	[ qw{ ouve    ouveste  ouve    ouvemos    ouvestes  ouvesen } ],# perfecto  
	[ qw{ ouvera  ouveras  ouvera  ouveramos  ouverades ouveron } ],# pluperfect
	[ qw{ aia     aias     aia     aiamos     aiades     aian    } ],# PresSub
	[ qw{ ouvesse ouvesses ouvesse ouvessemos ouvessedes ouvessen } ],# ImpSub
	[ qw{ ouver   ouveres  ouver   ouvermos   ouverdes   ouveren  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       ha       aia     aiamos     R          aian  } ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "avendo",
	pp => [ "avido", "avudo" ]
	);
my %dar = (
	"finite" => [
	[ qw{ dou     dás      dá      R          R          R   } ],	# Present
	[ qw{ R	      R        R       R          R          R   } ],	# Imperfect
 	[ qw{ R       R        R       R          R          R   } ],	# Futuro
	[ qw{ R       disti    deu     demos    destes     deron } ],# perfecto  
	[ qw{ dera    deras    dera    deramos  derades deran } ],# pluperfect
	[ qw{ dé      deas     dé      deamos   dedes     dean    } ],# PresSub
	[ qw{ desse   desses   desse   dessemos dessedes dessen } ],# ImpSub
	[ qw{ der     deres    der     dermos   derdes   deren  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       dá       dea     deamos     R          dean  } ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "dando",
	pp => [ "dado", "" ]
	);
my %dizer = (
	"finite" => [
	[ qw{ digo    dis      diz     R          R          R  } ],	# Present
	[ qw{ R		  R        R       R          R          R   } ],	# Imperfect
	[ qw{ direi   dirás    dirá    diremos  diredes    dirán } ],	# Futuro
	[ qw{ disse   dissiste disse   dissemos dissestes  disseron } ],# perfecto  
	[ qw{ dissera disseras dissera disseramos disserades disseran}],# pluperfect
	[ qw{ diga    digas    diga    digamos  digades  digan  } ],#  PresSub
	[ qw{ dissesse dissesses dissesse dissessemos dissessedes dissessen}],#ImpSb
	[ qw{ disser  disseres disser  dissermos disserdes disseren  } ],# FutSub
	[ qw{ diria   dirias   diria   diriamos  diriades  dirian } ],# Condicional
	[ qw{ X       di       diga    digamos    R         digan  } ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "dizendo",
	pp => [ "dito", "" ]
	);
my %estar = (
	"finite" => [
	[ qw{ estou   estás    está    R          R          estan } ],	# Present
	[ qw{ R		  R        R       R          R          R   } ],	# Imperfect
	[ qw{ R		  R        R       R          R          R   } ],	# Futuro
	[ qw{ estive  estiveste esteve estivemos estivestes estiveron }],# perfecto
	[ qw{ estivera estiveras estivera estiveremos estiverades estiveran}],#plup.
	[ qw{ estea   esteas   estea   esteamos  esteades  estean  } ],#  PresSub
	[ qw{ estivesse estivesses estivesse estivessemos estivessedes estivessen}],#ImpSub
	[ qw{ estiver estiveres estiver estivermos estiverdes estiveren } ],# FutSub
	[ qw{ R		  R        R       R          R          R   } ],	#Condicional
	[ qw{ X       está     estea   esteamos   R          estean } ],# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "estando",
	pp => [ "estado", "" ]
	);
my %fazer = (
	"finite" => [
	[ qw{ faço    R        faz     R          R          R  } ],	# Present
	[ qw{ R		  R        R       R          R          R   } ],	# Imperfect
	[ qw{ farei   farás    fará    faremos    faredes    farán } ],	# Futuro
	[ qw{ fiz     feziste  fez     fezemos    fezestes   fezeron }],# perfecto  
	[ qw{ fezera  fezeras  fezera  fezeramos  fezerades  fezeran}],# pluperfect
	[ qw{ faça    faças    faça    façamos    façades    façan  }],#  PresSub
	[ qw{ fezesse fezesses fezesse fezessemos fezessedes fezessen}],#ImpSb
	[ qw{ fezer   fezeres  fezer   fezermos   fezerdes   fezeren  } ],# FutSub
	[ qw{ faria   farias   faria   fariamos   fariades   farian }],# Condicional
	[ qw{ X       faz      faça    façamos    R          façan  }],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "fazendo",
	pp => [ "feito", "" ]
	);
my %ir = (
	"finite" => [
	[ qw{ vou     vais     vai     R          R          van } ],	# Present
	[ qw{ R		  R        R       R          R          R   } ],	# Imperfect
	[ qw{ R		  R        R       R          R          R   } ],	# Futuro
	[ qw{ fui     foste    foi     fomos      fostes     foron   }],# perfecto  
	[ qw{ fora    foras    fora    foramos    forades    foran  }],# pluperfect
	[ qw{ va      vas      va      vamos      vades      van    }],#  PresSub
	[ qw{ fosse   fosses   fosse   fossemos   fossedes   fossen  }],#ImpSb
	[ qw{ for     fores    for     formos     fordes     foren    } ],# FutSub
	[ qw{ R		  R        R       R          R          R   } ],# Condicional
	[ qw{ X       vai      va      famos      R          van    }],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "indo",
	pp => [ "ido", "" ]
	);
my %poder = (
	"finite" => [
	[ qw{ posso   R        R       R          R          R     } ],	# Present
	[ qw{ R		  R        R       R          R          R     } ],	# Imperfect
	[ qw{ R       R        R       R          R          R     } ],	# Futuro
	[ qw{ pude    podeste  pôde    podemos    podestes  poderon } ],# perfecto  
	[ qw{ podera  poderas  podera  poderamos  poderades poderan } ],# pluperfect
	[ qw{ possa   possas   possa   possamos   possades  possan   } ],# PresSub
	[ qw{ podesse podesses podesse podessemos podessedes podessen } ],# ImpSub
	[ qw{ poder   poderes  poder   podermos   poderdes   poderen  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       R        possa   possamos   possade    possan} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "podendo",
	pp => [ "podido", "podudo" ]
	);
my %ponner = (
	"finite" => [
	[ qw{ R       pos      pon     R          R          R    } ],	# Present
	[ qw{ R		  R        R       R          R          R     } ],	# Imperfect
	[ qw{ R       R        R       R          R          R     } ],	# Futuro
	[ qw{ pus     puseste  pos     pusemos    pusestes  puseron } ],# perfecto  
	[ qw{ pusera  puseras  pusera  puseramos  puserades puseran } ],# pluperfect
	[ qw{ R       R        R       R          R          R       } ],# PresSub
	[ qw{ pusesse pusesses pusesse pusessemos pusessedes pusessen } ],# ImpSub
	[ qw{ puser   puseres  puser   pusermos   puserdes   puseren  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       R        possa   possamos   possade    possan} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "ponnendo",
	pp => [ "posto", "" ]
	);
my %querer = (
	"finite" => [
	[ qw{ R       R        quer    R          R          R  } ],	# Present
	[ qw{ R		  R        R       R          R          R   } ],	# Imperfect
	[ qw{ querrei querras  querra  querremos  querredes  querran }],# Futuro
	[ qw{ quis    quiseste quis    quisemos   quisestes  quiseron}],# perfecto  
	[ qw{ quisera quiseras quisera quiseramos quiserades quiseran}],# pluperfect
	[ qw{ queira  queiras  queira  queiramos  queirades  queiran  } ],# PresSub
	[ qw{ quisesse quisesses quisesse quisessemos quisessedes quisessen}],#ImpSb
	[ qw{ quiser  quiseres quiser  quisermos  quiserdes  quiseren } ],# FutSub
	[ qw{ R       R        R       R          R          R    } ],# Condicional
	[ qw{ X       quer     queira  queramos   R         queiran} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "querendo",
	pp => [ "querido", "" ]
	);
my %saber = (
	"finite" => [
	[ qw{ sei     R        R       R          R          R     } ],	# Present
	[ qw{ R		  R        R       R          R          R     } ],	# Imperfect
	[ qw{ R       R        R       R          R          R     } ],	# Futuro
	[ qw{ soube   soubeste soube   soubemos   soubestes  souberon }],# perfecto
	[ qw{ soubera souberas soubera souberamos souberades souberan}],# pluperfect
	[ qw{ saiba   saibas   saiba   saibamos   saibades  saiban   } ],# PresSub
	[ qw{ soubesse soubesses soubesse soubessemos soubessedes soubessen }],#ImpSub
	[ qw{ souber  souberes souber  soubermos  souberdes  souberen  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       R        saiba   saibamos   R         saiban} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "sabendo",
	pp => [ "sabido", "sabudo" ]
	);
my %ser = (
	"finite" => [
	[ qw{ sou     es       é       somos      sodes      son } ],	# Present
	[ qw{ era 	  eras     era     eramos     erades     eran} ],	# Imperfect
	[ qw{ R		  R        R       R          R          R   } ],	# Futuro
	[ qw{ fui     foste    foi     fomos      fostes     foron   }],# perfecto  
	[ qw{ fora    foras    fora    foramos    forades    foran  }],# pluperfect
	[ qw{ seja    sejas    seja    sejamos    sejades    sejan  }],#  PresSub
	[ qw{ fosse   fosses   fosse   fossemos   fossedes   fossen  }],#ImpSb
	[ qw{ for     fores    for     formos     fordes     foren    } ],# FutSub
	[ qw{ R		  R        R       R          R          R   } ],# Condicional
	[ qw{ X       sê       seja    sejamos    sede       sejan }],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],	#
	gerund => "sendo",
	pp => [ "sido", "" ]
	);
my %ter = (
	"finite" => [
	[ qw{ tenno   R        ten     R          R          R    } ],	# Present
	[ qw{ tinia	  tinias   tinia   tiniamos   tiniades   tinian} ],	# Imperfect
	[ qw{ terrei  terras   terra   terremos   teredes    terràn} ],	# Futuro
	[ qw{ tive    teveste  teve    tivemos    tevestes  teveron } ],# perfecto  
	[ qw{ tivera  tiveras  tivera  tiveramos  tiverades tiveran } ],# pluperfect
	[ qw{ tenna	  tennas   tenna   tennamos   tennades   tennan} ],	# PresSub
	[ qw{ tevesse tevesses tevesse tevessemos tevessedes tevessen } ],# ImpSub
	[ qw{ tever   teveres  tever   tevermos   teverdes   teveren  } ],# FutSub
	[ qw{ R       R        R        R         R          R } ],	# Condicional
	[ qw{ X       ten      tenha   tenhamos   R          tenhan} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "tendo",
	pp => [ "tido", "" ]
	);
my %trazer = (
	"finite" => [
	[ qw{ trago   R        traz    R          R          R    } ],	# Present
	[ qw{ R       R        R       R          R          R     } ],	# Imperfect
	[ qw{ trarei  traras   trara   traremos   teredes    traran} ],	# Futuro
	[ qw{ trouxe  trouxeste trouxe trouxemos  trouxestes trouxeron }],# perfecto
	[ qw{ trouxera trouxeras trouxera trouxeramos trouxerades trouxeran}],#pluperfect
	[ qw{ traga	  tragas   traga   tragamos   tragades   tragan} ],	# PresSub
	[ qw{ trouxesse trouxesses trouxesse trouxessemos trouxessedes trouxessen } ],# ImpSub
	[ qw{ trouxer trouxeres trouxer trouxermos trouxerdes trouxeren }],# FutSub
	[ qw{ traria  trarias   traria  trariamos  trariades  trarien}],#Condicional
	[ qw{ X       traz     traga   tragamos   R          tragan} ],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],
	gerund => "trazendo",
	pp => [ "trazido", "" ]
	);
my %ver = (
	"finite" => [
	[ qw{ veio    R        R       R          R          R   } ],	# Present
	[ qw{ R       R        R       R          R          R   } ],	# Imperfect
	[ qw{ R       R        R       R          R          R   } ],	# Futuro
	[ qw{ vi	  viste    viu     vimos      vistes    viron} ],	# perfecto
	[ qw{ vira	  viras    vira    viramos    virades   viran} ],	# pluperfect
	[ qw{ veja    vejas    veja    vejamos    vejades   vejan  }],#  PresSub
	[ qw{ visse	  visses   visse   vissemos   vissedes  vissen }],	# ImpSb
	[ qw{ R		  vires    R       virmos     virdes    viren} ],	# FutSub
	[ qw{ veria   verias   veria   veriamos   veriades  verian } ],	# Condicional
	[ qw{ X       R        veia    veiamos    R         veian }],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],	#
	gerund => "vendo",
	pp => [ "visto", "" ]
	);
my %vir = (
	"finite" => [
	[ qw{ venno   vens     ven     R          R          R   } ],	# Present
	[ qw{ vinia   vinias   vinia   viniamos   viniades vinian} ],	# Imperfect
	[ qw{ verrei  verràs   verrà   verremos   verredes verràn} ],	# Futuro
	[ qw{ vin	  vieste   veio    viemos     viestes  vieron} ],	# perfecto
	[ qw{ viera	  vieras   viera   vieramos   vierades vieran} ],	# pluperfect
	[ qw{ venna   vennas   venna   vennamos   vennades   vennan  }],#  PresSub
	[ qw{ R		  R        R       R          R          R   } ],	# ImpSb
	[ qw{ R		  R        R       R          R          R   } ],	# FutSub
	[ qw{ verria  verrias  verria  verriamos  verriades verrian} ],	# Condicional
	[ qw{ X       R        R       R          R          R    }],	# Imperativo
	[ qw{ X       R        X       R          R          R  } ],	# Infinitive
	],	#
	gerund => "vindo",
	pp => [ "vido", "veudo" ]
	);
	my %irr_conjugations = ( aver => \%aver,	dar => \%dar, dizer => \%dizer,
							 estar => \%estar,	fazer => \%fazer, ir => \%ir,
							 poder => \%poder,	ponner => \%ponner, 
							 querer => \%querer, saber => \%saber, ser => \%ser,
							 ter => \%ter,		trazer => \%trazer,	
							 ver => \%ver, vir => \%vir );

	return if ( ! exists $irr_conjugations{$port} );

	my $irr_conj = $irr_conjugations{$port};	# the irregular conjugation
	my $conj = $conjugations{$suffix};			# the regular one

	# finite verbal forms
	my ( $tense, $person );
	for $tense ( 0 .. 10 ) {
		for $person ( 0 .. 5 ) {
			my $ending = $$irr_conj{finite}[$tense][$person];
			if ( $ending ne "X" ) {
				if ( $ending eq "R" ) {	# This one is regular
					$ending = $$conj{finite}[$tense][$person];
					$port = adjust( $suffix, $base, $ending );
				}
				else {					# and this one isn't.
					$port = $ending;
				}
				my ( $before, $after ) = split /=/, $tense[$tense];	#/
				my $x = "${person[$person]}.$before$eng$after";
				add_word( "|", $port, $x );
			}
		}
	}

	# gerund (present participle
	$port = $$irr_conj{gerund};
	add_word( "|", $port, "${eng}-ing" );

	# past participle
	my ( $pp, $x );
	for $pp ( 0 .. 1 ) {
		if ( $$irr_conj{pp}[$pp] ne "" ) {
			$port = $$irr_conj{pp}[$pp];
			$x = "${eng}-en";
			add_word( "|", $port, "$x" );
			decline( $port, "$x" );
		}
	}
}


# Make any needed spelling adjustments to connect the base and ending.
sub adjust
{
	my ( $conj, $base, $ending ) = @_;
	my $soft_vowels = "ie";
	my $hard_vowels = "aou";

	# Soften a 'g' to a 'j', or a 'c' to a 'ç',
	# if the following vowel goes from soft to hard.
	if ( $base =~ /[cg]$/ ) {
		if ( -1 ne index( $soft_vowels, substr( $conj, 0, 1 ) ) ) {
			if ( -1 ne index( $hard_vowels, substr( $ending, 0, 1 ) ) ) {
				my $x = substr( $base, -1 );
				$x =~ y/cg/çj/;
				$base = substr( $base, 0, -1 ) . $x;
			}
		}
	}

	# Harden a 'g' to a 'gu', or a 'c' to a 'qu',
	# if the following vowel goes from hard to soft.
	if ( $base =~ /[cg]$/ ) {
		if ( -1 ne index( $hard_vowels, substr( $conj, 0, 1 ) ) ) {
			if ( -1 ne index( $soft_vowels, substr( $ending, 0, 1 ) ) ) {
				my $x = substr( $base, -1 );
				$x =~ y/cg/qg/;
				$base = substr( $base, 0, -1 ) . $x . 'u';
			}
		}
	}

	return "$base$ending";
}

# Make the feminine from the masculine, and the plural from both.
sub decline
{
	my ( $port, $eng ) = @_;
	my $base   = substr $port, 0, -1;
	my $suffix = substr $port, -1;

	if ( $suffix eq "o" || $suffix eq "e" ) {
		pluralize( $port, $eng );	# Make the plural of the masculine
		my $fem = "${base}a";		# Make the feminine from the masculine
		add_word( "|", $fem, $eng );
		pluralize( $fem, $eng );	# Make the plural of the feminine
	}
}

sub pluralize
{
	my ( $port, $eng ) = @_;
	my $base   = substr $port, 0, -1;
	my $bas    = substr $base, 0, -1;
	my $suffix = substr $port, -1;

	if	  ( $suffix eq "o" ) { add_word( "|", "${port}s", "${eng}-s" ); }
	elsif ( $suffix eq "a" ) { add_word( "|", "${port}s", "${eng}-s" ); }
	elsif ( $suffix eq "e" ) { add_word( "|", "${port}s", "${eng}-s" ); }
	elsif ( $suffix eq "i" ) { add_word( "|", "${port}s", "${eng}-s" ); }
	elsif ( $suffix eq "u" ) { add_word( "|", "${port}s", "${eng}-s" ); }
	elsif ( $suffix eq "r" ) { add_word( "|", "${port}es", "${eng}-s" ); }
	elsif ( $suffix eq "z" ) { add_word( "|", "${port}es", "${eng}-s" ); }
	elsif ( $suffix eq "s" ) { add_word( "|", "${port}es", "${eng}-s" ); }
	elsif ( $suffix eq "l" ) { add_word( "|", "${base}is", "${eng}-s" ); }
	elsif ( $suffix eq "n" ) {
		if ( 'o' eq substr($base, -1) ) {
			add_word( "|", "${bas}ões", "${eng}-s" ); 
		} else {
			add_word( "|", "${port}es", "${eng}-s" ); 
		}
	}
	else  { print "$port ???\n" };
}

sub add_word 
{
	my ( $sep, $port, $eng ) = @_;

	if ( exists $dict{$port} )	{ $dict{$port} = "$dict{$port}$sep$eng"; }
	else						{ $dict{$port} = $eng; }
}

#!/usr/bin/perl -w

use strict;
use warnings;
use TL1FB;
use Time::Piece;
use Email::Sender::Simple qw(sendmail);
use Email::Simple;
use Email::Simple::Creator;


sub  trim { my $s = shift; $s =~ s/^\s+|\s+$//g; return $s };

{
    my $num_args = $#ARGV + 1;
    if ($num_args != 1) {
        print "\nUsage: fiberpl.pl oltname\n";
        exit;
    }

    my $oltid = $ARGV[0];

    my $tl1 = new TL1FB ('xxx.xxx.xxx.xxx', 3337, '1', '1');
    
    my @lines = $tl1->listaronus($oltid);

    my $now = Time::Piece->new;
    my $tempo = $now->strftime('%d/%m/%Y %T');
    my $tempoassuntoemail = $now->strftime('%d/%m/%Y %p');

    my @resultado;
    foreach my $l (@lines) {
        my @cols = split(/\t/,$l);

        my $pon = $cols[1];
        my $onunro = $cols[2];
        my $onuname = $cols[3];
        my $onumac = $cols[8];

        my @linessinal = $tl1->sinal($onuname);
        
        foreach my $s (@linessinal) {
            my @colunassinal = split(/\t/,$s);

            if ($colunassinal[1] ne '--') {

                my $rx = $colunassinal[1] * 1;
                my $tx = $colunassinal[3] * 1;
                my $prx = $colunassinal[12] * 1;
                my $ptx = $colunassinal[11] * 1;
                my $temperature = $colunassinal[7] * 1;

                push @resultado, [$onuname, $pon, $onunro, $onumac, $rx, $tx, $prx, $ptx, $temperature];
            }
        }
    }

    my @sorted = sort { $a->[4] <=> $b->[4] } @resultado;
    my @sortedplaca = sort { $a->[6] <=> $b->[6] } @resultado;
    #@sorted = reverse @sorted;

    my $i = 0;
    my $conteudo = '';

    foreach my $t (@sorted) {
        $i++;
        #print @$t[0] . " " . @$t[1] . " " . @$t[2] . " " . @$t[3] . " " . @$t[4];
        #print "\n";

        $conteudo .= "<tr>" .
    
        "<td>" . $i . "</td>" .
    
        "<td>" . trim(@$t[0]) . "</td>" .
    
        "<td>" . trim(@$t[1]) . "</td>" .
    
        "<td>" . trim(@$t[2]) . "</td>" .
    
        "<td>" . trim(@$t[3]) . "</td>" .
    
        "<td>" . trim(@$t[4]) . "</td>" .

        "<td>" . trim(@$t[5]) . "</td>" .

        "<td>" . trim(@$t[6]) . "</td>" .

        "<td>" . trim(@$t[7]) . "</td>" .

        "<td>" . trim(@$t[8]) . "</td>" .
     
        "</tr>" . "\n";

        if ($i == 100) {
            last;
        }
    }


    my $conteudo2 = '';
    $i = 0;
    foreach my $t (@sortedplaca) {
        $i++;
	#print @$t[0] . " " . @$t[1] . " " . @$t[2] . " " . @$t[3] . " " . @$t[4];
        #print "\n";

        $conteudo2 .= "<tr>" .

        "<td>" . $i . "</td>" .

        "<td>" . trim(@$t[0]) . "</td>" .

        "<td>" . trim(@$t[1]) . "</td>" .

        "<td>" . trim(@$t[2]) . "</td>" .

        "<td>" . trim(@$t[3]) . "</td>" .

        "<td>" . trim(@$t[4]) . "</td>" .

        "<td>" . trim(@$t[5]) . "</td>" .

        "<td>" . trim(@$t[6]) . "</td>" .

        "<td>" . trim(@$t[7]) . "</td>" .

        "<td>" . trim(@$t[8]) . "</td>" .

        "</tr>" . "\n";

        if ($i == 100) {
            last;
        }
    }    

my $html = <<"HTML";

<html>

<head>
<meta charset="UTF-8">

<style type="text/css">

table.gridtable {
	font-family: verdana,arial,sans-serif;
	font-size:11px;
	color:#333333;
	border-width: 1px;
	border-color: #666666;
	border-collapse: collapse;
    
    /* tamanho fixo para a tabela */
    table-layout: fixed;
    width: 100%;
    /*width: 250px;*/
}
table.gridtable th {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #dedede;
}
table.gridtable td {
	border-width: 1px;
	padding: 8px;
	border-style: solid;
	border-color: #666666;
	background-color: #ffffff;
    
    /* quebra o texto longo em linhas */
    word-wrap: break-word;         /* All browsers since IE 5.5+ */
    overflow-wrap: break-word;     /* Renamed property in CSS3 draft spec */
    
    /* centraliza o texto */
    text-align:center;
}
    
table.gridtable th.id {
    width: 30px;
} 

table.gridtable th.onunro {
    width: 40px;
}


table.gridtable th.slotpon {
    width: 100px;
} 

table.gridtable th.rx {
    width: 70px;
} 

table.gridtable th.tx {
    width: 70px;
} 

table.gridtable th.prx {
    width: 70px;
} 

table.gridtable th.ptx {
    width: 70px;
} 

table.gridtable th.temperatura {
    width: 70px;
} 


table.gridtable th.onumac {
    width: 145px;
} 

#titulo {
    margin-top: 8px;
    margin-bottom: 5px;
}

.texto {
    text-align:center;
    color: rgba(0,0,0,0.6);
}


</style>


</head>

<body>

<div id="titulo">
<div class="texto"><b>TOP 100 - SINAL FIBRA ($oltid)</b></div>
<div class="texto">($tempo)</div>
</div>

<div>

<table class="gridtable">
<tr>
	<th class="id"></th><th class="login">Login</th><th class="slotpon">Slot/Pon</th><th class="onunro">Nro</th><th class="onumac">Mac Onu</th><th class="tx">TX</th><th class="rx">RX</th><th class="ptx">PTX</th><th class="prx">PRX</th><th class="temperatura">&deg;C</th>
</tr>
	$conteudo
<tr>
	
</tr>
</table>

</div>

<br>
<div id="titulo">
<div class="texto"><b>TOP 100 - SINAL FIBRA ($oltid) - Ordenado por Placa</b></div>
<div class="texto">($tempo)</div>
</div>

<div>

<table class="gridtable">
<tr>

<th class="id"></th><th class="login">Login</th><th class="slotpon">Slot/Pon</th><th class="onunro">Nro</th><th class="onumac">Mac Onu</th><th            class="tx">TX</th><th class="rx">RX</th><th class="ptx">PTX</th><th class="prx">PRX</th><th class="temperatura">&deg;C</th>

</tr>
     	$conteudo2
<tr>

</tr>
</table>

</div>



</body>

</html>


HTML

#print $html;
 

my $email = Email::Simple->create(
    header => [
      To             => 'suporte1@thsprovider.com.br',
      To             => 'suporte2@thsprovider.com.br',
      From           => 'ths@ths-186-209-6-15',
      Subject        => "TOP 100 SINAL FIBRA ($oltid) - $tempoassuntoemail",
      'Content-Type' => 'text/html; charset=utf-8', 
    ],
    body => $html,
  );
  sendmail($email);

}

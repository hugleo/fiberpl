# fiberpl
Script para gerar um relatório de sinal das onus e enviar por email

Requer a instação das seguintes libs perl:

Net/Telnet.pm
Email/Sender/Simple.pm
Module/Pluggable.pm 

Ou talvez outros que ele pedir pra instalar.


No arquivo de contrab fica assim:

------------------
Requer instalado o ts que faz parte do pacote moreutils apenas para também para capturar possível log de erro com timestamp...


/etc/crontab

00 9 * * * ths perl -I/home/ths/Desktop/teste/fiberpl /home/ths/Desktop/teste/fiberpl/fiberelat.pl OLTSR 2>&1 | ts >> /home/ths/Desktop/teste/fiberplsr.log

------------------


Pra enviar email requer um servidor de email default instalado no server, aqui uso o postfix.


Configuração:
No arquivo fiberelat.pl alterar o ip e senha do seu anm2000.

my $tl1 = new TL1FB ('xxx.xxx.xxx.xxx', 3337, '1', '1');

Alterar também os emails desejados:

my $email = Email::Simple->create(
    header => [
      To             => 'email1@email',
      To             => 'email2@email',
      From           => 'ths@reverso',
      Subject        => "TOP 100 SINAL FIBRA ($oltid) - $tempoassuntoemail",
      'Content-Type' => 'text/html; charset=utf-8', 
    ],
    body => $html,
  );
  sendmail($email);

}


Alterar o também From           => 'ths@reverso', para o reverso de seu ip senão pode cair em mensagem de spam.
Para encontrar o reverso d seu ip: 
drill -x x.x.x.x
ou 
dig -x x.x.x.x


package TL1FB;
use Net::Telnet;
#use Data::Dumper;
use strict;

sub new {
    #print Dumper(@_);
    my $class = shift;

    my $self = {};
    bless $self, $class;

    $self->{_host} = shift;
    $self->{_port} = shift;
    $self->{_user} = shift;
    $self->{_pass} = shift;

    $self->{_telnet} = new Net::Telnet (Timeout => 30, Port => $self->{_port}, Prompt => '/;/');

    #print Dumper($self);

    ($self->{_telnet})->open($self->{_host});
    $self->login();

    return $self;
}

sub login {
    my ($self) = @_;
    my $cmd = 'LOGIN::UN='.$self->{_user}.',PWD='.$self->{_pass}.':CTAG::;';

    my @lines = $self->{_telnet}->cmd($cmd);
    #print @lines;
}

sub logout {
    my ($self) = @_;
    my $cmd = 'LOGOUT:::CTAG::;';
    
    my @lines = $self->{_telnet}->cmd($cmd);
    #print @lines;      
}

sub sinal {
    my ($self, $onuname) = @_;
    my $cmd = 'LST-OMDDM::ONUIP='.$onuname.',PEERFLAG=True:CTAG::;';

    my @lines = $self->{_telnet}->cmd(String => $cmd, Timeout => 160);

    return $self->parselines(@lines);
}

sub hand_shake {
    my ($self) = @_;
    my $cmd = 'SHAKEHAND:::CTAG::;';
    $self->{_telnet}->cmd(String => $cmd);
}

sub listaronus {
    my ($self, $oltid) = @_;
    my $cmd = 'LST-ONU::OLTID='.$oltid.':CTAG::;';
    my @lines = $self->{_telnet}->cmd(String => $cmd, Timeout => 350);
   
    return $self->parselines(@lines);
}

sub listar_status_onus {
    my ($self, $oltid, $ponid) = @_;
    my $cmd = 'LST-ONUSTATE::OLTID='.$oltid.',PONID='.$ponid.':CTAG::;';
  
    print $cmd."\n";
    my @lines = $self->{_telnet}->cmd(String => $cmd, Timeout => 160);
   
    $self->{_telnet}->dump_log('/tmp/some_file');

    return $self->parselines(@lines);
}

sub parselines {

    my ($self, @lines) = @_;

    my $iscontent = 0;
    my $isheader = 1;
    my @formatedlines;
    
    foreach my $l (@lines) {
        if ($l =~ /^\s*$/) {}
        elsif ($l =~ /^--------------------------------------------------------------------------------$/) {
            $iscontent = !$iscontent;
            $isheader = 1;
        }
        else {
            $l =~ s/\n//g;
            $l =~ s/\r//g;

            if ($iscontent) {
                $l =~ s/\n//g;
                $l =~ s/\r//g;

                if ($isheader) {
                    $isheader = 0;   
                }
                else {
                    push @formatedlines, $l;
                }
            }
        }
    }

    return @formatedlines;
}

sub testar {
    my ($self) = @_;
    #$self->login();


    #my @lines = $self->{_telnet}->cmd(";");
    #print @lines;

    #@lines = $self->{_telnet}->cmd(";");
    #print @lines;

    #print $this->{_host}."\n";
}

sub DESTROY {
    my ($self) = @_;
    $self->logout();
    ($self->{_telnet})->close();
    #print "bye\n";
}

1;

use RakudoPrereq v2017.05.380.g.0.a.100825.d,
    'Toaster.pm6 module requires Rakudo v2017.06 or newer';

unit class Toaster;

use Proc::Q;
use Temp::Path;
use Terminal::ANSIColor;
use WhereList;
use WWW;

use Toaster::DB;

has $.db = Toaster::DB.new;
has @.commits where all-items(Str, *.so) = ['nom'];

constant INSTALL_TIMEOUT  = 10*60;
constant ECO_API          = 'https://modules.perl6.org/.json';
constant RAKUDO_REPO      = 'https://github.com/rakudo/rakudo';
constant ZEF_REPO         = 'https://github.com/ugexe/zef';
constant RAKUDO_BUILD_DIR = 'build'.IO.mkdir.self;
constant BANNED_MODULES   = (); # regex objects to regex over the name

my $batch = floor 1.3 * do with run 'lscpu', :out, :!err {
    .out.lines(:close).grep(*.contains: 'CPU(s)').head andthen .words.tail.Int
} || 8;


method toast-all ($commit = 'nom') {
    my @modules = jget(ECO_API)<dists>.map(*.<name>).sort
        .grep: *.match: BANNED_MODULES.none;
    say "About to toast {+@modules} modules";
    self.toast: $commit, @modules;
}
method toast ($commit = 'nom', @modules) {
    self.build-rakudo: $commit;
    my $store = make-temp-dir;
    my $ver = run(:out, :!err, $*EXECUTABLE.absolute, '-e', ｢
        print $*PERL.compiler.version.Str
    ｣).out.slurp: :close;
    my $rakudo      = $ver.subst(:th(2..*), '.', '').split('g').tail;
    my $rakudo-long = $ver.subst(:th(2, 3), '.', '-').subst(:th(2..*), '.', '');

    react whenever proc-q @modules.map({
        my $where = $store.add(.subst: :g, /\W/, '_').mkdir;
        «zef --debug install "$_" "-to=inst#$where"»
    }), :tags[@modules], :$batch, :timeout(INSTALL_TIMEOUT) {
        my ToastStatus $status = .killed
          ?? Kill !! .out.contains('FAILED') ?? Fail !! Succ;

        $!db.add: $rakudo, $rakudo-long, .tag, .out, .err, ~.exitcode, $status;
        say colored "Finished {.tag}: $status", <red green>[$status ~~ Succ];
    }
}

method build-rakudo (Str:D $commit = 'nom') {
    indir RAKUDO_BUIL_DIR, {
        run «git clone "{RAKUDO_REPO}"»;
        run «git checkout "$commit"»;
        run «perl Configure.pl --gen-moar --gen-nqp --backends=moar»;
        run «make»;
        run «make install»;
        run «git clone "{ZEF_REPO}"»;

        temp %*ENV;
        %*ENV<PATH> = $*CWD.add('/install/bin').absolute ~ ":$*ENV<PATH>";
        indir $*CWD.add('zef'), { run «perl6 -Ilib bin/zef install . » }
        $*CWD.add('/install/share/perl6/site/bin').absolute ~ ":$*ENV<PATH>"
    }
}

unit class Toaster;

use Proc::Q;
use Temp::Path;
use Terminal::ANSIColor;
use WhereList;
use WWW;

use Toaster::DB;

has $.db = Toaster::DB.new;
has @.commits where all-items(Str, *.so) = ['nom'];

constant INSTALL_TIMEOUT = 500*60;
constant ECO_API = 'https://modules.perl6.org/.json';
constant BANNED_MODULES = (); # regex objects to regex over the name

my $batch = floor 1.3 * do with run 'lscpu', :out, :!err {
    .out.lines(:close).grep(*.contains: 'CPU(s)').head andthen .words.tail.Int
} || 8;


method toast-all {
    my @modules = jget(ECO_API)<dists>.map(*.<name>).sort
        .grep: *.match: BANNED_MODULES.none;
    say "About to toast {+@modules} modules";
    self.toast: @modules;
}
method toast (@modules) {
    my $store = make-temp-dir;
    # XXX TODO swap toaster to build own perl6s and use those to get ver from
    my $ver = run(:out, :!err, $*EXECUTABLE.absolute, '-e', ｢
        print $*PERL.compiler.version.Str
    ｣).out.slurp: :close;
    my $rakudo      = $ver.subst(:th(2..*), '.', '').split('g').tail;
    my $rakudo-long = $ver.subst(:th(2, 3), '.', '-').subst(:th(2..*), '.', '');

    react whenever proc-q @modules.map({
        my $where = $store.add(.subst: :g, /\W/, '_').mkdir;
        «zef --debug install "$_" "-to=inst#$where"»
    }), :tags[@modules], :$batch {
        my ToastStatus $status = .killed
          ?? Kill !! .out.contains('FAILED') ?? Fail !! Succ;

        $!db.add: $rakudo, $rakudo-long, .tag, $status;
        say colored "Finished {.tag}: $status", <red green>[$status ~~ Succ];
    }
}

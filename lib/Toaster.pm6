unit class Toaster;

use Proc::Q;
use WhereList;
use Temp::Path;
use WWW;

has @.commits where all-items(Str, *.so) = ['nom'];

constant INSTALL_TIMEOUT = 500*60;
constant ECO_API = 'https://modules.perl6.org/.json';
constant BANNED_MODULES = (); # regex objects to regex over the name

my $batch = floor 1.3 * do with run 'lscpu', :out, :!err {
    .out.lines(:close).grep(*.contains: 'CPU(s)').head andthen .words.tail.Int
} || 8;

class Zefyr {
    method toast-all {
        self.toast: run(:out, <zef list>).out.lines(:close).grep(
            *.starts-with('#').not
        )».trim.sort.grep: *.match: BANNED_MODULES.none;
    }
    method toast (*@modules) {
        @modules .= head: 20;
        my $store = make-temp-dir;

        react whenever proc-q @modules.map(
            «zef --debug install "$_" "-to=inst#$store"»
        ), :tags[@modules], :$batch -> $r {
            say join ' ', "Finished $r.tag(): ",
                 <SUCCEEDED!  FAILED!>[.out.contains: 'FAILED' or .killed],
                 ('(killed)' if .killed);
        }
    }
}

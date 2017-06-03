#!/usr/bin/env perl6
use v6.d.PREVIEW;
# use WWW;

constant OUTPUT_DIR = 'output'.IO;
constant INSTALL_TIMEOUT = 500*60;
constant ECO_API = 'https://modules.perl6.org/.json';

class Zefyr {
    method toast-all {
        self.toast: run(:out, <zef list>).out.lines(:close).grep(
            *.starts-with('#').not
        )».trim;
    }
    method toast (*@modules) {
        say "Installing:\n@modules.join("\n")";
        with OUTPUT_DIR { .dir andthen $_».unlink».so; .rmdir.so; .mkdir.so; }

        my role ModuleNamer[$name] { method Module-Name { $name } }
        my @results = @modules.map: -> $module {
            start {
                my $proc = Proc::Async.new: :out, :err,
                    |<zef --serial --debug install>, $module;
                CATCH { default { say "DIED HERE! "; .Str.say; .backtrace.say } }
                my $out = ''; my $err = '';
                $proc.stdout.tap: $out ~ *;
                $proc.stderr.tap: $err ~ *;
                my $proc-prom = $proc.start;
                Promise.in(INSTALL_TIMEOUT).then: {
                    $proc-prom or try {
                        $out ~= 'FAILED! KILLING INSTALL FOR TAKING TOO LONG!';
                        say "KILLING install of $module for taking too long";
                        $proc.kill;
                        $proc.kill: SIGTERM;
                        $proc.kill: SIGSEGV
                    }
                }
                so try await $proc-prom;
                OUTPUT_DIR.add($module.subst: :g, /\W+/, '-').spurt:
                      "ERR: $err\n\n-----\n\n" ~ "OUT: $out\n";
                $out
            } does ModuleNamer[$module]
        }

        say "Started {+@results} Promises. Awaiting results";
        while @results {
            await Promise.anyof: @results;
            my @ready = @results.grep: *.so;
            @results .= grep: none @ready;
            for @ready {
                say .Module-Name ~ ': ', .status ~~ Kept
                    ?? <SUCCEEDED!  FAILED!>[.result.contains: 'FAILED']
                    !! "died with {.cause}";
            }
        }
    }
}

sub MAIN {
    Zefyr.new.toast-all;
}

unit class Toaster::DB;
use DBIish;

has $.db = 'toast.sqlite.db';
has $!dbh;

enum ToastStatus is export <Succ Fail Kill>;

submethod TWEAK {
    my $exists = $!db.IO.e;
    $!dbh = DBIish.connect: 'SQLite', :database($!db), :RaiseError;
    $exists or self.deploy
}

method deploy {
    $!dbh.do: ｢
        CREATE TABLE toast (
            id          INTEGER PRIMARY KEY,
            rakudo      TEXT NOT NULL,
            rakudo_long TEXT NOT NULL,
            module      TEXT NOT NULL,
            status      TEXT NOT NULL,
            time        INTEGER NOT NULL
            stderr      TEXT NOT NULL,
            stdout      TEXT NOT NULL,
            exitcode    TEXT NOT NULL
        )
    ｣;
    self
}

method add (
  Str:D $rakudo, Str:D $rakudo-long, Str:D $module,
  Str:D $stderr, Str:D $stdout,      Str:D $exitcode,
  ToastStatus $status
)  {
    $!dbh.do: ｢
        DELETE FROM toast WHERE rakudo = ? AND rakudo_long = ? AND module = ?
    ｣, $rakudo, $rakudo-long, $module;
    $!dbh.do: ｢
        INSERT INTO toast (
            rakudo, rakudo_long, module,
            stderr, stdout, exitcode, status, time
        )
        VALUES (?, ?, ?, ?, ?)
    ｣, $rakudo, $rakudo-long, $module, $stderr, $stdout, $exitcode,
      ~$status, time;
    self
}

method all {
  $!dbh.d.allrows: :array-of-hash
}

method DESTROY { quietly try self.close }
method close {
    $!dbh.dispose;
    self
}

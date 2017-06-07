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
            id     INTEGER PRIMARY KEY,
            rakudo TEXT NOT NULL,
            module TEXT NOT NULL,
            status TEXT NOT NULL,
            time   INTEGER NOT NULL
        )
    ｣;
    self
}

method add (Str:D $rakudo, Str:D $module, ToastStatus $status)  {
    $!dbh.do: ｢
        DELETE FROM toast WHERE rakudo = ? AND module = ?
    ｣, $rakudo, $module;
    $!dbh.do: ｢
        INSERT INTO toast (rakudo, module, status, time)
        VALUES (?, ?, ?, ?)
    ｣, $rakudo, $module, ~$status, time;
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

unit class Toaster::DB;
use DBIish;

has $.db = 'toast.sqlite.db';
has DBIish $!dbh;

subset ToastStatus of Str:D where any <S F> is export;

submethod TWEAK {
    my $exists = $!db.IO.e;
    $!dbh = DBIish.connect: 'SQLite', :database($!db), :RaiseError;
    $exists or self.deploy
}

method deply {
    $!dbh.do: ｢
        CREATE TABLE toast (
            id     INTEGER PRIMARY KEY,
            commit TEXT NOT NULL,
            module TEXT NOT NULL,
            status TEXT NOT NULL
            time   INTEGER NOT NULL
        )
    ｣;
    self
}

method add (Str:D $commit, Str:D $module, ToastStatus $status)  {
    $!dbh.do: ｢
        INSERT INTO toast (commit, module, status, time) VALUES (?, ?, ?, ?)
    ｣, $commit, $module, $status, time;
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

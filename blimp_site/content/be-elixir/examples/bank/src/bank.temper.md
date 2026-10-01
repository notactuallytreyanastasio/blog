# A bank of actors

    export class Box { public var v: Int = 0; }

    @actor export class Account(public owner: String) {
      public var balance: Int = 0;
      public deposit(n: Int): Int { balance += n; balance }
      public withdraw(n: Int): Int throws Bubble {
        if (n > balance) { bubble() }
        balance -= n;
        balance
      }
      public transferTo(other: Account, n: Int): Void throws Bubble {
        withdraw(n);
        other.deposit(n);
      }
      public pingBack(p: Pinger): Int { p.ping(this) }
      public stash(b: Box): Int { b.v }
    }

    @actor export class Pinger {
      public ping(a: Account): Int { a.deposit(1) }
    }

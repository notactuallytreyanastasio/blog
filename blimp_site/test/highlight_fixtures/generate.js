// Regenerates the fixtures test/highlight_test.blimp compares against: the
// output of highlight.js itself for every elixir block in the posts
// (corpus-NN) and for a list of edge cases (edge-NNN). Apostrophes are
// written as &#39; to match escape_html; hljs writes &#x27;.
//
//   HLJS=/path/to/node_modules/highlight.js node test/highlight_fixtures/generate.js
//
// Last generated with highlight.js 11.11.1.
const fs = require('fs'), path = require('path');
const hljs = require(process.env.HLJS || path.join(process.env.HOME, 'code/slides/node_modules/highlight.js'));
const here = __dirname;
const posts = path.join(here, '../../../priv/static/posts');
const hl = (code) => hljs.highlight(code, { language: 'elixir' }).value.replace(/&#x27;/g, '&#39;');
const out = (name, code) => {
  fs.writeFileSync(path.join(here, name + '.ex'), code);
  fs.writeFileSync(path.join(here, name + '.html'), hl(code));
};

// Same rule as the test: a line that is ```elixir opens, the next line
// starting with ``` closes, the code is the lines between.
let n = 0;
for (const f of fs.readdirSync(posts).sort()) {
  if (!f.endsWith('.md') || /[0-9a-f]{32}/.test(f)) continue;
  let inBlock = false, buf = [];
  for (const l of fs.readFileSync(path.join(posts, f), 'utf8').split('\n')) {
    if (!inBlock && l.trim() === '```elixir') { inBlock = true; buf = []; continue; }
    if (inBlock && l.trim().startsWith('```')) {
      inBlock = false;
      out('corpus-' + String(n++).padStart(2, '0'), buf.join('\n'));
      continue;
    }
    if (inBlock) buf.push(l);
  }
}

const cases=[
 'defmodule Foo.Bar do\n  use GenServer\nend',
 'defmodule\nFoo do end', 'defmodule Foo; x',
 'def foo?(x), do: x', 'defp bar!(a) when is_atom(a), do: :ok', 'defmacro m(x)', 'def', 'def\n\n  foo',
 'x.def foo', 'Kernel.def', 'defstruct [:a, :b]', 'defguard is_x(x) when x > 1', 'defdelegate f(x), to: M',
 '"a #{b + 1} c"', '"a #{"nested #{x}"} c"', '"unterminated', '"a #{ unterminated', '"esc \\" q"', '\'charlist\'',
 '"""\nheredoc #{x}\n"""', "'''\nh\n'''", '~S"no #{x} \\"', '~S"""\nraw\n"""', "~S'a'",
 '~r/ab+c/iu x', '~r{a}}', '~R/x\\/y/', '~w(a b c)a', '~s[a\\]b] y', '~s<a>', '~s|a|', "~c'x'", '~H"""\n<div a="b">\n"""',
 '~s(a)(b)', '~s(a #{b} \\n)', '~S(a\\)b)', '~E(x)',
 ':ok :error :"quoted atom" :+ :<=> :== :=== :[] :foo= :a? :b!', ':: x :: y', 'a::b', ': x', ':1', ':"a"b', ':ok|x',
 '%{a: 1, "b" => 2, c?: 3}', '[do: x, else: y]', 'if x, do: y, else: z',
 '1 1_000 3.14 1.0e10 1.5E-3 0x1F 0b101 0o17 x-1 a1 1..10 -5 0xZ 1.e5',
 '@moduledoc """\ndoc\n"""', '@spec f(integer) :: :ok', '@@x $x $! @ x',
 '# TODO: fix this\n# plain comment with words here', 'x # c "not a string"', '"# not a comment"',
 'IO.puts("hi")', 'Enum.map(xs, &(&1 * 2))', 'fn x -> x end', 'case x do\n  {:ok, v} -> v\n  _ -> nil\nend',
 'with {:ok, a} <- f(), do: a', 'receive do\n  msg -> msg\nafter\n  100 -> :timeout\nend', 'true and false or not nil',
 'x.end y.in', 'unquote_splicing(x) quote do: x', '?a ?#', 'A B1 AB', 'fooBar Foo_bar', 'é :é "é" #é\n~s(\\é)',
 'x = "a" <> "b"', 'raise ArgumentError, "bad"', 'try do\n x\nrescue\n e -> e\ncatch\n  :exit, _ -> 1\nend',
 '"a\r\nb" # c\r\nd', '~r/x/uismxfUU', ':"#{a}b"', '"#{}"', '#{x}', 'x}', '%User{name: "x"}', 'defimpl Proto, for: X do end',
 'IO.inspect(x, label: "y")', '& &1', 'x |> Enum.map(fn {k, v} -> {k, v * 2} end)', '<<a::binary-size(4), rest::binary>>',
];
cases.forEach((c, i) => out('edge-' + String(i).padStart(3, '0'), c));
console.log(n + ' corpus blocks, ' + cases.length + ' edge cases');

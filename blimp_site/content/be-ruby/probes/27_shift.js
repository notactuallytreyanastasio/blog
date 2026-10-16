// The JavaScript half of 27_deque_and_bits.rb: is Array.prototype.shift
// cheap enough to be a deque's removeFirst? Run with `node 27_shift.js`.
for (const n of [100000, 1000000]) {
  const a = [];
  const t = Date.now();
  for (let i = 0; i < n; i++) a.push(i);
  for (let i = 0; i < n; i++) a.shift();
  console.log(`push ${n}, then shift ${n}, ms`, Date.now() - t);
}

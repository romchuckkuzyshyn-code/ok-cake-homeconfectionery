// Генерує supabase/seed.sql з data.js: node supabase/make-seed.js
const fs = require('fs');
const path = require('path');
const window = {};
new Function('window', fs.readFileSync(path.join(__dirname, '..', 'data.js'), 'utf8'))(window);
const q = s => `'${String(s).replace(/'/g, "''")}'`;
const arr = a => `array[${a.map(q).join(', ')}]::text[]`;
const rows = window.SEED.map(d =>
  `  (${q(d.category)}, ${d.sort}, ${q(d.name)}, ${q(d.price)}, ${q(d.size)}, ${q(d.extra)}, ${q(d.text)}, ${arr(d.items)}, ${arr(d.tags)}, ${arr(d.photos)}, ${d.hidden})`);
fs.writeFileSync(path.join(__dirname, 'seed.sql'),
  `-- Початкове заповнення. Запускати один раз, коли таблиця порожня.\n` +
  `insert into public.desserts (category, sort, name, price, size, extra, text, items, tags, photos, hidden) values\n` +
  rows.join(',\n') + ';\n');
console.log(rows.length + ' rows');

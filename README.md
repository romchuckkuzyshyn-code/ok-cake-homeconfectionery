# ok cake homeconfectionery

Прайс домашньої кондитерської Оксани Кузишин (Львів): вкладки «Кенді бар» і «Торти».

- `index.html` — публічна сторінка. Дані бере з Supabase, а якщо його не налаштовано, то з `data.js`.
- `admin.html` — адмінка для редагування цін, складу і фото (вхід за email і паролем, редагувати може лише користувач із таблиці `admins`).
- `supabase/schema.sql` — таблиці, RLS і bucket для фото; `supabase/seed.sql` — початкові дані (генерується `node supabase/make-seed.js`).
- `config.js` — URL і publishable-ключ Supabase.

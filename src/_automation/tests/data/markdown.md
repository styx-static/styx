---
foo: "The ${bar}"
bar: "answer"
baz: 40
---

Intro text.

<!--more-->

First page

{{ "{{ meta.foo }} is {{ toString (meta.baz + env.buz) }}." }}

---
---

Second page.

\{{ non evaluated nix }}

{{ "this \}} is not evaluated" }}

---
---

Third page.

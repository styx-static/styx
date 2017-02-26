{---
foo = "The ${bar}";
bar = "answer";
baz = 40;
---}
{{ "{{ meta.foo }} is {{ toString (meta.baz + env.buz) }}." }}

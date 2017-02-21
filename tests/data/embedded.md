2 + 2 = {{ lib.toString (2+2) }}
{{ let answer = "42"; in ''
 Answer is {{ answer }} and foo is {{ foo }}
''}}
